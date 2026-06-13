#!/usr/bin/env bash
# social-creator — install the persona and enable it.
#
# Usage:
#   ./install.sh                # install into ./.san (project scope) and enable
#   ./install.sh --user         # install into ~/.san (user scope)
#   ./install.sh --dir <path>   # install into <path>/.san
#
# Effects:
#   1. Copy persona/ → <confdir>/personas/social-creator/
#   2. Enable it by setting "persona": "social-creator" in <confdir>/settings.json
set -euo pipefail

PERSONA="social-creator"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/persona"

SCOPE="project"
BASE="$PWD"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --user)    SCOPE="user"; shift ;;
    --dir)     BASE="$2"; shift 2 ;;
    -h|--help) sed -n '2,9p' "$0"; exit 0 ;;
    *)         echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [ "$SCOPE" = "user" ]; then
  CONFDIR="$HOME/.san"
else
  CONFDIR="$BASE/.san"
fi

if [ ! -d "$SRC" ]; then
  echo "error: persona source not found at $SRC" >&2
  echo "run this script from the social-creator repo (it needs ./persona/)." >&2
  exit 3
fi

DEST="$CONFDIR/personas/$PERSONA"
mkdir -p "$CONFDIR/personas"
rm -rf "$DEST"
cp -R "$SRC" "$DEST"
echo "→ installed persona to $DEST"

# Enable: set "persona" in <confdir>/settings.json, preserving any other keys.
SETTINGS="$CONFDIR/settings.json"
if command -v python3 >/dev/null 2>&1; then
  python3 - "$SETTINGS" "$PERSONA" <<'PY'
import json, sys
path, name = sys.argv[1], sys.argv[2]
try:
    with open(path) as f:
        data = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    data = {}
data["persona"] = name
with open(path, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
PY
elif [ ! -s "$SETTINGS" ]; then
  printf '{\n  "persona": "%s"\n}\n' "$PERSONA" > "$SETTINGS"
else
  echo "warning: python3 not found and $SETTINGS already exists." >&2
  echo "         add  \"persona\": \"$PERSONA\"  to it manually to enable." >&2
fi
echo "→ enabled '$PERSONA' in $SETTINGS ($SCOPE scope)"

cat <<EOF

✓ social-creator installed & enabled ($SCOPE scope)
  Persona:  $DEST
  Enabled:  $SETTINGS  → "persona": "$PERSONA"

Start san in this directory and the persona is active. Switch anytime with:
  /persona $PERSONA          # activate
  /persona default           # back to built-in San
EOF
