#!/usr/bin/env bash
set -euo pipefail

# Ensure Playwright uses preinstalled browsers
export PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

# 1. Timezone: default to UTC if not provided
: "${TZ:=UTC}"
ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime
echo "$TZ" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

# 2. Manually start Xvfb for better log handling in Docker
echo "[entrypoint] Starting virtual display..."
export DISPLAY=:99
# Start Xvfb in the background and redirect its output to /dev/null
Xvfb $DISPLAY -screen 0 1280x720x24 >/dev/null 2>&1 &
XVFB_PID=$!
# Trap to ensure Xvfb is killed on exit
trap 'echo "[entrypoint] Shutting down virtual display..."; kill $XVFB_PID' EXIT INT TERM

# 3. Run the script directly
echo "[entrypoint] Starting run at $(date)"
cd /usr/src/microsoft-rewards-script || {
  echo "[entrypoint] ERROR: Unable to cd to /usr/src/microsoft-rewards-script" >&2
  exit 1
}

# If you want to preserve the random sleep logic, don’t set SKIP_RANDOM_SLEEP
exec src/run_daily.sh
