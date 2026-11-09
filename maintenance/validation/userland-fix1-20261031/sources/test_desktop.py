"""No device access: reject wrong GPUs, virtual outputs, corrupt frames, leaks."""
import json
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
Compositing is active
Compositing Type: OpenGL ES
OpenGL vendor string: Moore Threads
OpenGL renderer string: MTT S30
OpenGL platform interface: EGL
'''


class Desktop(unittest.TestCase):
    def test_graphics_faults_are_retained_even_if_compositor_stays_alive(self):
        for line in ('kwin_wayland_drm: Atomic commit failed!', 'kwin_wayland_drm: Pageflip timed out',
                     'Modeset failed: Invalid argument', 'EGL_BAD_ALLOC', 'GL_CONTEXT_LOST',
                     'Failed to compile fragment shader:', 'Failed to compile vertex shader:',
                     'Failed to link shader:', 'Failed to load downsampling pass shader',
                     'Error creating EGLImageKHR: "EGL_BAD_PARAMETER"'):
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
                        'LD_PRELOAD':'evil','LIBGL_ALWAYS_SOFTWARE':'1','KWIN_COMPOSE':'Q'},'/dev/dri/card0')
            for key in ('DISPLAY','WAYLAND_DISPLAY','DBUS_SESSION_BUS_ADDRESS','XDG_SESSION_ID','LD_PRELOAD','LIBGL_ALWAYS_SOFTWARE','KWIN_COMPOSE'):
                self.assertNotIn(key,env)
            self.assertEqual(env['KWIN_DRM_DEVICES'],'/dev/dri/card0')
            self.assertEqual(env['GBM_BACKEND'],'mtgpu')
            self.assertEqual(env['KWIN_DRM_NO_DIRECT_SCANOUT'],'1')
            self.assertEqual(env['QT_FORCE_STDERR_LOGGING'],'1')
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
            self.assertEqual(client['LIBGL_DRIVERS_PATH'],env['LIBGL_DRIVERS_PATH'])
            self.assertTrue(client['LD_LIBRARY_PATH'].startswith(str(stage/'desktop/egl')+':'))
            self.assertNotIn('GBM_BACKEND',client)
            self.assertNotIn('LIBGL_ALWAYS_SOFTWARE',client)
            self.assertNotIn('MESA_LOADER_DRIVER_OVERRIDE',client)

    def test_missing_private_dependency_is_rejected_before_launch(self):
        with patch.object(d.subprocess,'check_output',return_value='libexample.so => not found\n'):
            with self.assertRaisesRegex(RuntimeError,'Missing private desktop dependency'):
                d.verify_runtime_dependencies('/tmp/private-stage')

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
