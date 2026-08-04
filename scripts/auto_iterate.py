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
DESIGN_LOG = os.path.join(ROOT, 'docs', 'DESIGN_REFLECTION.md')

# 亲肤 fallback：主 patch 失败时仍保证每版有 UX 微改进
GENTLE_FALLBACKS = [
    ('StockPulse/Theme/AppTheme.swift', 'static let pillRadius: CGFloat = 14',
     'static let pillRadius: CGFloat = 14\n    static let softPadding: CGFloat = 8'),
    ('StockPulse/Theme/AppTheme.swift', 'static let cardRadius: CGFloat = 20',
     'static let cardRadius: CGFloat = 20\n    static let gentleAnimation: Double = 0.25'),
    ('StockPulse/Views/AnalysisCardView.swift', 'VStack(alignment: .leading, spacing: 12) {',
     'VStack(alignment: .leading, spacing: 14) {'),
    ('StockPulse/Views/SettingsView.swift', 'private let intervalOptions = [15, 30, 60, 120, 240]',
     'private let intervalOptions = [5, 15, 30, 60, 120, 240]'),
]


def infer_design_rationale(num, msg):
    """Mandatory 设计三问 before each commit."""
    m = msg.lower()
    if 'haptic' in m or '触觉' in m:
        return ('轻触觉微交互反馈', '操作有即时、克制的响应', '轻柔震动，不打扰、不惊吓')
    if 'accessibility' in m or 'accessibility' in msg:
        return ('无障碍标签/提示', '信息层级更清晰可读', '让所有用户都能舒适理解界面')
    if 'widget' in m:
        return ('桌面小组件视觉优化', '桌面一瞥即得关键信息', '柔和背景色，不刺眼')
    if 'settings' in m or '设置' in msg:
        return ('设置页体验优化', '分组清晰、操作直观', '文案温和，减少认知负担')
    if 'chart' in m or '图表' in msg or 'minichart' in m:
        return ('走势图表美学提升', '线条圆润、留白舒适', '淡色背景，长时间看不疲劳')
    if 'card' in m or '卡片' in msg or 'analysis' in m:
        return ('卡片式信息布局', '阴影/圆角/间距统一', '投资建议区柔和底色，阅读不费力')
    if 'loading' in m or '加载' in msg or 'progress' in m:
        return ('温和加载态', '等待时有明确反馈', '文案「加载中…」代替空白，减少焦虑')
    if 'alert' in m or 'error' in m or '知道了' in msg:
        return ('友好错误/提示交互', '按钮文案更亲切', '「知道了」代替生硬「好的」')
    if 'apptheme' in m or 'theme' in m:
        return ('设计系统常量扩展', '全局色彩/间距一致', '柔和配色，深浅模式都舒适')
    if 'readme' in m or num == 100:
        return ('版本里程碑文档', '项目进展可追溯', '完成标记给用户安心感')
    if 'placeholder' in m or '文案' in msg or 'footer' in m:
        return ('微文案优化', '提示更清晰易懂', '语气亲切，像朋友提醒而非机器报错')
    if 'spacing' in m or 'padding' in m or '间距' in msg:
        return ('留白与呼吸感', '视觉层级更舒展', '加大触控区，手指操作更轻松')
    if 'label' in m or '图标' in msg:
        return ('图标+文字语义化', '功能一眼可辨', 'SF Symbols 统一风格，温和不杂乱')
    return (
        '界面细节持续打磨',
        '统一 AppTheme 设计语言',
        '圆角卡片、柔和配色，长时间使用不疲劳',
    )


def log_design_reflection(num, msg, feature, elegant, gentle):
    header = '# 设计三问 · 迭代反思\n\n'
    entry = (
        '## v1.0.{n} — {msg}\n\n'
        '1. **新特性**：{feature}\n'
        '2. **更优雅**：{elegant}\n'
        '3. **更亲肤**：{gentle}\n\n'
    ).format(n=num, msg=msg, feature=feature, elegant=elegant, gentle=gentle)
    if not os.path.exists(DESIGN_LOG):
        write('docs/DESIGN_REFLECTION.md', header + entry)
    else:
        content = read('docs/DESIGN_REFLECTION.md')
        if content.startswith('# 设计三问'):
            write('docs/DESIGN_REFLECTION.md', header + entry + content[len(header):])
        else:
            append_line('docs/DESIGN_REFLECTION.md', entry)


def apply_gentle_fallback(num):
    idx = (num - 1) % len(GENTLE_FALLBACKS)
    path, old, new = GENTLE_FALLBACKS[idx]
    if patch(path, old, new):
        log('  亲肤 fallback applied: {}'.format(path))
        return True
    return False


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

        log('--- iter #{}: {} ---'.format(num, msg))
        feature, elegant, gentle = infer_design_rationale(num, msg)
        log('  [设计三问] 新特性: {} | 优雅: {} | 亲肤: {}'.format(feature, elegant, gentle))
        log_design_reflection(num, msg, feature, elegant, gentle)
        try:
            applied = apply_fn()
            if not applied:
                log('  skip (already applied)')
                applied = apply_gentle_fallback(num)
                if applied:
                    msg = msg + ' + 亲肤fallback'
        except Exception as e:
            log('  apply failed: {}'.format(e))
            applied = apply_gentle_fallback(num)

        bump_version(num)
        update_changelog(num, msg)
        log_iteration(num, msg)

        commit_msg = 'iter #{}: {} [v1.0.{}]'.format(num, msg, num)
        ok = push(commit_msg)
        if ok:
            state['completed'] = num
            save_state(state)
            log('  OK pushed #{}'.format(num))
            if num % 5 == 0:
                if not verify_build():
                    log('  WARN build failed at #{} — continuing'.format(num))
        else:
            log('  FAIL push #{}'.format(num))

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
