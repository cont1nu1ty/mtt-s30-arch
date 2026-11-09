"""Host-safe workload verdict, tampering and sequencing tests. No GPU access."""
import hashlib
import json
from pathlib import Path
import shutil
import tempfile
import unittest
from unittest.mock import patch

import workload_support as w

RENDER = {'passed': True, 'mode': 's30', 'frames': 8,
          'pixels_checked': 98304, 'mismatches': 0}
VIDEO = {'passed': True, 'mode': 'vaapi', 'frames': 48, 'hardware_frames': 48,
         'bad_frames': 0, 'different_bytes': 0, 'max_abs_error': 0}


def pixels():
    colors = [(255, 0, 0, 255), (0, 255, 0, 255), (0, 0, 255, 255), (255, 255, 255, 255)]
    return bytes(c for y in range(96) for x in range(128)
                 for c in colors[(x // 16 + 3 * (y // 16) + 7) % 4])


def bundle(directory):
    directory.mkdir()
    for name in w.FILES:
        (directory / name).write_bytes(b'\x5a' * w.VIDEO_BYTES if name == 'reference.nv12' else b'fixture')
    manifest = {'profile': w.PROFILE, 'files': {name: {
        'size': (directory / name).stat().st_size, 'sha256': w.digest(directory / name)} for name in w.FILES}}
    (directory / 'manifest.json').write_text(json.dumps(manifest))
    return w.digest(directory / 'manifest.json')


class Workloads(unittest.TestCase):
    def test_render_rejects_software_partial_and_corrupt_results(self):
        image = pixels()
        w.verify_render(RENDER, image)
        for key, value in [('mode', 'software-validation'), ('frames', 7),
                           ('pixels_checked', 0), ('passed', False)]:
            with self.subTest(key=key), self.assertRaises(RuntimeError):
                w.verify_render({**RENDER, key: value}, image)
        for corrupt in [image[:-1], bytes([image[0] ^ 1]) + image[1:]]:
            with self.assertRaises(RuntimeError):
                w.verify_render(RENDER, corrupt)

    def test_video_rejects_software_missing_frames_and_single_byte_difference(self):
        with tempfile.TemporaryDirectory() as d:
            d = Path(d); reference = d / 'ref'; actual = d / 'actual'
            reference.write_bytes(b'\x5a' * w.VIDEO_BYTES);shutil.copyfile(reference,actual)
            w.verify_video(VIDEO,actual,reference)
            for key, value in [('mode','software-check'),('hardware_frames',47),('frames',47),('passed',False)]:
                with self.subTest(key=key), self.assertRaises(RuntimeError):
                    w.verify_video({**VIDEO,key:value},actual,reference)
            with actual.open('r+b') as f:f.write(b'\x5b')
            with self.assertRaises(RuntimeError):w.verify_video(VIDEO,actual,reference)
            actual.write_bytes(b'\x5a')
            with self.assertRaises(RuntimeError):w.verify_video(VIDEO,actual,reference)

    def test_bundle_rejects_changes_and_symlinks(self):
        with tempfile.TemporaryDirectory() as d:
            src=Path(d)/'src';sha=bundle(src);w.verify_bundle(src,sha)
            with self.assertRaises(RuntimeError):w.verify_bundle(src,'0'*64)
            p=src/'clip.h264';p.write_bytes(b'changed')
            with self.assertRaises(RuntimeError):w.verify_bundle(src,sha)
            p.unlink();p.symlink_to(src/'h264-check')
            with self.assertRaises(RuntimeError):w.verify_bundle(src,sha)

    def test_staging_rechecks_copied_bytes_and_refuses_overwrite(self):
        with tempfile.TemporaryDirectory() as d:
            src=Path(d)/'src';dest=Path(d)/'dest';sha=bundle(src)
            w.stage_bundle(src,dest,sha);w.verify_bundle(dest,sha)
            with self.assertRaises(FileExistsError):w.stage_bundle(src,dest,sha)
            original=shutil.copyfile
            def copy(a,b):
                original(a,b)
                if Path(b).name=='clip.h264':Path(b).write_bytes(b'corruption')
            with patch.object(w.shutil,'copyfile',side_effect=copy), self.assertRaises(RuntimeError):
                w.stage_bundle(src,Path(d)/'corrupt',sha)

    def test_command_failure_or_kernel_fault_never_reaches_next_gpu_call(self):
        for failure in ['render','pixels','kernel','video',None]:
            with self.subTest(failure=failure), tempfile.TemporaryDirectory() as d:
                stage=Path(d);sha=bundle(stage/'workloads');events=[]
                def command(name,args,timeout,env):
                    events.append(name)
                    self.assertEqual(timeout,30)
                    self.assertNotIn('--software-validation',args)
                    self.assertNotIn('--software-check',args)
                    if name=='render-workload':
                        (stage/(name+'.log')).write_text(json.dumps(RENDER)+'\n')
                        (stage/'render.rgba').write_bytes(b'bad' if failure=='pixels' else pixels())
                        return int(failure=='render')
                    (stage/(name+'.log')).write_text(json.dumps(VIDEO)+'\n')
                    shutil.copyfile(stage/'workloads/reference.nv12',stage/'decoded.nv12')
                    return int(failure=='video')
                def kernel():
                    events.append('kernel')
                    if failure=='kernel':raise RuntimeError('kernel fault')
                if failure:
                    with self.assertRaises(RuntimeError):
                        w.run_workloads(stage,'/dev/dri/renderD128',{},command,kernel,sha)
                    self.assertFalse((stage/'workload-result.json').exists())
                    if failure in ('render','pixels','kernel'):
                        self.assertNotIn('video-workload',events)
                else:
                    result=w.run_workloads(stage,'/dev/dri/renderD128',{},command,kernel,sha)
                    self.assertTrue(result['passed'])
                    self.assertEqual(events,['render-workload','kernel','video-workload','kernel'])

    def test_manifest_failure_prevents_any_workload_execution(self):
        with tempfile.TemporaryDirectory() as d:
            stage=Path(d);sha=bundle(stage/'workloads')
            (stage/'workloads/vk-offscreen').write_bytes(b'changed')
            with patch.object(w,'verify_render') as verify, self.assertRaises(RuntimeError):
                w.run_workloads(stage,'/dev/dri/renderD128',{},lambda *a:self.fail('executed'),lambda:None,sha)
            verify.assert_not_called()


if __name__ == '__main__':
    unittest.main()
