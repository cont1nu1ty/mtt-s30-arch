"""Real disposable process trees; no display, GPU or system service is used."""
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import tempfile
import unittest

import session_process as sessions


CHILD = '''import signal,time
signal.signal(signal.SIGTERM, signal.SIG_IGN)
time.sleep(30)
'''


class PrivateSessionProcesses(unittest.TestCase):
    def tree(self, mode):
        with tempfile.TemporaryDirectory() as temporary:
            record = Path(temporary) / 'pids.json'
            program = '''import json,os,subprocess,sys,time
from pathlib import Path
child=subprocess.Popen([sys.executable,'-c',sys.argv[2]])
Path(sys.argv[1]).write_text(json.dumps({'leader':os.getpid(),'child':child.pid,'group':os.getpgrp()}))
if sys.argv[3]=='wait':time.sleep(30)
elif sys.argv[3]=='join':child.terminate();child.wait()
'''
            child_code = CHILD if mode != 'join' else 'import time; time.sleep(30)'
            command = [sys.executable, '-c', program, str(record), child_code, mode]
            try:
                with open(os.devnull, 'w') as output:
                    if mode == 'wait':
                        with self.assertRaises(subprocess.TimeoutExpired):
                            sessions.run_session(command, timeout=0.7, stdout=output, stderr=output)
                    elif mode == 'leave':
                        with self.assertRaisesRegex(RuntimeError, 'left live child'):
                            sessions.run_session(command, timeout=3, stdout=output, stderr=output)
                    else:
                        result = sessions.run_session(command, timeout=3, stdout=output, stderr=output)
                        self.assertEqual(result.returncode, 0)
                pids = json.loads(record.read_text())
                self.assertEqual(pids['group'], pids['leader'])
                self.assertNotEqual(pids['group'], os.getpgrp())
                self.assertEqual(sessions.live_group_members(pids['group']), [])
                self.assertEqual(os.getpgid(os.getpid()), os.getpgrp())
            finally:
                if record.exists():
                    pids = json.loads(record.read_text())
                    if pids['group'] != os.getpgrp():
                        try: os.killpg(pids['group'], signal.SIGKILL)
                        except ProcessLookupError: pass

    def test_timeout_kills_term_resistant_descendant_and_preserves_timeout(self):
        self.tree('wait')

    def test_zero_exit_with_living_descendant_is_rejected_and_cleaned(self):
        self.tree('leave')

    def test_normal_joined_child_is_accepted(self):
        self.tree('join')

    def test_interrupt_cleans_descendants_before_reraising(self):
        with tempfile.TemporaryDirectory() as temporary:
            record = Path(temporary) / 'pids.json'
            program = ("import json,os,subprocess,sys,time; from pathlib import Path; "
                       "child=subprocess.Popen([sys.executable,'-c',sys.argv[2]]); "
                       "Path(sys.argv[1]).write_text(json.dumps({'group':os.getpgrp()})); "
                       "time.sleep(30)")

            def interrupted(signum, frame):
                raise InterruptedError('controlled interruption')

            previous = signal.signal(signal.SIGALRM, interrupted)
            try:
                signal.setitimer(signal.ITIMER_REAL, 0.7)
                with self.assertRaisesRegex(InterruptedError, 'controlled interruption'):
                    sessions.run_session([sys.executable, '-c', program, str(record), CHILD], timeout=10)
                group = json.loads(record.read_text())['group']
                self.assertEqual(sessions.live_group_members(group), [])
            finally:
                signal.setitimer(signal.ITIMER_REAL, 0)
                signal.signal(signal.SIGALRM, previous)
                if record.exists():
                    group = json.loads(record.read_text())['group']
                    if group != os.getpgrp():
                        try: os.killpg(group, signal.SIGKILL)
                        except ProcessLookupError: pass

    def test_clean_failure_code_is_not_rewritten_as_success(self):
        result = sessions.run_session([sys.executable, '-c', 'raise SystemExit(7)'], timeout=3)
        self.assertEqual(result.returncode, 7)


if __name__ == '__main__':
    unittest.main()
