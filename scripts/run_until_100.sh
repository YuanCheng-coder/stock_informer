#!/bin/bash
# Resilient runner: continues auto-iterate until 100/100 complete
set -euo pipefail
cd "$(dirname "$0")/.."
export LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

LOG=logs/auto-iterate.log
mkdir -p logs

while true; do
  DONE=$(python3 -c "import json; print(json.load(open('.auto-iterate-state.json'))['completed'])" 2>/dev/null || echo 0)
  if [ "$DONE" -ge 100 ]; then
    echo "[$(date +%H:%M:%S)] ALL 100 ITERATIONS COMPLETE" | tee -a "$LOG"
    break
  fi
  NEXT=$((DONE + 1))
  REMAIN=$((100 - DONE))
  echo "[$(date +%H:%M:%S)] resume from #$NEXT ($REMAIN remaining)" | tee -a "$LOG"
  python3 scripts/auto_iterate.py --from "$NEXT" --count "$REMAIN" 2>&1 | tee -a "$LOG" || true
  sleep 3
done

# Final build verify
xcodebuild -scheme StockPulse -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build 2>&1 | tail -3 | tee -a "$LOG"
