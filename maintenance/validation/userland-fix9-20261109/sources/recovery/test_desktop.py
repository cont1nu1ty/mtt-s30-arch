"""No device access: reject wrong GPUs, virtual outputs, corrupt frames, leaks."""
import json
from contextlib import ExitStack
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch, Mock
import desktop_support as d

ROOT = Path(__file__).resolve().parents[2]


def pixels(frame):
    colors = (b'\xff\0\0\xff', b'\0\xff\0\xff', b'\0\0\xff\xff', b'\xff\xff\xff\xff')
    return b''.join(colors[(x // 16 + 3 * (y // 16) + frame) % 4] for y in range(192) for x in range(256))


SUPPORT = '''LogicalOutput backend
==============
Name: DRM
Atomic Mode Setting on GPU 0: true
Screen 0:
---------
Name: HDMI-A-1
Enabled: 1
Geometry: 0,0,1920x1080
Scale: 1
Compositing is active
Compositing Type: OpenGL ES
OpenGL vendor string: Moore Threads
OpenGL renderer string: MTT S30
OpenGL platform interface: EGL
'''

ACCEPTED = ('kwin_scene_opengl: MTT compatibility: context import formats before QList("XBGR8888", "XRGB8888") '
            'current QList("XRGB8888") accepted QList("XRGB8888") removed QList("XBGR8888")')
SELECTED = ('kwin_wayland_drm: MTT validation: swapchain selected source drm-layer '
            'size QSize(1920, 1080) fourcc 875713112 modifier 72057594037927935 importMode 0 bufferTarget 0')
SHADOW = SELECTED.replace('source drm-layer', 'source shadow')
REJECTED = 'kwin_scene_opengl: MTT compatibility: context import formats rejected: current-context DMA-BUF query failed'
FIXED = ('kwin_scene_opengl: MTT compatibility: fixed-driver import formats tableEntries 18 '
         'vendorSha256 2583b5c4e793389e0d130bfb8895884dfdee358ac70d63195deeba1eb0d1a07c '
         'outside-primary-table QList("AB30 little-endian (0x30334241)", "XB24 little-endian (0x34324258)")')


class Desktop(unittest.TestCase):
    def test_context_and_physical_swapchain_evidence_retains_exact_lines(self):
        evidence = d.validate_compositor_compatibility('\n'.join((FIXED, ACCEPTED, SHADOW, SELECTED)), SUPPORT)
        self.assertTrue(evidence['context_import_formats_accepted'])
        self.assertEqual(evidence['context_import_formats_evidence'], [ACCEPTED])
        self.assertTrue(evidence['fixed_driver_import_table_verified'])
        self.assertEqual(evidence['fixed_driver_import_table_evidence'], [FIXED])
        self.assertEqual(evidence['fixed_driver_import_table_invalid'], [])
        self.assertTrue(evidence['drm_layer_swapchain_selected'])
        self.assertEqual(evidence['swapchain_selection_evidence'], [SHADOW, SELECTED])
        self.assertEqual(evidence['drm_layer_swapchains'], [{
            'line': SELECTED, 'size': [1920, 1080], 'fourcc': 875713112,
            'modifier': 72057594037927935, 'import_mode': 0, 'buffer_target': 0,
            'physical_outputs': ['HDMI-A-1'],
        }])

    def test_context_and_swapchain_markers_cannot_hide_missing_stages_or_faults(self):
        for text in ('', SELECTED, ACCEPTED, ACCEPTED + '\n' + SHADOW, REJECTED + '\n' + SELECTED,
                     ACCEPTED + '\n' + REJECTED + '\n' + SELECTED,
                     ACCEPTED + '\n' + SELECTED + '\nError creating EGLImageKHR: "EGL_BAD_PARAMETER"'):
            with self.subTest(text=text), self.assertRaises(RuntimeError):
                d.validate_compositor_compatibility(FIXED + '\n' + text, SUPPORT)
        self.assertFalse(d.compositor_compatibility_evidence(REJECTED)['context_import_formats_accepted'])

    def test_cursor_copy_or_unmatched_swapchain_cannot_prove_physical_output(self):
        variants = (SELECTED.replace('QSize(1920, 1080)', 'QSize(64, 64)'),
                    SELECTED.replace('importMode 0', 'importMode 1'),
                    SELECTED.replace('importMode 0', 'importMode 2'),
                    SELECTED.replace('bufferTarget 0', 'bufferTarget 1'),
                    SELECTED.replace('source drm-layer', 'source drm-layer-other'))
        for line in variants:
            with self.subTest(line=line), self.assertRaisesRegex(RuntimeError, 'physical output'):
                d.validate_compositor_compatibility(FIXED + '\n' + ACCEPTED + '\n' + line, SUPPORT)
        for support in (SUPPORT.replace('Enabled: 1', 'Enabled: 0'), SUPPORT.replace('HDMI-A-1', 'Virtual-1'),
                        SUPPORT.replace('Scale: 1\n', ''), SUPPORT.replace('Scale: 1', 'Scale: 0')):
            with self.subTest(support=support), self.assertRaisesRegex(RuntimeError, 'physical output'):
                d.validate_compositor_compatibility(FIXED + '\n' + ACCEPTED + '\n' + SELECTED, support)

    def test_scaled_physical_geometry_matches_pixel_size(self):
        scaled = SUPPORT.replace('1920x1080', '1536x864').replace('Scale: 1', 'Scale: 1.25')
        evidence = d.validate_compositor_compatibility(FIXED + '\n' + ACCEPTED + '\n' + SELECTED, scaled)
        self.assertEqual(evidence['physical_output_sizes'], [{
            'name': 'HDMI-A-1', 'logical_size': [1536.0, 864.0], 'scale': 1.25, 'pixel_size': [1920, 1080],
        }])

    def test_software_exempts_vendor_markers_but_not_faults_or_hardware_renderer_gate(self):
        d.validate_compositor_compatibility('', software=True)
        with self.assertRaises(RuntimeError):
            d.validate_compositor_compatibility(REJECTED, software=True)
        with self.assertRaises(RuntimeError):
            d.validate_support(SUPPORT.replace('MTT S30', 'llvmpipe'))

    def mock_hardware_session(self, startup_log, final_log=None, client_exit=0, dispatch=True,
                              client_driver_dir='desktop/client-dri'):
        """Exercise the real session gates with all process/device I/O replaced."""
        with tempfile.TemporaryDirectory() as tmp, ExitStack() as patches:
            stage = Path(tmp).resolve()
            (stage / 'desktop-runtime').mkdir()
            (stage / 'desktop-runtime/mtt-s30-test').touch()
            process = Mock(pid=42424242)
            process.poll.return_value = None
            process.wait.return_value = 15
            proc = Path('/proc/42424242')
            original_exists, original_read, original_resolve = Path.exists, Path.read_text, Path.resolve
            original_iterdir, original_readlink = Path.iterdir, d.os.readlink

            def exists(path):
                return True if path == Path('/sys/module/mtgpu') else original_exists(path)

            def read(path, *args, **kwargs):
                if path == Path('/sys/class/watchdog/watchdog0/state'):
                    return 'active\n'
                if path == proc / 'maps':
                    return str(stage / 'desktop/kwin/libkwin.so.6')
                return original_read(path, *args, **kwargs)

            def resolve(path, *args, **kwargs):
                return stage / 'desktop/kwin/kwin_wayland' if path == proc / 'exe' else original_resolve(path, *args, **kwargs)

            def iterdir(path):
                return iter([proc / 'fd/9']) if path == proc / 'fd' else original_iterdir(path)

            def readlink(path, *args, **kwargs):
                return '/dev/dri/card0' if Path(path) == proc / 'fd/9' else original_readlink(path, *args, **kwargs)

            def launch(*args, **kwargs):
                kwargs['stdout'].write(d.BUILD_MARKER + '\n' + startup_log)
                kwargs['stdout'].flush()
                return process

            def query(args, **kwargs):
                if args[-1] == 'org.kde.KWin.supportInformation':
                    return SUPPORT
                return '42424242' if 'org.freedesktop.DBus.GetConnectionUnixProcessID' in args else 'true'

            def client(*args, **kwargs):
                result = {'passed': True, 'mode': 'wayland-s30', 'frames': 60, 'pixels_checked': 2949120,
                          'mismatches': 0, 'discarded': 0, 'renderer': 'MTT S30', 'presented': 60,
                          'hardware_presentations': 60, 'presentation_flags_all': 7, 'egl_vendor': 'Mesa Project'}
                kwargs['stdout'].write('\n'.join(('Graphics library: ' + str(stage / 'desktop/egl/libEGL_mesa.so.0'),
                    'Graphics library: ' + str(stage / client_driver_dir / 'mtgpu_dri.so'),
                    'Graphics library: ' + str(stage / client_driver_dir / 'musa_dri.so'),
                    d.EGL_LOOKUP_MARKER, d.EGL_SCREEN_MARKER, d.EGL_CONTEXT_MARKER, d.EGL_CONFIG_MARKER,
                    d.EGL_DISPLAY_MARKER, (d.EGL_DISPATCH_MARKER + ' ' + str(stage / d.VENDOR_GLAPI)) if dispatch else '',
                    json.dumps(result))) + '\n')
                kwargs['stdout'].flush()
                (stage / 'wayland.rgba').write_bytes(pixels(59))
                if final_log is not None:
                    (stage / 'kwin.log').write_text(d.BUILD_MARKER + '\n' + final_log)
                return subprocess.CompletedProcess(args[0], client_exit)

            for target, name, replacement in ((d, 'verify_bundle', Mock()), (d, 'check_session_kernel', Mock()),
                    (d.os, 'geteuid', lambda: 0), (d.os, 'readlink', readlink), (d.time, 'sleep', lambda seconds: None),
                    (Path, 'exists', exists), (Path, 'read_text', read), (Path, 'resolve', resolve),
                    (Path, 'iterdir', iterdir), (d.subprocess, 'Popen', launch), (d.subprocess, 'check_output', query)):
                patches.enter_context(patch.object(target, name, replacement))
            client_mock = patches.enter_context(patch.object(d.subprocess, 'run', side_effect=client))
            patches.enter_context(patch.dict(d.os.environ, {
                'XDG_RUNTIME_DIR': str(stage / 'desktop-runtime'), 'DBUS_SESSION_BUS_ADDRESS': 'isolated-test-bus',
                'KWIN_DRM_DEVICES': '/dev/dri/card0'}, clear=True))
            code = d.session(stage, '/dev/dri/card0')
            return code, json.loads((stage / 'desktop-session-result.json').read_text()), client_mock.call_count

    def test_session_refuses_client_when_context_or_output_evidence_is_missing(self):
        for log in (SELECTED, ACCEPTED + '\n' + SHADOW, REJECTED + '\n' + SELECTED,
                    ACCEPTED + '\n' + SELECTED.replace('QSize(1920, 1080)', 'QSize(64, 64)')):
            with self.subTest(log=log):
                code, state, clients = self.mock_hardware_session(FIXED + '\n' + log)
                self.assertEqual(code, 1)
                self.assertEqual(clients, 0)
                self.assertFalse(state['passed'])
                self.assertEqual(state['swapchain_selection_evidence'], [log.splitlines()[-1]])

    def test_session_requires_final_evidence_and_records_progress_after_failure(self):
        good = FIXED + '\n' + ACCEPTED + '\n' + SELECTED
        code, state, clients = self.mock_hardware_session(good)
        self.assertEqual((code, clients, state['passed']), (0, 1, True))
        for final_log in (FIXED + '\n' + SELECTED, good + '\nGL_CONTEXT_LOST', good + '\n' + REJECTED):
            with self.subTest(final_log=final_log):
                code, state, clients = self.mock_hardware_session(good, final_log=final_log)
                self.assertEqual((code, clients, state['passed']), (1, 1, False))
                self.assertTrue(state['drm_layer_swapchain_selected'])
                self.assertEqual(state['swapchain_selection_evidence'], [SELECTED])
        code, state, clients = self.mock_hardware_session(good, client_exit=1)
        self.assertEqual((code, clients, state['passed']), (1, 1, False))
        self.assertEqual(state['context_import_formats_evidence'], [ACCEPTED])
        self.assertTrue(state['drm_layer_swapchain_selected'])

    def test_session_requires_pinned_import_table_before_starting_client(self):
        wrong_sha = FIXED.replace('2583b5c4e793389e0d130bfb8895884dfdee358ac70d63195deeba1eb0d1a07c', '0' * 64)
        variants = ('', wrong_sha, FIXED.replace('tableEntries 18', 'tableEntries 17'),
                    FIXED.replace('vendorSha256 ', 'wrongField '), FIXED + '\n' + wrong_sha)
        for marker in variants:
            with self.subTest(marker=marker):
                code, state, clients = self.mock_hardware_session(marker + '\n' + ACCEPTED + '\n' + SELECTED)
                self.assertEqual((code, clients, state['passed']), (1, 0, False))
                self.assertIn('pinned 18-format', state['error'])
                self.assertFalse(state['fixed_driver_import_table_verified'])
                self.assertTrue(state['context_import_formats_accepted'])
                self.assertTrue(state['drm_layer_swapchain_selected'])
                self.assertEqual(state['fixed_driver_import_table_evidence'], marker.splitlines())

    def test_late_table_change_cannot_retain_a_successful_session(self):
        good = FIXED + '\n' + ACCEPTED + '\n' + SELECTED
        for final_log in (ACCEPTED + '\n' + SELECTED,
                          good + '\n' + FIXED.replace('tableEntries 18', 'tableEntries 19')):
            with self.subTest(final_log=final_log):
                code, state, clients = self.mock_hardware_session(good, final_log=final_log)
                self.assertEqual((code, clients, state['passed']), (1, 1, False))
                self.assertFalse(state['fixed_driver_import_table_verified'])
                self.assertEqual(state['fixed_driver_import_table_evidence'],
                                 [line for line in final_log.splitlines() if 'fixed-driver import formats' in line])
        # A client failure retains the table stage without claiming session success.
        code, state, clients = self.mock_hardware_session(good, client_exit=1)
        self.assertEqual((code, clients, state['passed']), (1, 1, False))
        self.assertTrue(state['fixed_driver_import_table_verified'])
        self.assertEqual(state['fixed_driver_import_table_evidence'], [FIXED])

    def test_v5_crash_preserves_progress_without_claiming_new_bridge(self):
        stage = '/var/lib/mtt-s30-test/20261104-112910/test'
        log = ROOT / 'maintenance/validation/runtime-20261104-112910/wayland-client.log'
        evidence = d.client_compatibility_evidence(stage, log.read_text())
        self.assertEqual(evidence, {
            'private_client_egl_verified': True,
            'private_client_dri_verified': False,
            'mtgpu_lookup_v1_selected': True,
            'mtgpu_public_screen_and_context_selected': True,
            'mtgpu_config_bounds_verified': True,
            'mtgpu_display_bridge_selected': False,
            'mtgpu_gles_dispatch_selected': False,
        })
        wrong_stage = d.client_compatibility_evidence('/wrong-stage', log.read_text())
        self.assertFalse(wrong_stage['private_client_egl_verified'])

    def test_hardware_session_requires_vendor_dispatch_even_if_client_reports_success(self):
        good = '\n'.join((FIXED, ACCEPTED, SELECTED))
        code, state, clients = self.mock_hardware_session(good, dispatch=False)
        self.assertEqual((code, clients, state['passed']), (1, 1, False))
        self.assertIn('GLES dispatch library', state['error'])

    def test_hardware_session_rejects_client_with_original_dri(self):
        good = '\n'.join((FIXED, ACCEPTED, SELECTED))
        code, state, clients = self.mock_hardware_session(
            good, client_driver_dir='vendor/usr/lib/x86_64-linux-gnu/dri')
        self.assertEqual((code, clients, state['passed']), (1, 1, False))
        self.assertFalse(state['private_client_dri_verified'])
        self.assertIn('Wayland DRI pair', state['error'])

    def test_dri_evidence_rejects_mixed_or_incomplete_client_libraries(self):
        stage = Path('/test')
        paths = [stage / 'desktop' / name for name in sorted(d.CLIENT_DRIVERS)]
        extra = stage / 'vendor/usr/lib/x86_64-linux-gnu/dri/mtgpu_dri.so'
        for seen, accepted in ((paths, True), (paths[:1], False), (paths + [extra], False)):
            text = '\n'.join('Graphics library: ' + str(path) for path in seen)
            self.assertEqual(d.client_compatibility_evidence(stage, text)['private_client_dri_verified'], accepted)

    def test_graphics_faults_are_retained_even_if_compositor_stays_alive(self):
        for line in ('kwin_wayland_drm: Atomic commit failed!', 'kwin_wayland_drm: Pageflip timed out',
                     'Modeset failed: Invalid argument', 'EGL_BAD_ALLOC', 'GL_CONTEXT_LOST',
                     'Failed to compile fragment shader:', 'Failed to compile vertex shader:',
                     'Failed to link shader:', 'Failed to load downsampling pass shader',
                     'Error creating EGLImageKHR: "EGL_BAD_PARAMETER"', REJECTED):
            self.assertEqual(d.compositor_faults(line),[line])
        self.assertEqual(d.compositor_faults('Could not determine the active graphical session'),[])

    def test_compositor_requires_hardware_renderer_physical_output_and_gles(self):
        self.assertEqual(d.validate_support(SUPPORT), 'MTT S30')
        for text in (SUPPORT.replace('MTT S30', 'llvmpipe'), SUPPORT.replace('Name: DRM', 'Name: KWin::VirtualBackend'),
                     SUPPORT.replace('Enabled: 1', 'Enabled: 0'), SUPPORT.replace('HDMI-A-1', 'Virtual-1'),
                     SUPPORT.replace('OpenGL ES', 'QPainter'), SUPPORT.replace('1920x1080', '0x0')):
            with self.subTest(text=text), self.assertRaises(RuntimeError):d.validate_support(text)

    def test_window_result_rejects_fallback_missing_feedback_and_pixel_corruption(self):
        result={'passed':True,'mode':'wayland-s30','frames':60,'pixels_checked':2949120,
                'mismatches':0,'discarded':0,'renderer':'MTT S30','presented':60,
                'hardware_presentations':60,'presentation_flags_all':7,'egl_vendor':'Mesa Project'}
        with tempfile.TemporaryDirectory() as tmp:
            p=Path(tmp)/'pixels';p.write_bytes(pixels(59));d.validate_egl(result,p,window=True)
            for change in ({'mode':'wayland-software'},{'renderer':'llvmpipe'}, {'presented':59},
                           {'hardware_presentations':0},{'presentation_flags_all':1},{'discarded':1},
                           {'frames':59},{'pixels_checked':1},{'egl_vendor':'MTT Mesa Client'}):
                with self.subTest(change=change),self.assertRaises(RuntimeError):d.validate_egl(result|change,p,window=True)
            data=bytearray(p.read_bytes());data[5]^=1;p.write_bytes(data)
            with self.assertRaises(RuntimeError):d.validate_egl(result,p,window=True)

    def test_env_is_private_and_cannot_inherit_user_session_or_software_overrides(self):
        with tempfile.TemporaryDirectory() as tmp:
            env=d.isolated_env(tmp,{'HOME':'/home/user','DISPLAY':':0','WAYLAND_DISPLAY':'wayland-0',
                        'DBUS_SESSION_BUS_ADDRESS':'user-bus','XDG_SESSION_ID':'user-session',
                        'LD_PRELOAD':'evil','LIBGL_ALWAYS_SOFTWARE':'1','KWIN_COMPOSE':'Q',
                        'QT_LOGGING_RULES':'*.warning=false;*.critical=false'},'/dev/dri/card0')
            for key in ('DISPLAY','WAYLAND_DISPLAY','DBUS_SESSION_BUS_ADDRESS','XDG_SESSION_ID','LD_PRELOAD','LIBGL_ALWAYS_SOFTWARE','KWIN_COMPOSE'):
                self.assertNotIn(key,env)
            self.assertEqual(env['KWIN_DRM_DEVICES'],'/dev/dri/card0')
            self.assertEqual(env['GBM_BACKEND'],'mtgpu')
            self.assertEqual(env['KWIN_DRM_NO_DIRECT_SCANOUT'],'1')
            self.assertEqual(env['QT_FORCE_STDERR_LOGGING'],'1')
            self.assertEqual(env['QT_LOGGING_RULES'], 'kwin_scene_opengl.info=true;kwin_wayland_drm.info=true')
            self.assertEqual(env['KWIN_DISABLE_UDMABUF_IMPORT'],'1')
            self.assertEqual(env['HOME'],str(Path(tmp)/'desktop-home'))
            with self.assertRaises(FileExistsError):d.isolated_env(tmp,{},'/dev/dri/card0')

    def test_only_native_wayland_client_switches_egl_vendor(self):
        with tempfile.TemporaryDirectory() as tmp:
            stage=Path(tmp)
            env=d.isolated_env(stage,{},'/dev/dri/card0')
            client=d.wayland_client_env(stage,env)
            self.assertIn('00_mtgpu.json',env['__EGL_VENDOR_LIBRARY_FILENAMES'])
            self.assertEqual(client['__EGL_VENDOR_LIBRARY_FILENAMES'],str(stage/'desktop/egl/50_mesa.json'))
            self.assertEqual(env['LIBGL_DRIVERS_PATH'],str(stage/'vendor/usr/lib/x86_64-linux-gnu/dri'))
            self.assertEqual(client['LIBGL_DRIVERS_PATH'],str(stage/'desktop/client-dri'))
            self.assertTrue(client['LD_LIBRARY_PATH'].startswith(str(stage/'desktop/egl')+':'))
            self.assertNotIn('GBM_BACKEND',client)
            self.assertNotIn('LIBGL_ALWAYS_SOFTWARE',client)
            self.assertNotIn('MESA_LOADER_DRIVER_OVERRIDE',client)
            self.assertNotIn('MTT_S30_WAYLAND_GLAPI',env)
            self.assertEqual(client['MTT_S30_WAYLAND_GLAPI'],str(stage/d.VENDOR_GLAPI))
            self.assertNotIn('MTT_S30_WAYLAND_GLAPI', d.wayland_client_env(stage,client,software=True))

    def test_missing_private_dependency_is_rejected_before_launch(self):
        with patch.object(d.subprocess,'check_output',return_value='libexample.so => not found\n'):
            with self.assertRaisesRegex(RuntimeError,'Missing private desktop dependency'):
                d.verify_runtime_dependencies('/tmp/private-stage')

    def test_dispatch_resolver_and_dri_must_open_same_reviewed_file(self):
        with tempfile.TemporaryDirectory() as tmp, patch.object(d.subprocess, 'check_output', return_value='resolved'):
            glapi = Path(tmp) / d.VENDOR_GLAPI
            glapi.parent.mkdir(parents=True)
            glapi.write_bytes((ROOT/'official/driver-3.1.0/usr/lib/x86_64-linux-gnu'/glapi.name).read_bytes())
            soname = glapi.with_name('libglapi_musa.so.0')
            soname.write_bytes(glapi.read_bytes())
            with self.assertRaisesRegex(RuntimeError, 'GLES dispatch library'):
                d.verify_runtime_dependencies(tmp)
            soname.unlink()
            soname.symlink_to(glapi.name)
            d.verify_runtime_dependencies(tmp)
            glapi.write_bytes(b'incorrect provider')
            with self.assertRaisesRegex(RuntimeError, 'GLES dispatch library'):
                d.verify_runtime_dependencies(tmp)

    def test_recorded_s30_shader_and_import_failures_are_not_lost(self):
        journal=ROOT/'maintenance/validation/runtime-20261031-191508/kwin-journal.log'
        faults=d.compositor_faults(journal.read_text())
        self.assertTrue(any('EGLImageKHR' in line for line in faults))
        self.assertTrue(any('compile fragment shader' in line for line in faults))
        self.assertTrue(any('downsampling' in line for line in faults))

    def test_bundle_rejects_tampering_and_symlinks(self):
        with tempfile.TemporaryDirectory() as tmp:
            out=Path(tmp)/'bundle';d.stage_bundle(ROOT/'builds'/d.BUNDLE_DIRECTORY,out)
            target=out/'egl-check';target.chmod(0o600);target.write_bytes(target.read_bytes()+b'x')
            with self.assertRaises(RuntimeError):d.verify_bundle(out)
            target.unlink();target.symlink_to(ROOT/'builds'/d.BUNDLE_DIRECTORY/'egl-check')
            with self.assertRaises(RuntimeError):d.verify_bundle(out)

    def test_private_library_corruption_and_directory_symlink_are_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            out=Path(tmp)/'bundle';d.stage_bundle(ROOT/'builds'/d.BUNDLE_DIRECTORY,out)
            lib=out/'egl/libEGL_mesa.so.0';lib.chmod(0o600)
            data=bytearray(lib.read_bytes());data[-1]^=1;lib.write_bytes(data)
            with self.assertRaisesRegex(RuntimeError,'checksum'):d.verify_bundle(out)
        with tempfile.TemporaryDirectory() as tmp:
            out=Path(tmp)/'bundle';d.stage_bundle(ROOT/'builds'/d.BUNDLE_DIRECTORY,out)
            (out/'kwin').rename(out/'kwin-real');(out/'kwin').symlink_to(out/'kwin-real')
            with self.assertRaisesRegex(RuntimeError,'library directory'):d.verify_bundle(out)

    def test_egl_failure_and_kernel_fault_stop_before_kwin(self):
        for failure in ('egl','kernel'):
            with self.subTest(failure=failure),tempfile.TemporaryDirectory() as tmp:
                stage=Path(tmp)
                result={'passed':True,'mode':'gbm-s30','frames':8,'pixels_checked':393216,
                        'mismatches':0,'discarded':0,'renderer':'MTT S30','presented':0}
                (stage/'egl-gbm.log').write_text(json.dumps(result)+'\n')
                (stage/'egl-gbm.rgba').write_bytes(pixels(7))
                command=Mock(return_value=1 if failure=='egl' else 0)
                kernel=Mock(side_effect=RuntimeError('GPU fault'))
                with patch.object(d,'verify_bundle'),patch.object(d,'isolated_env',return_value={}),self.assertRaises(RuntimeError):
                    d.run_desktop(stage,'/dev/dri/renderD128','/dev/dri/card0',{},command,kernel)
                self.assertEqual(command.call_count,1)
                self.assertEqual(command.call_args.args[0],'egl-gbm')

    def test_host_version_drift_is_rejected(self):
        variants = [d.REVIEWED_DESKTOP_PACKAGES | change for change in (
            {'kwin':'6.9.0-1'}, {'kwin':'6.8.1-2'}, {'mesa':'1:26.2.7-1'},
            {'qt6-base':'6.12.1-1'}, {'qt6-declarative':'6.12.1-1'}, {'kdecoration':'6.8.3-1'})]
        variants.append({k:v for k,v in d.REVIEWED_DESKTOP_PACKAGES.items() if k!='qt6-base'})
        for variant in variants:
            versions='\n'.join(k+' '+v for k,v in variant.items())+'\n'
            with self.subTest(versions=versions),patch.object(d.shutil,'which',return_value='/usr/bin/tool'), \
                 patch.object(d.subprocess,'check_output',return_value=versions):
                with self.assertRaisesRegex(RuntimeError,'Expected .*found'):d.verify_host()

    def test_reviewed_upgraded_stack_is_accepted(self):
        with patch.object(d.shutil,'which',return_value='/usr/bin/tool'), \
             patch.object(d.subprocess,'check_output',return_value='\n'.join(k+' '+v for k,v in d.REVIEWED_DESKTOP_PACKAGES.items())+'\n'):
            d.verify_host()


if __name__=='__main__':unittest.main()
