"""Failure boundaries for the bounded private Plasma workspace check."""
import copy
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import plasma_support as p

STAGE = Path('/private-stage')
GRAPHICS = '''qt.rhi.general: OpenGL VENDOR: MOORE THREADS RENDERER: MTT S30 VERSION: 4.6 vendor
 -> zwp_linux_buffer_params_v1#81.create_immed(new id wl_buffer#91, 800, 600, 875713112, 0)
 -> zwp_linux_buffer_params_v1#82.create_immed(new id wl_buffer#92, 800, 44, 875713112, 0)
 -> zwlr_layer_shell_v1#52.get_layer_surface(new id zwlr_layer_surface_v1#54, wl_surface#48, wl_output#25, 0, "desktop")
 -> wl_surface#48.attach(wl_buffer#91, 0, 0)
 -> wl_surface#48.commit()
 -> zwlr_layer_shell_v1#52.get_layer_surface(new id zwlr_layer_surface_v1#130, wl_surface#79, wl_output#25, 2, "dock")
 -> wl_surface#79.attach(wl_buffer#92, 0, 0)
 -> wl_surface#79.commit()
'''
MAPS = '\n'.join(str(STAGE / path) for path in ('desktop/egl/libEGL_mesa.so.0',
                                               'desktop/client-dri/mtgpu_dri.so',
                                               'desktop/client-dri/musa_dri.so'))
LAYOUT = {'desktops': [{'id': 1, 'type': 'org.kde.plasma.folder', 'screen': 0}],
          'panels': [{'id': 2, 'type': 'org.kde.panel', 'screen': 0, 'height': 44,
                      'widgets': ['org.kde.plasma.kickoff', 'org.kde.plasma.icontasks',
                                  'org.kde.plasma.systemtray', 'org.kde.plasma.digitalclock']}]}


class Plasma(unittest.TestCase):
    def private_environment(self, stage):
        env = {key: str(stage / directory) for key, directory in {
            'HOME': 'desktop-home', 'XDG_CONFIG_HOME': 'desktop-config', 'XDG_DATA_HOME': 'desktop-data',
            'XDG_CACHE_HOME': 'desktop-cache', 'XDG_STATE_HOME': 'desktop-state',
            'XDG_RUNTIME_DIR': 'desktop-runtime'}.items()}
        env.update(WAYLAND_DISPLAY='mtt-s30-test', DBUS_SESSION_BUS_ADDRESS='unix:path=/private/bus')
        return env

    def test_authenticated_private_xwayland_metadata_allows_only_matching_endpoint(self):
        with tempfile.TemporaryDirectory() as tmp:
            stage = Path(tmp); env = self.private_environment(stage)
            auth = str(stage / 'desktop-runtime/xauthority')
            record = stage / 'private-xwayland.json'
            with patch.dict(os.environ, env, clear=True):
                for display in (':100', ':199'):
                    record.write_text(json.dumps({'display': display, 'xauthority': auth}))
                    record.chmod(0o600)
                    p.validate_environment(stage, env | {'DISPLAY': display, 'XAUTHORITY': auth})
                for change in ({'DISPLAY': ':0', 'XAUTHORITY': auth},
                               {'DISPLAY': ':198', 'XAUTHORITY': auth},
                               {'DISPLAY': ':199', 'XAUTHORITY': '/home/real/.Xauthority'},
                               {'DISPLAY': ':199'}, {'XAUTHORITY': auth}):
                    with self.subTest(change=change), self.assertRaises(RuntimeError):
                        p.validate_environment(stage, env | change)

    def test_private_xwayland_record_rejects_unsafe_metadata_and_identity(self):
        with tempfile.TemporaryDirectory() as tmp:
            stage = Path(tmp); env = self.private_environment(stage)
            auth = str(stage / 'desktop-runtime/xauthority')
            endpoint = {'display': ':100', 'xauthority': auth}
            record = stage / 'private-xwayland.json'
            client = env | {'DISPLAY': ':100', 'XAUTHORITY': auth}
            with patch.dict(os.environ, env, clear=True):
                with self.assertRaisesRegex(RuntimeError, 'record missing or unsafe'):
                    p.validate_environment(stage, client)
                for value in ({}, endpoint | {'display': ':99'}, endpoint | {'display': ':200'},
                              endpoint | {'display': 'localhost:100'},
                              endpoint | {'xauthority': '/home/real/.Xauthority'}):
                    record.write_text(json.dumps(value)); record.chmod(0o600)
                    with self.subTest(value=value), self.assertRaises(RuntimeError):
                        p.validate_environment(stage, client)
                record.write_text(json.dumps(endpoint)); record.chmod(0o644)
                with self.assertRaisesRegex(RuntimeError, 'unsafe'):
                    p.validate_environment(stage, client)
                record.chmod(0o600)
                with patch.object(p.os, 'geteuid', return_value=os.geteuid() + 1), self.assertRaisesRegex(RuntimeError, 'unsafe'):
                    p.validate_environment(stage, client)
                record.rename(stage / 'actual'); record.symlink_to(stage / 'actual')
                with self.assertRaisesRegex(RuntimeError, 'unsafe'):
                    p.validate_environment(stage, client)
                record.unlink();record.write_text(' ' * 4096);record.chmod(0o600)
                with self.assertRaisesRegex(RuntimeError, 'unsafe'):
                    p.validate_environment(stage, client)

    def test_empty_or_partial_shell_is_not_desktop_acceptance(self):
        p.validate_snapshot(LAYOUT)
        variants = [dict(LAYOUT, desktops=[]), dict(LAYOUT, panels=[])]
        for field, value in [('widgets', ['org.kde.plasma.digitalclock']), ('screen', -1),
                             ('height', 0), ('type', 'org.kde.fake')]:
            data = copy.deepcopy(LAYOUT); data['panels'][0][field] = value; variants.append(data)
        for data in variants:
            with self.subTest(data=data), self.assertRaises(RuntimeError):
                p.validate_snapshot(data)

    def test_real_opengl_and_exact_private_driver_pair_are_required(self):
        result = p.graphics_evidence(GRAPHICS, MAPS, STAGE)
        self.assertEqual(result['layer_buffer_submissions'], {'desktop': 1, 'dock': 1})
        for text in (GRAPHICS.replace('MTT S30', 'llvmpipe'), GRAPHICS.replace('4.6 vendor', 'OpenGL ES 3.2'),
                     GRAPHICS.replace('4.6 vendor', '3.0 vendor'), GRAPHICS + 'GL_CONTEXT_LOST\n',
                     GRAPHICS.replace('qt.rhi.general: OpenGL', 'unobserved OpenGL')):
            with self.subTest(text=text), self.assertRaises(RuntimeError):
                p.graphics_evidence(text, MAPS, STAGE)
        for maps in (MAPS.replace('desktop/client-dri', 'vendor/dri'),
                     MAPS + '\n/other/mtgpu_dri.so', MAPS.replace('desktop/egl', 'system/egl')):
            with self.subTest(maps=maps), self.assertRaises(RuntimeError):
                p.graphics_evidence(GRAPHICS, maps, STAGE)

    def test_layer_registration_without_drawn_panel_is_rejected(self):
        for text in (GRAPHICS.replace('wl_surface#79.attach', 'wl_surface#50.attach'),
                     GRAPHICS.replace('wl_surface#48.commit', 'wl_surface#50.commit'),
                     GRAPHICS.replace('"dock"', '"popup"'),
                     GRAPHICS.replace('zwp_linux_buffer_params_v1', 'wl_shm')):
            with self.subTest(text=text), self.assertRaises(RuntimeError):
                p.graphics_evidence(text, MAPS, STAGE)

    def test_software_control_cannot_be_claimed_as_s30(self):
        cpu = GRAPHICS.replace('MTT S30', 'softpipe')
        p.graphics_evidence(cpu, MAPS, STAGE, software=True)
        with self.assertRaises(RuntimeError):
            p.graphics_evidence(cpu, MAPS, STAGE)
        with self.assertRaises(RuntimeError):
            p.graphics_evidence(GRAPHICS, MAPS, STAGE, software=True)

    def test_parent_session_environment_and_activation_are_rejected_before_launch(self):
        with tempfile.TemporaryDirectory() as tmp:
            stage = Path(tmp)
            env = {key: str(stage / directory) for key, directory in {
                'HOME': 'desktop-home', 'XDG_CONFIG_HOME': 'desktop-config', 'XDG_DATA_HOME': 'desktop-data',
                'XDG_CACHE_HOME': 'desktop-cache', 'XDG_STATE_HOME': 'desktop-state',
                'XDG_RUNTIME_DIR': 'desktop-runtime'}.items()}
            env.update(WAYLAND_DISPLAY='mtt-s30-test', DBUS_SESSION_BUS_ADDRESS='unix:path=/private/bus')
            with patch.dict(os.environ, env, clear=True):
                p.validate_environment(stage, env)
                for change in ({'HOME': '/home/real'}, {'DBUS_SESSION_BUS_ADDRESS': 'unix:path=/run/user/1000/bus'},
                               {'WAYLAND_DISPLAY': 'wayland-0'}, {'DISPLAY': ':0'}, {'LD_PRELOAD': '/wrong.so'}):
                    with self.subTest(change=change), self.assertRaises(RuntimeError):
                        p.validate_environment(stage, env | change)
                with patch.object(p.subprocess, 'check_output', return_value='org.freedesktop.DBus\norg.freedesktop.systemd1'), \
                        patch.object(p.subprocess, 'Popen') as launch, self.assertRaisesRegex(RuntimeError, 'automatic activation'):
                    p.run(stage, env, software=True)
                launch.assert_not_called()
                record = json.loads((stage / 'plasma-result.json').read_text())
                self.assertFalse(record['passed'])
                self.assertFalse(record['forced_kill'])


if __name__ == '__main__':
    unittest.main()
