#!/usr/bin/env bash
# Instala agentes e skills do bundle Claude.
#
#   ./install.sh                pergunta item a item; destino ~/.claude
#   ./install.sh --all          instala tudo
#   ./install.sh devoso tdd     instala só os nomes dados
#   ./install.sh --to <projeto> instala em <projeto>/.claude
#
# Agente instalado leva junto agents/knowledge/, que os agentes citam.
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)/claude/.claude"
DEST="$HOME/.claude"
ALL=false
PICKED=()

while [ $# -gt 0 ]; do
  case "$1" in
    --to) DEST="$2/.claude"; shift 2 ;;
    --all) ALL=true; shift ;;
    -h|--help) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) PICKED+=("$1"); shift ;;
  esac
done

AGENTS=$(ls "$SRC/agents"/*.md | xargs -n1 basename | sed 's/\.md$//')
SKILLS=$(ls -d "$SRC/skills"/*/ | xargs -n1 basename)

wanted() {
  local kind="$1" name="$2"
  $ALL && return 0
  if [ ${#PICKED[@]} -gt 0 ]; then
    for p in "${PICKED[@]}"; do [ "$p" = "$name" ] && return 0; done
    return 1
  fi
  local note=""
  [ -e "$DEST/$kind/$name" ] || [ -e "$DEST/$kind/$name.md" ] && note=" (já existe, substitui)"
  read -r -p "  $kind/$name$note [S/n] " ans
  [[ -z "$ans" || "$ans" =~ ^[SsYy]$ ]]
}

installed_agent=false
echo "Destino: $DEST"
echo "Agentes:"
for a in $AGENTS; do
  if wanted agents "$a"; then
    mkdir -p "$DEST/agents"
    cp "$SRC/agents/$a.md" "$DEST/agents/"
    installed_agent=true
    echo "  + agents/$a.md"
  fi
done
if $installed_agent; then
  mkdir -p "$DEST/agents/knowledge"
  cp "$SRC/agents/knowledge/"*.md "$DEST/agents/knowledge/"
  echo "  + agents/knowledge/"
fi

echo "Skills:"
for s in $SKILLS; do
  if wanted skills "$s"; then
    mkdir -p "$DEST/skills/$s"
    cp "$SRC/skills/$s/SKILL.md" "$DEST/skills/$s/"
    echo "  + skills/$s/"
  fi
done

if [ ${#PICKED[@]} -gt 0 ]; then
  for p in "${PICKED[@]}"; do
    echo "$AGENTS $SKILLS" | tr ' ' '\n' | grep -qx "$p" || echo "aviso: '$p' não existe no bundle"
  done
fi
