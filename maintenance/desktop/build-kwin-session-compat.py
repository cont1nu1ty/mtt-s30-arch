#!/usr/bin/env python3
"""Build the private Arch Xwayland startup correction, restoring the v11 tree.

The reviewed build tree is snapshotted before same-path incremental compilation.
No installed file or old bundle is replaced. Interrupted builds retain snapshots
under --work, and the finally block restores and hashes the original trees.
"""
import argparse
import difflib
import hashlib
import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'maintenance/recovery'))
from session_process import run_session

BASE = ROOT / 'work/kwin-import-table-final-20261104'
SOURCE_SHA = 'b546d29d64010c6c3ac5826886cb9074be6662e1bcef67ec41976abb2827ec30'
EXPECTED = {'kwin_wayland': 'f3d11822f04a3d81ab1bda8aaf79ee362c72faa707f91619089b0ec62c7aca12',
            'libkwin.so.6.8.2': '70f2110f553b260311d24ded8f287c262e60700eb8ba146b5f949c47eaedd5f0'}

REPLACEMENT = '''void Xwayland::runXWaylandStartupScripts()
{
    // This private validation build must never enumerate the installed
    // session scripts (at-spi, input method, user-manager integrations).
    const QString privateScripts = qEnvironmentVariable("MTT_S30_XWAYLAND_STARTUP_DIR");
    const QFileInfo privateInfo(privateScripts);
    const QDir scriptDir(privateScripts);
    if (!QDir::isAbsolutePath(privateScripts) || !privateInfo.isDir() || privateInfo.isSymLink()
        || !scriptDir.entryList(QDir::AllEntries | QDir::Hidden | QDir::System | QDir::NoDotAndDotDot).isEmpty()) {
        qCCritical(KWIN_XWL) << "MTT validation: Xwayland startup failed: private empty script directory required";
        QCoreApplication::exit(1);
        return;
    }

    const QString helper = QString(LIBEXEC_DIR) + QStringLiteral("/plasma-setup-xwayland");
    if (helper != QStringLiteral("/usr/lib/plasma-setup-xwayland")) {
        qCCritical(KWIN_XWL) << "MTT validation: Xwayland startup failed: wrong Arch helper path" << helper;
        QCoreApplication::exit(1);
        return;
    }
    qCInfo(KWIN_XWL) << "MTT validation: Xwayland startup directory" << privateScripts
                    << "systemScriptsSkipped true helper" << helper;
    QProcessEnvironment setupEnv = kwinApp()->processStartupEnvironment();
    setupEnv.insert("DISPLAY", m_launcher->initDisplayName());
    auto *process = new QProcess(this);
    process->setProcessEnvironment(setupEnv);
    connect(process, &QProcess::finished, this, [this, process, helper](int code, QProcess::ExitStatus status) {
        qCInfo(KWIN_XWL) << "MTT validation: Xwayland setup helper completed" << helper
                        << "exitCode" << code << "normalExit" << (status == QProcess::NormalExit);
        if (code == 0 && status == QProcess::NormalExit) {
            registerReady();
        } else {
            qCCritical(KWIN_XWL) << "MTT validation: Xwayland startup failed: helper did not finish normally";
            QCoreApplication::exit(1);
        }
        process->deleteLater();
    });
    connect(process, &QProcess::errorOccurred, this, [process, helper](QProcess::ProcessError error) {
        qCCritical(KWIN_XWL) << "MTT validation: Xwayland startup failed: helper error" << helper << error;
        QCoreApplication::exit(1);
        process->deleteLater();
    });
    QTimer::singleShot(5000, process, [process]() {
        if (process->state() != QProcess::NotRunning) {
            qCCritical(KWIN_XWL) << "MTT validation: Xwayland startup failed: helper timed out";
            process->kill();
            QCoreApplication::exit(1);
        }
    });
    process->start(helper);
}
'''


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def tree_state(directory):
    return {str(p.relative_to(directory)): ('symlink:' + os.readlink(p) if p.is_symlink() else sha(p))
            for p in sorted(directory.rglob('*')) if p.is_file() or p.is_symlink()}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--work', type=Path, required=True)
    parser.add_argument('--jobs', type=int, default=8)
    args = parser.parse_args()
    work = args.work.resolve()
    if args.jobs < 1 or work.exists():
        raise ValueError('Use a new work directory and positive jobs.')
    source, build = BASE / 'kwin-6.8.2', BASE / 'kwin-build'
    original_cpp = source / 'src/xwayland/xwayland.cpp'
    if sha(original_cpp) != SOURCE_SHA:
        raise ValueError('Unreviewed Xwayland source.')
    for name, expected in EXPECTED.items():
        if sha(build / 'bin' / name) != expected:
            raise ValueError('The original KWin tree no longer matches v11: ' + name)
    work.mkdir(parents=True)
    before = {name: tree_state(BASE / name) for name in ('kwin-6.8.2', 'kwin-build')}
    (work / 'original-tree-sha256.json').write_text(json.dumps(before, indent=2) + '\n')
    snapshots = work / 'original-snapshots'
    snapshots.mkdir()
    for name in before:
        subprocess.run(['cp', '-a', '--reflink=auto', str(BASE / name), str(snapshots / name)], check=True)
        if tree_state(snapshots / name) != before[name]:
            raise RuntimeError('Snapshot mismatch: ' + name)
    original = original_cpp.read_text()
    start = original.index('void Xwayland::runXWaylandStartupScripts()\n')
    end = original.index('\nbool Xwayland::dragMoveFilter', start)
    modified = original[:start] + REPLACEMENT + original[end:]
    modified = modified.replace('#include <QDataStream>\n', '#include <QDataStream>\n#include <QCoreApplication>\n#include <QFileInfo>\n')
    patch = ''.join(difflib.unified_diff(original.splitlines(True), modified.splitlines(True),
                                        fromfile='a/src/xwayland/xwayland.cpp', tofile='b/src/xwayland/xwayland.cpp'))
    (work / 'kwin-private-xwayland-startup.patch').write_text(patch)
    shutil.copyfile(__file__, work / Path(__file__).name)
    report = {'base_source_sha256': SOURCE_SHA, 'old_binaries': EXPECTED, 'built': False,
              'system_files_changed': False, 'old_trees_restored': False}

    def interrupted(signum, frame):
        raise InterruptedError('Interrupted build; restore original tree.')

    old_term = signal.signal(signal.SIGTERM, interrupted)
    try:
        original_cpp.write_text(modified)
        env = dict(os.environ, PKG_CONFIG_PATH=str(BASE / 'deps/usr/share/pkgconfig'))
        with (work / 'configure.log').open('w') as log:
            run_session(['cmake', '-S', str(source), '-B', str(build), '-DKDE_INSTALL_LIBEXECDIR=lib'],
                        timeout=600, env=env, stdout=log, stderr=subprocess.STDOUT).check_returncode()
        assert 'LIBEXEC_DIR("/usr/lib")' in (build / 'src/config-kwin.h').read_text()
        with (work / 'build.log').open('w') as log:
            run_session(['cmake', '--build', str(build), '--target', 'kwin_wayland', '-j', str(args.jobs)],
                        timeout=7200, env=env, stdout=log, stderr=subprocess.STDOUT).check_returncode()
        with (work / 'format-regression.log').open('w') as log:
            run_session([sys.executable, str(ROOT / 'maintenance/desktop/test-kwin-format-context.py'),
                         '--build', str(build), '--subject', 'library',
                         '--output', str(work / 'format-regression')],
                        timeout=120, env=env, stdout=log, stderr=subprocess.STDOUT).check_returncode()
        regression = json.loads((work / 'format-regression/results.json').read_text())
        if (regression.get('passed') is not True or regression.get('case_count') != 35
                or regression.get('library_sha256') != sha(build / 'bin/libkwin.so.6.8.2')):
            raise RuntimeError('Final library regression evidence mismatch.')
        report['format_regression_sha256'] = sha(work / 'format-regression/results.json')
        bundle = work / 'bundle'
        bundle.mkdir()
        for name in EXPECTED:
            target = bundle / ('libkwin.so.6' if name.startswith('libkwin') else name)
            shutil.copyfile(build / 'bin' / name, target)
            target.chmod(0o755 if name == 'kwin_wayland' else 0o644)
        report.update(built=True, new_binaries={p.name: {'sha256': sha(p), 'size': p.stat().st_size}
                                              for p in bundle.iterdir()},
                      modified_source_sha256=sha(original_cpp), patch_sha256=sha(work / 'kwin-private-xwayland-startup.patch'),
                      builder_sha256=sha(Path(__file__)),
                      session_process_sha256=sha(ROOT / 'maintenance/recovery/session_process.py'),
                      configure_libexecdir='/usr/lib')
    finally:
        signal.signal(signal.SIGTERM, old_term)
        rebuilt = work / 'rebuilt-trees'
        rebuilt.mkdir()
        for name in before:
            (BASE / name).rename(rebuilt / name)
            (snapshots / name).rename(BASE / name)
        restored = {name: tree_state(BASE / name) for name in before}
        report['old_trees_restored'] = restored == before
        (work / 'result.json').write_text(json.dumps(report, indent=2) + '\n')
        if restored != before:
            raise RuntimeError('Original tree restoration mismatch; inspect snapshots immediately.')
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
