#!/usr/bin/env bash
# social-creator — install the persona and enable it.
#
# Local:   ./install.sh [--user] [--dir <path>]
# Remote:  curl -fsSL https://raw.githubusercontent.com/genai-io/social-creator/main/install.sh | bash
#          curl -fsSL .../install.sh | bash -s -- --user
#
# Default scope is the current project (<cwd>/.san). --user installs to
# ~/.san; --dir <path> targets <path>/.san.
set -euo pipefail

PERSONA="social-creator"
REPO_URL="${SOCIAL_CREATOR_REPO:-https://github.com/genai-io/social-creator.git}"
REF="${SOCIAL_CREATOR_REF:-main}"

usage() {
  cat <<EOF
Usage: install.sh [--user] [--dir <path>]
  --user        install into ~/.san (user scope)
  --dir <path>  install into <path>/.san
  (default: current project, ./.san)
EOF
}

SCOPE="project"
BASE="$PWD"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --user)    SCOPE="user"; shift ;;
    --dir)     BASE="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *)         echo "unknown arg: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [ "$SCOPE" = "user" ]; then
  CONFDIR="$HOME/.san"
else
  CONFDIR="$BASE/.san"
fi

# Resolve the source root holding the persona files (system/, skills/,
# settings.json). They sit at the repo root, so use the checkout when run from
# one, otherwise clone the repo (the `curl | bash` path).
SRC_ROOT=""
if [ -n "${BASH_SOURCE:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  { [ -d "$here/system" ] || [ -f "$here/settings.json" ]; } && SRC_ROOT="$here"
fi
if [ -z "$SRC_ROOT" ]; then
  command -v git >/dev/null 2>&1 || { echo "error: git is required for remote install" >&2; exit 3; }
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  echo "→ fetching $PERSONA@$REF"
  git clone --depth 1 --branch "$REF" --quiet "$REPO_URL" "$TMP/src"
  SRC_ROOT="$TMP/src"
fi

DEST="$CONFDIR/personas/$PERSONA"
rm -rf "$DEST"
mkdir -p "$DEST"
copied=0
for item in system skills settings.json; do
  if [ -e "$SRC_ROOT/$item" ]; then
    cp -R "$SRC_ROOT/$item" "$DEST/"
    copied=1
  fi
done
[ "$copied" = 1 ] || { echo "error: no persona content found in $SRC_ROOT" >&2; exit 3; }
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
  Enabled:  $SETTINGS  →  "persona": "$PERSONA"

Start san in this directory and the persona is active. Switch anytime with:
  /persona $PERSONA      (activate)   ·   /persona default   (back to built-in San)
EOF
