#!/usr/bin/env python3
"""Commit local changes and push to GitHub (git push with API fallback)."""
import base64
import json
import os
import subprocess
import sys
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OWNER = "YuanCheng-coder"
REPO = "stock_informer"
API = f"https://api.github.com/repos/{OWNER}/{REPO}"


def get_token():
    raw = subprocess.check_output(
        ['security', 'find-generic-password', '-s', 'gh:github.com', '-w'],
        stderr=subprocess.DEVNULL,
    ).decode().strip()
    if raw.startswith('go-keyring-base64:'):
        raw = raw.split(':', 1)[1]
    return base64.b64decode(raw).decode()


def api_request(token, method, url, data=None):
    headers = {
        'Authorization': f'Bearer {token}',
        'Accept': 'application/vnd.github+json',
        'User-Agent': 'stock-informer-auto',
    }
    body = None
    if data is not None:
        body = json.dumps(data).encode()
        headers['Content-Type'] = 'application/json'
    req = urllib.request.Request(url, data=body, headers=headers, method=method)
    with urllib.request.urlopen(req, timeout=120) as resp:
        return json.loads(resp.read().decode())


def git_commit(message):
    os.chdir(ROOT)
    subprocess.run(['git', 'add', '-A'], check=True)
    status = subprocess.check_output(['git', 'status', '--porcelain']).decode().strip()
    if not status:
        return False
    subprocess.run(['git', 'commit', '-m', message], check=True)
    return True


def git_push(timeout=45):
    os.chdir(ROOT)
    try:
        subprocess.run(
            ['git', 'push', 'origin', 'main'],
            check=True,
            timeout=timeout,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        return True
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired):
        return False


def api_push(token, message):
    os.chdir(ROOT)
    parent = api_request(token, 'GET', f'{API}/git/ref/heads/main')['object']['sha']
    tree_items = []
    skip_prefixes = ('./.git/',)
    skip_files = {'.DS_Store'}

    for dirpath, dirnames, filenames in os.walk('.'):
        dirnames[:] = [d for d in dirnames if d != '.git' and not d.startswith('.')]
        for name in filenames:
            if name in skip_files or name.startswith('.') and name != '.gitignore':
                continue
            path = os.path.join(dirpath, name)
            rel = path[2:] if path.startswith('./') else path
            if any(rel.startswith(p[2:]) for p in skip_prefixes):
                continue
            with open(path, 'rb') as f:
                content = base64.b64encode(f.read()).decode()
            blob = api_request(token, 'POST', f'{API}/git/blobs', {
                'content': content,
                'encoding': 'base64',
            })
            tree_items.append({
                'path': rel.replace('\\', '/'),
                'mode': '100644',
                'type': 'blob',
                'sha': blob['sha'],
            })

    tree = api_request(token, 'POST', f'{API}/git/trees', {'tree': tree_items})
    commit = api_request(token, 'POST', f'{API}/git/commits', {
        'message': message,
        'tree': tree['sha'],
        'parents': [parent],
    })
    api_request(token, 'PATCH', f'{API}/git/refs/heads/main', {'sha': commit['sha']})
    subprocess.run(['git', 'fetch', 'origin'], check=False)
    subprocess.run(['git', 'reset', '--hard', 'origin/main'], check=False)
    return commit['sha']


def push(message):
    if not git_commit(message):
        print('NO_CHANGES')
        return None
    if git_push():
        sha = subprocess.check_output(['git', 'rev-parse', 'HEAD']).decode().strip()
        print('GIT_PUSH_OK', sha)
        return sha
    token = get_token()
    sha = api_push(token, message)
    print('API_PUSH_OK', sha)
    return sha


if __name__ == '__main__':
    msg = sys.argv[1] if len(sys.argv) > 1 else 'auto update'
    push(msg)
