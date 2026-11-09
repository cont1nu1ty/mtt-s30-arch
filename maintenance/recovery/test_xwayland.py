"""No display/GPU access: authenticated endpoints and strict GLX acceptance."""
import copy
import json
import os
from pathlib import Path
import stat
import struct
import subprocess
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import Mock, patch

import xwayland_support as x

GOOD = {'passed': True, 'mode': 'xwayland-glx-s30', 'frames': 12, 'pixels_checked': 589824,
        'mismatches': 0, 'swapped': 12, 'direct': True, 'xwayland_extension': True,
        'desktop_opengl': True, 'gl_major': 4, 'gl_minor': 6, 'window_destroyed': True,
        'context_destroyed': True, 'display_closed': True, 'renderer': 'MTT S30',
        'dri3_extension': True, 'dri3_node': '/dev/dri/renderD128',
        'dri3_device_major': 226, 'dri3_device_minor': 128}


def pixels(frame=11):
    palette = (bytes((255,0,0,255)), bytes((0,255,0,255)),
               bytes((0,0,255,255)), bytes((255,255,255,255)))
    return b''.join(palette[(x//16 + 3*(y//16) + frame) % 4] for y in range(192) for x in range(256))


class Xwayland(unittest.TestCase):
    def test_endpoint_skips_existing_paths_and_occupied_abstract_sockets(self):
        with tempfile.TemporaryDirectory() as tmp:
            stage = Path(tmp); (stage / 'desktop-runtime').mkdir()
            occupied, available = Mock(), Mock()
            occupied.bind.side_effect = OSError('address in use')
            original = Path.exists

            def exists(path):
                if str(path) in ('/tmp/.X11-unix/X100', '/tmp/.X101-lock'):
                    return True
                return original(path)

            with patch.object(Path, 'exists', exists), patch.object(x.socket, 'socket', side_effect=[occupied, available]) as factory, \
                    patch.object(x.secrets, 'token_bytes', return_value=b'q' * 16):
                listener, display, auth = x.endpoint(stage)
            self.assertEqual(display, ':103')
            self.assertIs(listener, available)
            self.assertEqual(factory.call_count, 2)
            occupied.bind.assert_called_once_with('\0/tmp/.X11-unix/X102')
            occupied.close.assert_called_once()
            available.bind.assert_called_once_with('\0/tmp/.X11-unix/X103')
            available.listen.assert_called_once()
            p = Path(auth)
            self.assertEqual(p, stage / 'desktop-runtime/xauthority')
            self.assertEqual(stat.S_IMODE(p.stat().st_mode), 0o600)
            data = p.read_bytes(); self.assertEqual(struct.unpack('!H', data[:2])[0], 65535)
            data = data[2:]; fields = []
            while data:
                size = struct.unpack('!H', data[:2])[0]; fields.append(data[2:2+size]); data = data[2+size:]
            self.assertEqual(fields, [b'', b'103', b'MIT-MAGIC-COOKIE-1', b'q' * 16])

    def test_endpoint_does_not_overwrite_auth_or_remove_other_display_files(self):
        with tempfile.TemporaryDirectory() as tmp:
            stage = Path(tmp); (stage / 'desktop-runtime').mkdir()
            auth = stage / 'desktop-runtime/xauthority'; auth.write_bytes(b'existing')
            listener = Mock()
            with patch.object(x.socket, 'socket', return_value=listener), self.assertRaises(FileExistsError):
                x.endpoint(stage)
            self.assertEqual(auth.read_bytes(), b'existing')
            listener.close.assert_called_once()
        with patch.object(Path, 'exists', return_value=True), patch.object(x.socket, 'socket') as create, \
                self.assertRaisesRegex(RuntimeError, 'No unused'):
            x.endpoint('/never-created')
        create.assert_not_called()

    def test_hardware_glx_uses_vendor_and_removes_inherited_overrides(self):
        env = x.client_env('/stage', {'WAYLAND_DEBUG': 'client', 'MTT_S30_WAYLAND_GLAPI': '/old',
            'LIBGL_ALWAYS_INDIRECT': '1', 'LD_PRELOAD': '/bad', 'LIBGL_ALWAYS_SOFTWARE': '1',
            'MESA_LOADER_DRIVER_OVERRIDE': 'swrast', 'GALLIUM_DRIVER': 'softpipe',
            'LIBGL_DRIVERS_PATH': '/wrong', '__GLX_VENDOR_LIBRARY_NAME': 'mesa'}, ':105', '/stage/auth')
        self.assertEqual(env['DISPLAY'], ':105'); self.assertEqual(env['XAUTHORITY'], '/stage/auth')
        self.assertEqual(env['__GLX_VENDOR_LIBRARY_NAME'], 'mtgpu')
        self.assertEqual(env['LD_LIBRARY_PATH'], '/stage/vendor/usr/lib/x86_64-linux-gnu')
        self.assertEqual(env['LIBGL_DRIVERS_PATH'], '/stage/vendor/usr/lib/x86_64-linux-gnu/dri')
        for key in ('WAYLAND_DEBUG', 'MTT_S30_WAYLAND_GLAPI', 'LIBGL_ALWAYS_INDIRECT', 'LD_PRELOAD',
                    'LIBGL_ALWAYS_SOFTWARE', 'MESA_LOADER_DRIVER_OVERRIDE', 'GALLIUM_DRIVER'):
            self.assertNotIn(key, env)

    def test_software_glx_uses_system_mesa_not_inherited_vendor_dri(self):
        env = x.client_env('/stage', {'LD_LIBRARY_PATH': '/vendor', 'LIBGL_DRIVERS_PATH': '/vendor/dri',
                                     '__GLX_VENDOR_LIBRARY_NAME': 'mtgpu'}, ':105', '/stage/auth', software=True)
        self.assertEqual(env['__GLX_VENDOR_LIBRARY_NAME'], 'mesa')
        self.assertEqual(env['LIBGL_ALWAYS_SOFTWARE'], '1')
        self.assertNotIn('LIBGL_DRIVERS_PATH', env)
        self.assertNotIn('LD_LIBRARY_PATH', env)

    def test_hardware_result_requires_renderer_frames_cleanup_and_dri3_node(self):
        original = os.stat

        def device(path, *args, **kwargs):
            if str(path) == '/dev/dri/renderD128':
                return SimpleNamespace(st_mode=stat.S_IFCHR | 0o600, st_rdev=os.makedev(226, 128))
            return original(path, *args, **kwargs)

        with tempfile.TemporaryDirectory() as tmp, patch.object(x.os, 'stat', side_effect=device):
            p = Path(tmp) / 'pixels'; p.write_bytes(pixels())
            x.validate_result(GOOD, p)
            variants = [{'mode': 'xwayland-glx-software'}, {'renderer': 'llvmpipe'}, {'renderer': 'MTT S30 software'},
                        {'gl_major': 3, 'gl_minor': 2}, {'frames': 11}, {'swapped': 11}, {'pixels_checked': 1},
                        {'mismatches': 1}, {'dri3_node': '/dev/dri/card0'}, {'dri3_node': '/dev/dri/renderD129'}]
            variants += [{key: False} for key in ('passed', 'direct', 'xwayland_extension', 'desktop_opengl',
                                                 'window_destroyed', 'context_destroyed', 'display_closed', 'dri3_extension')]
            for change in variants:
                with self.subTest(change=change), self.assertRaises(RuntimeError):
                    x.validate_result(GOOD | change, p)
            p.write_bytes(pixels(10))
            with self.assertRaisesRegex(RuntimeError, 'pixels'):
                x.validate_result(GOOD, p)

    def test_software_acceptance_does_not_satisfy_hardware_gate(self):
        with tempfile.TemporaryDirectory() as tmp:
            p = Path(tmp) / 'pixels'; p.write_bytes(pixels())
            cpu = GOOD | {'mode': 'xwayland-glx-software', 'renderer': 'llvmpipe', 'dri3_extension': False,
                          'dri3_node': '', 'dri3_device_major': 0, 'dri3_device_minor': 0}
            x.validate_result(cpu, p, software=True)
            with self.assertRaises(RuntimeError): x.validate_result(cpu, p)
            with self.assertRaises(RuntimeError): x.validate_result(GOOD, p, software=True)

    def server(self, stage, args=None, parent=42, executable='/usr/bin/Xwayland', duplicate=False,
               maps=None, fds=('/dev/dri/renderD128',), log='MTT validation: Xwayland setup helper completed \"/usr/lib/plasma-setup-xwayland\" exitCode 0 normalExit true\n', software=False):
        """Supply a fake proc tree; no actual process or render node is touched."""
        proc = stage / 'proc'; proc.mkdir()
        auth = str(stage / 'auth')
        vendor = stage / 'vendor/usr/lib/x86_64-linux-gnu'
        defaults = [str(vendor / name) for name in ('libEGL_mtgpu.so.0.0.0', 'dri/mtgpu_dri.so', 'dri/musa_dri.so')]
        for pid in ([123, 124] if duplicate else [123]):
            entry = proc / str(pid); entry.mkdir(); (entry / 'fd').mkdir()
            (entry / 'status').write_text('PPid:\t' + str(parent) + '\n')
            (entry / 'exe').symlink_to(executable)
            command = args if args is not None else ['/usr/bin/Xwayland', ':100', '-auth', auth, '-rootless']
            (entry / 'cmdline').write_bytes(('\0'.join(command) + '\0').encode())
            (entry / 'maps').write_text('\n'.join(defaults if maps is None else maps))
            for i, target in enumerate(fds): (entry / 'fd' / str(i)).symlink_to(target)
        (stage / 'kwin.log').write_text(log)
        with patch.object(x, 'Path', side_effect=lambda value: proc if str(value) == '/proc' else Path(value)):
            return x.inspect_server(stage, 42, ':100', auth, software=software)

    def test_server_requires_exact_parent_executable_display_auth_and_single_process(self):
        with tempfile.TemporaryDirectory() as tmp:
            stage = Path(tmp)
            result = self.server(stage, software=True)
            self.assertEqual(result['pid'], 123)
            self.assertFalse(result['hardware_server_verified'])
        for change in ({'parent': 420}, {'executable': '/usr/bin/true'}, {'duplicate': True},
                       {'args': ['/usr/bin/Xwayland', ':101', '-auth', '/wrong']},
                       {'args': ['/usr/bin/Xwayland', ':101', '-auth', 'AUTH', '-unused', ':100']}):
            with self.subTest(change=change), tempfile.TemporaryDirectory() as tmp:
                stage = Path(tmp); arguments = copy.deepcopy(change)
                if 'args' in arguments: arguments['args'] = [str(stage / 'auth') if arg == 'AUTH' else arg for arg in arguments['args']]
                with self.assertRaises(RuntimeError): self.server(stage, software=True, **arguments)

    def test_server_rejects_other_uid_before_hardware_introspection(self):
        with tempfile.TemporaryDirectory() as tmp, patch.object(x.os, 'geteuid', return_value=os.geteuid() + 1), \
                self.assertRaisesRegex(RuntimeError, 'owner'):
            self.server(Path(tmp), software=True)

    def test_server_requires_successful_setup_helper_in_both_modes(self):
        for software in (False, True):
            for text in ('', x.SETUP_OK.replace('exitCode 0', 'exitCode 1'),
                         x.SETUP_OK.replace('normalExit true', 'normalExit false'),
                         x.SETUP_OK.replace('/usr/lib/plasma-setup-xwayland', '/unreviewed/helper'),
                         x.SETUP_OK + '\nMTT validation: Xwayland startup failed: helper timed out'):
                with self.subTest(software=software, text=text), tempfile.TemporaryDirectory() as tmp, \
                        self.assertRaisesRegex(RuntimeError, 'helper'):
                    self.server(Path(tmp), log=text, software=software)

    def test_server_hardware_rejects_mixed_driver_fallback_and_wrong_device(self):
        with tempfile.TemporaryDirectory() as tmp:
            result = self.server(Path(tmp))
            self.assertTrue(result['hardware_server_verified'])
            self.assertEqual(result['drm_fds'], ['/dev/dri/renderD128'])
        for case in ('missing', 'mixed', 'mesa_egl', 'software', 'wrong_node', 'fallback'):
            with self.subTest(case=case), tempfile.TemporaryDirectory() as tmp:
                stage = Path(tmp); vendor = stage / 'vendor/usr/lib/x86_64-linux-gnu'
                maps = [str(vendor / name) for name in ('libEGL_mtgpu.so.0.0.0', 'dri/mtgpu_dri.so', 'dri/musa_dri.so')]
                change = {}
                if case == 'missing': change['maps'] = maps[:-1]
                if case == 'mixed': change['maps'] = maps + ['/other/mtgpu_dri.so']
                if case == 'mesa_egl': change['maps'] = maps + ['/usr/lib/libEGL_mesa.so.0']
                if case == 'software': change['maps'] = maps + ['/usr/lib/dri/swrast_dri.so']
                if case == 'wrong_node': change['fds'] = ('/dev/dri/renderD129',)
                if case == 'fallback': change['log'] = 'Failed to initialize glamor, falling back to sw\n'
                with self.assertRaises(RuntimeError): self.server(stage, **change)

    def run_client(self, stage, change=None, code=0, extra_library=None):
        vendor = stage / 'vendor/usr/lib/x86_64-linux-gnu'
        libraries = [vendor / name for name in ('libGLX_mtgpu.so.0.0.0', 'dri/mtgpu_dri.so', 'dri/musa_dri.so')]
        if extra_library: libraries.append(stage / extra_library)
        for path in libraries:
            path.parent.mkdir(parents=True, exist_ok=True); path.write_bytes(b'fixture')
        original = os.stat

        def device(path, *args, **kwargs):
            if str(path) == '/dev/dri/renderD128':
                return SimpleNamespace(st_mode=stat.S_IFCHR | 0o600, st_rdev=os.makedev(226, 128))
            return original(path, *args, **kwargs)

        def process(args, **kwargs):
            kwargs['stdout'].write('\n'.join('Graphics library: ' + str(p) for p in libraries) + '\n')
            kwargs['stdout'].write(json.dumps(GOOD | (change or {})) + '\n'); kwargs['stdout'].flush()
            (stage / 'x11.rgba').write_bytes(pixels())
            return subprocess.CompletedProcess(args, code)

        with patch.object(x.subprocess, 'run', side_effect=process), \
                patch.object(x, 'inspect_server', return_value={'hardware_server_verified': True}), \
                patch.object(x.os, 'stat', side_effect=device):
            return x.run(stage, {}, 42, ':100', str(stage / 'auth'))

    def test_run_requires_device_rdev_and_exclusive_glx_driver_and_normal_exit(self):
        with tempfile.TemporaryDirectory() as tmp:
            stage = Path(tmp); result = self.run_client(stage)
            self.assertTrue(result['passed']); self.assertEqual(result['client_exit'], 0)
        variants = [{'change': {'dri3_device_major': 1}}, {'change': {'dri3_device_minor': 129}},
                    {'code': -6}, {'code': -11}, {'code': 2},
                    {'extra_library': 'other/mtgpu_dri.so'}, {'extra_library': 'other/libGLX_mesa.so.0'}]
        for changes in variants:
            with self.subTest(changes=changes), tempfile.TemporaryDirectory() as tmp:
                stage = Path(tmp)
                with self.assertRaises(RuntimeError): self.run_client(stage, **changes)
                result = json.loads((stage / 'xwayland-result.json').read_text())
                self.assertFalse(result['passed']); self.assertIn('error', result)


if __name__ == '__main__':
    unittest.main()
