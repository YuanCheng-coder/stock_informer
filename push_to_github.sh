#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

export GITHUB_TOKEN=$(security find-generic-password -s "gh:github.com" -w | sed 's/go-keyring-base64://' | base64 -d)
OWNER="YuanCheng-coder"
REPO="stock_informer"
API="https://api.github.com/repos/$OWNER/$REPO"

api() {
  local method="$1" url="$2" data="${3:-}"
  if [ -n "$data" ]; then
    curl -fsSL -X "$method" "$url" \
      -H "Authorization: Bearer $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github+json" \
      -H "Content-Type: application/json" \
      --data-binary "$data"
  else
    curl -fsSL -X "$method" "$url" \
      -H "Authorization: Bearer $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github+json"
  fi
}

# Get current main commit as parent
PARENT=$(api GET "$API/git/ref/heads/main" | python3 -c "import sys,json; print(json.load(sys.stdin)['object']['sha'])")
echo "parent=$PARENT"

TREE_ITEMS=()
while IFS= read -r -d '' file; do
  rel="${file#./}"
  [[ "$rel" == ".git/"* ]] && continue
  [[ "$rel" == "README.md" ]] && continue

  B64=$(base64 < "$file" | tr -d '\n')
  SHA=$(api POST "$API/git/blobs" "{\"content\":\"$B64\",\"encoding\":\"base64\"}" | python3 -c "import sys,json; print(json.load(sys.stdin)['sha'])")
  TREE_ITEMS+=("{\"path\":\"$rel\",\"mode\":\"100644\",\"type\":\"blob\",\"sha\":\"$SHA\"}")
  echo "blob $rel"
done < <(find . -type f ! -path './.git/*' ! -name '.DS_Store' -print0)

# Include existing README from parent commit
README_SHA=$(api GET "$API/contents/README.md" | python3 -c "import sys,json; print(json.load(sys.stdin)['sha'])")
TREE_ITEMS+=("{\"path\":\"README.md\",\"mode\":\"100644\",\"type\":\"blob\",\"sha\":\"$README_SHA\"}")

TREE_JSON="{\"base_tree\":\"$PARENT\",\"tree\":[$(IFS=,; echo "${TREE_ITEMS[*]}")]} "
TREE_SHA=$(api POST "$API/git/trees" "$TREE_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['sha'])")

COMMIT_SHA=$(api POST "$API/git/commits" "{\"message\":\"Add StockPulse iOS app source code\",\"tree\":\"$TREE_SHA\",\"parents\":[\"$PARENT\"]}" | python3 -c "import sys,json; print(json.load(sys.stdin)['sha'])")

api PATCH "$API/git/refs/heads/main" "{\"sha\":\"$COMMIT_SHA\"}" > /dev/null

echo "PUSH_OK commit=$COMMIT_SHA"
echo "https://github.com/$OWNER/$REPO"
