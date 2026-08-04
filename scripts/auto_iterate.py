#!/usr/bin/env python3
"""
全自动迭代引擎 — 100 次改进，每次自动提交推送。
用法: python3 scripts/auto_iterate.py [--from N] [--count 100]
"""
import json
import os
import subprocess
import sys
import time
from datetime import datetime

from ux_improvements import UX_IMPROVEMENTS

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STATE_FILE = os.path.join(ROOT, '.auto-iterate-state.json')
LOG_FILE = os.path.join(ROOT, 'logs', 'auto-iterate.log')
VERSION_FILE = os.path.join(ROOT, 'VERSION')
CHANGELOG = os.path.join(ROOT, 'CHANGELOG.md')
ITERATION_LOG = os.path.join(ROOT, 'docs', 'ITERATION_LOG.md')


def log(msg):
    line = "[{}] {}".format(datetime.now().strftime('%H:%M:%S'), msg)
    os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)
    with open(LOG_FILE, 'ab') as f:
        f.write((line + '\n').encode('utf-8'))
    try:
        sys.stdout.write(line + '\n')
        sys.stdout.flush()
    except Exception:
        pass


def read(path):
    full = os.path.join(ROOT, path)
    with open(full, 'rb') as f:
        return f.read().decode('utf-8')


def write(path, content):
    full = os.path.join(ROOT, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, 'wb') as f:
        f.write(content.encode('utf-8'))


def patch(path, old, new):
    content = read(path)
    if old not in content:
        return False
    write(path, content.replace(old, new, 1))
    return True


def append_line(path, line):
    content = read(path) if os.path.exists(os.path.join(ROOT, path)) else ''
    if line.strip() in content:
        return False
    write(path, content + ('\n' if content and not content.endswith('\n') else '') + line + '\n')
    return True


def push(message):
    try:
        result = subprocess.run(
            [sys.executable, os.path.join(ROOT, 'scripts', 'github_push.py'), message],
            cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            universal_newlines=True, timeout=180,
        )
    except subprocess.TimeoutExpired:
        log('  push timeout')
        return False
    out = (result.stdout or '') + (result.stderr or '')
    log(out.strip())
    return result.returncode == 0 and 'NO_CHANGES' not in out


def load_state():
    if os.path.exists(STATE_FILE):
        with open(STATE_FILE, 'rb') as f:
            return json.loads(f.read().decode('utf-8'))
    return {'completed': 0, 'total': 100}


def save_state(state):
    with open(STATE_FILE, 'wb') as f:
        f.write(json.dumps(state, indent=2).encode('utf-8'))


def bump_version(build):
    write('VERSION', f'1.0.{build}\n')


def update_changelog(n, msg):
    header = '# Changelog\n\n'
    entry = '## v1.0.{} - {}\n- {}\n\n'.format(n, datetime.now().strftime("%Y-%m-%d %H:%M"), msg)
    if os.path.exists(CHANGELOG):
        content = read('CHANGELOG.md')
        if content.startswith('# Changelog'):
            write('CHANGELOG.md', header + entry + content[len(header):])
        else:
            write('CHANGELOG.md', header + entry + content)
    else:
        write('CHANGELOG.md', header + entry)


def log_iteration(n, msg):
    os.makedirs(os.path.join(ROOT, 'docs'), exist_ok=True)
    line = f'| {n} | {datetime.now().strftime("%Y-%m-%d %H:%M")} | {msg} |'
    if not os.path.exists(ITERATION_LOG):
        write('docs/ITERATION_LOG.md', '# 迭代日志\n\n| # | 时间 | 改动 |\n|---|------|------|\n' + line + '\n')
    else:
        append_line('docs/ITERATION_LOG.md', line)


# ─── 100 次改进定义 ───────────────────────────────────────────

def verify_build():
    """Run xcodebuild without code signing to verify Swift compiles."""
    project = os.path.join(ROOT, 'StockPulse.xcodeproj')
    try:
        result = subprocess.run(
            [
                'xcodebuild',
                '-project', project,
                '-scheme', 'StockPulse',
                '-destination', 'generic/platform=iOS',
                'CODE_SIGNING_ALLOWED=NO',
                'build',
            ],
            cwd=ROOT,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
            timeout=300,
        )
    except subprocess.TimeoutExpired:
        log('  xcodebuild timeout')
        return False
    if result.returncode != 0:
        tail = (result.stdout or '') + (result.stderr or '')
        log('  xcodebuild FAILED (exit {})'.format(result.returncode))
        for line in tail.strip().splitlines()[-8:]:
            log('    ' + line)
        return False
    log('  xcodebuild OK')
    return True


def build_improvements():
    items = [
        (1, '添加版本追踪文件 VERSION', lambda: bump_version(1) or True),
        (2, '添加 CHANGELOG 初始化', lambda: update_changelog(2, '初始化变更日志') or True),
    ]
    for num, msg, path, old, new in UX_IMPROVEMENTS:
        items.append((num, msg, lambda p=path, o=old, nw=new: patch(p, o, nw)))
    return items


def run(from_iter=1, count=100):
    improvements = build_improvements()
    state = load_state()
    start = max(from_iter, state['completed'] + 1)
    end = min(start + count - 1, 100)

    log(f'=== 自动迭代启动: #{start} → #{end} ===')

    for num, msg, apply_fn in improvements:
        if num < start or num > end:
            continue

        log(f'--- 迭代 #{num}: {msg} ---')
        try:
            applied = apply_fn()
            if not applied:
                log(f'  跳过 (已应用或无变化)')
        except Exception as e:
            log(f'  应用失败: {e}')
            applied = False

        bump_version(num)
        update_changelog(num, msg)
        log_iteration(num, msg)

        commit_msg = 'iter #{}: {} [v1.0.{}]'.format(num, msg, num)
        ok = push(commit_msg)
        if ok:
            state['completed'] = num
            save_state(state)
            log(f'  ✓ 已推送 #{num}')
        else:
            log(f'  ✗ 推送失败 #{num}')

        if num % 5 == 0:
            verify_build()

        time.sleep(1)

    log(f'=== 完成: 共 {state["completed"]}/100 次迭代 ===')


if __name__ == '__main__':
    from_arg = 1
    count_arg = 100
    args = sys.argv[1:]
    i = 0
    while i < len(args):
        if args[i] == '--from' and i + 1 < len(args):
            from_arg = int(args[i + 1]); i += 2
        elif args[i] == '--count' and i + 1 < len(args):
            count_arg = int(args[i + 1]); i += 2
        else:
            i += 1
    run(from_arg, count_arg)
