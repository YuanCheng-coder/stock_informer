#!/bin/bash
# Push current working tree on top of remote main via GitHub API (when git push fails)
set -euo pipefail
cd "$(dirname "$0")/.."
MSG="${1:-sync local to remote}"
export GITHUB_TOKEN=$(security find-generic-password -s "gh:github.com" -w | sed 's/go-keyring-base64://' | base64 -d)
API="https://api.github.com/repos/YuanCheng-coder/stock_informer"
PARENT=$(curl -fsSL "$API/git/ref/heads/main" -H "Authorization: Bearer $GITHUB_TOKEN" | python3 -c "import sys,json; print(json.load(sys.stdin)['object']['sha'])")
echo "parent=$PARENT"

TREE_ITEMS=()
while IFS= read -r -d '' file; do
  rel="${file#./}"
  [[ "$rel" == .git/* ]] && continue
  B64=$(base64 < "$file" | tr -d '\n')
  SHA=$(curl -fsSL -X POST "$API/git/blobs" -H "Authorization: Bearer $GITHUB_TOKEN" -H "Content-Type: application/json" \
    -d "{\"content\":\"$B64\",\"encoding\":\"base64\"}" | python3 -c "import sys,json; print(json.load(sys.stdin)['sha'])")
  TREE_ITEMS+=("{\"path\":\"$rel\",\"mode\":\"100644\",\"type\":\"blob\",\"sha\":\"$SHA\"}")
done < <(find . -type f ! -path './.git/*' ! -name '.DS_Store' -print0)

TREE_JSON="{\"tree\":[$(IFS=,; echo "${TREE_ITEMS[*]}")]} "
TREE_SHA=$(curl -fsSL -X POST "$API/git/trees" -H "Authorization: Bearer $GITHUB_TOKEN" -H "Content-Type: application/json" --data-binary "$TREE_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['sha'])")
COMMIT_SHA=$(curl -fsSL -X POST "$API/git/commits" -H "Authorization: Bearer $GITHUB_TOKEN" -H "Content-Type: application/json" \
  -d "{\"message\":\"$MSG\",\"tree\":\"$TREE_SHA\",\"parents\":[\"$PARENT\"]}" | python3 -c "import sys,json; print(json.load(sys.stdin)['sha'])")
curl -fsSL -X PATCH "$API/git/refs/heads/main" -H "Authorization: Bearer $GITHUB_TOKEN" -H "Content-Type: application/json" -d "{\"sha\":\"$COMMIT_SHA\"}" > /dev/null
git fetch origin && git reset --hard origin/main
echo "PUSH_OK $COMMIT_SHA"
