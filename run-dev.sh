#!/usr/bin/env bash
# Единая точка запуска dev-игры из workspace.
set -euo pipefail
WS="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$WS/work/PersonalKnox-dev"
exec ./tools/launch_dev.sh \
  --profile both \
  --source "$WS/work/PersonalKnox-dev" \
  --worldgen-source "$WS/work/PersonalWorldGen-dev" \
  --cache-dir "$WS/work/pz-cache" \
  --build --trust-local-builds --restart --detach --no-debug --nosteam \
  --scenario-seconds 30 \
  "$@"
