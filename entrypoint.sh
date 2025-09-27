#!/usr/bin/env bash
set -euo pipefail

# Ensure Playwright uses preinstalled browsers
export PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

# 1. Timezone: default to UTC if not provided
: "${TZ:=UTC}"
ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime
echo "$TZ" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

# 2. Run the script directly (once per container start)
echo "[entrypoint] Starting run at $(date)"
cd /usr/src/microsoft-rewards-script || {
  echo "[entrypoint] ERROR: Unable to cd to /usr/src/microsoft-rewards-script" >&2
  exit 1
}

# If you want to preserve the random sleep logic, don’t set SKIP_RANDOM_SLEEP
exec xvfb-run --auto-servernum -s "-screen 0 1280x720x24" src/run_daily.sh
