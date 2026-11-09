import importlib.util
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('next_boot', Path(__file__).with_name('inspect-next-boot.py'))
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)


class NextBoot(unittest.TestCase):
    def test_initramfs_requires_exact_target_without_mtgpu(self):
        good = 'usr/lib/modules/7.2.14-arch1-1/kernel/fs/ext4/ext4.ko.zst'
        self.assertEqual(m.check_initramfs(good, '7.2.14-arch1-1'), ['7.2.14-arch1-1'])
        for bad in ('', good.replace('7.2.14', '7.2.11'), good + '\nusr/lib/modules/old/kernel/a.ko',
                    good + '\nusr/lib/modules/7.2.14-arch1-1/extra/mtgpu.ko.zst'):
            with self.subTest(bad=bad), self.assertRaises(RuntimeError):
                m.check_initramfs(bad, '7.2.14-arch1-1')

    def test_boot_references_reject_missing_duplicate_and_escape(self):
        with tempfile.TemporaryDirectory() as temp:
            esp = Path(temp) / 'efi'
            esp.mkdir()
            for name in ('linux', 'initrd'):
                (esp / name).write_bytes(b'test')
            (esp.parent / 'outside').write_bytes(b'test')
            valid = 'linux /linux\ninitrd /initrd\noptions root=UUID=test rw\n'
            images, options = m.references(esp, valid)
            self.assertEqual(len(images), 2)
            self.assertIn('root=UUID=test', options)
            for bad in (valid.replace('/linux', '/missing'), valid + 'linux /linux\n',
                        valid.replace('/linux', '/../outside'), 'linux /linux\n'):
                with self.subTest(bad=bad), self.assertRaises(RuntimeError):
                    m.references(esp, bad)


if __name__ == '__main__':
    unittest.main()
