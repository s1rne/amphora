#!/bin/bash
# Что уцелело в Amphora.
#
#   curl -fsSL https://github.com/s1rne/amphora/releases/latest/download/rescue.sh | bash
#
# Этот сценарий ничего не меняет и ничего не удаляет. Он только смотрит и
# говорит, что нашёл, — и какой командой это вернуть.
#
# Нужен он в одном случае: когда окружение пересобрали и кажется, что всё
# пропало. Копия окружения снимается перед пересборкой сама и переживает её,
# так что «пропало» чаще всего означает «лежит рядом и не найдено».

set -u

A="$HOME/Library/Application Support/Amphora"
CLI="/Applications/Amphora.app/Contents/Resources/amphora-cli"

ru() { case "${AMPHORA_LANG:-${LANG:-en}}" in ru*|RU*) printf '%s' "$1";; *) printf '%s' "$2";; esac; }

if [ ! -d "$A" ]; then
  echo "$(ru "Amphora на этом Маке не находится." "Amphora is not installed on this Mac.")"
  exit 1
fi

version=$([ -x "$CLI" ] && "$CLI" --help 2>/dev/null | head -1 | sed 's/ —.*//; s/ - .*//')
echo "${version:-Amphora}"
echo

# ── копии окружений ──────────────────────────────────────────────────────
echo "$(ru "КОПИИ ОКРУЖЕНИЙ" "ENVIRONMENT COPIES")"
found=0
restore=""
for d in "$A/Snapshots"/*/*/ "$A/Apps"/*/snapshots/*/; do
  [ -d "$d" ] || continue
  found=1
  id=$(printf '%s' "$d" | sed "s|.*/Snapshots/\([^/]*\)/.*|\1|; s|.*/Apps/\([^/]*\)/snapshots/.*|\1|")
  size=$(du -sh "$d" 2>/dev/null | cut -f1)
  when=$(stat -f "%Sm" -t "%d.%m.%Y %H:%M" "$d" 2>/dev/null)
  games=$(find "$d" -maxdepth 7 -type d -name steamapps 2>/dev/null | head -1)
  line="  $when   $size   $id"
  if [ -n "$games" ]; then
    line="$line   <<< $(ru "ИГРЫ ВНУТРИ" "GAMES INSIDE"): $(du -sh "$games" 2>/dev/null | cut -f1)"
  fi
  echo "$line"
  [ -z "$restore" ] && restore="$id"
done
[ "$found" = 0 ] && echo "  $(ru "копий не нашлось" "no copies found")"
echo

# ── отложенное при сбое ──────────────────────────────────────────────────
echo "$(ru "ОТЛОЖЕННОЕ ПРИ СБОЕ" "SET ASIDE AFTER A FAILURE")"
kept=0
for k in "$A/Apps"/*/kept; do
  [ -d "$k" ] || continue
  kept=1
  echo "  $(du -sh "$k" 2>/dev/null | cut -f1)   $k"
done
[ "$kept" = 0 ] && echo "  $(ru "нет" "none")"
echo

# ── что на месте сейчас ──────────────────────────────────────────────────
echo "$(ru "ИГРЫ НА МЕСТЕ СЕЙЧАС" "GAMES IN PLACE RIGHT NOW")"
now=0
while IFS= read -r s; do
  [ -n "$s" ] || continue
  now=1
  echo "  $(du -sh "$s" 2>/dev/null | cut -f1)   $s"
done <<EOF
$(find "$A/Apps" -maxdepth 6 -type d -name steamapps 2>/dev/null)
EOF
[ "$now" = 0 ] && echo "  $(ru "нет" "none")"
echo

# ── что делать ───────────────────────────────────────────────────────────
echo "$(ru "ЧТО ДЕЛАТЬ" "WHAT TO DO")"
if [ "$found" = 1 ]; then
  echo "  $(ru "Копия есть — вернуть её целиком, вместе с играми:" "A copy exists — restore it whole, games and all:")"
  echo "      \"$CLI\" rollback $restore"
  echo "  $(ru "Сначала посмотреть список:" "See the list first:")"
  echo "      \"$CLI\" snapshots $restore"
else
  echo "  $(ru "Копий не нашлось. Игры Steam при этом не потеряны насовсем:" "No copies found. Steam games are not gone for good, though:")"
  echo "  $(ru "они привязаны к учётной записи и качаются заново, а сохранения" "they belong to your account and download again, and saves")"
  echo "  $(ru "у большинства игр лежат в облаке Steam." "for most games live in the Steam cloud.")"
fi
