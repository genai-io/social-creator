#!/usr/bin/env bash
# social-creator — remove the persona and disable it.
#
# Usage:
#   ./uninstall.sh              # remove from ./.san (project scope)
#   ./uninstall.sh --user       # remove from ~/.san (user scope)
#   ./uninstall.sh --dir <path> # remove from <path>/.san
set -euo pipefail

PERSONA="social-creator"
SCOPE="project"
BASE="$PWD"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --user)    SCOPE="user"; shift ;;
    --dir)     BASE="$2"; shift 2 ;;
    -h|--help) sed -n '2,7p' "$0"; exit 0 ;;
    *)         echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [ "$SCOPE" = "user" ]; then
  CONFDIR="$HOME/.san"
else
  CONFDIR="$BASE/.san"
fi

DEST="$CONFDIR/personas/$PERSONA"
if [ -d "$DEST" ]; then
  rm -rf "$DEST"
  echo "→ removed $DEST"
else
  echo "→ no persona dir at $DEST (skipping)"
fi

# Disable: drop "persona" from settings.json only if it points at this persona.
SETTINGS="$CONFDIR/settings.json"
if [ -f "$SETTINGS" ] && command -v python3 >/dev/null 2>&1; then
  python3 - "$SETTINGS" "$PERSONA" <<'PY'
import json, sys
path, name = sys.argv[1], sys.argv[2]
try:
    with open(path) as f:
        data = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    sys.exit(0)
if data.get("persona") == name:
    data.pop("persona", None)
    with open(path, "w") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")
    print(f"→ disabled persona in {path}")
else:
    print(f"→ {path} active persona is not '{name}'; left unchanged")
PY
elif [ -f "$SETTINGS" ]; then
  echo "warning: python3 not found; if \"persona\": \"$PERSONA\" is set in $SETTINGS, remove it manually." >&2
fi

echo
echo "✓ social-creator uninstalled ($SCOPE scope)"
