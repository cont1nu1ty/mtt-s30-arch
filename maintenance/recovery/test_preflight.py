import importlib.util,pathlib,tempfile,unittest
p=pathlib.Path(__file__).with_name('prepare-recovery.py')
spec=importlib.util.spec_from_file_location('preflight',p);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
class BootReferences(unittest.TestCase):
 def test_valid_kernel_and_initrd(self):
  with tempfile.TemporaryDirectory() as d:
   root=pathlib.Path(d);(root/'vmlinuz').write_bytes(b'kernel');(root/'initrd').write_bytes(b'initrd')
   entry=root/'entry.conf';entry.write_text('title known-good\nlinux /vmlinuz\ninitrd /initrd\noptions root=UUID=example rw\n')
   self.assertEqual(m.entry_images(root,entry),[root/'vmlinuz',root/'initrd'])
 def test_missing_kernel_stops(self):
  with tempfile.TemporaryDirectory() as d:
   root=pathlib.Path(d);entry=root/'entry.conf';entry.write_text('linux /missing\n')
   with self.assertRaises(RuntimeError):m.entry_images(root,entry)
 def test_traversal_stops(self):
  with tempfile.TemporaryDirectory() as d:
   root=pathlib.Path(d)/'efi';root.mkdir();(root.parent/'outside').write_bytes(b'kernel')
   entry=root/'entry.conf';entry.write_text('linux /../outside\n')
   with self.assertRaises(RuntimeError):m.entry_images(root,entry)
 def test_empty_entry_stops(self):
  with tempfile.TemporaryDirectory() as d:
   root=pathlib.Path(d);entry=root/'entry.conf';entry.write_text('title no-image\n')
   with self.assertRaises(RuntimeError):m.entry_images(root,entry)
if __name__=='__main__':unittest.main()
