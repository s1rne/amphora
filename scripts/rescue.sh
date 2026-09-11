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
orphaned_games=0
while IFS= read -r s; do
  [ -n "$s" ] || continue
  now=1
  echo "  $(du -sh "$s" 2>/dev/null | cut -f1)   $s"

  # Папка с игрой есть, а сведений о ней нет — Steam такую не видит и
  # предлагает качать заново, хотя качать нечего.
  manifests=$(ls "$s"/appmanifest_*.acf 2>/dev/null | wc -l | tr -d ' ')
  folders=0
  if [ -d "$s/common" ]; then
    folders=$(ls -1 "$s/common" 2>/dev/null | wc -l | tr -d ' ')
    for g in "$s/common"/*/; do
      [ -d "$g" ] || continue
      echo "      $(du -sh "$g" 2>/dev/null | cut -f1)  $(basename "$g")"
    done
  fi
  echo "      $(ru "сведений о играх" "game records"): $manifests, $(ru "папок с играми" "game folders"): $folders"
  if [ "$folders" -gt 0 ] && [ "$manifests" -lt "$folders" ]; then
    orphaned_games=1
  fi
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
elif [ "$now" = 1 ]; then
  echo "  $(ru "Копий нет, но игры на диске целы — они никуда не пропадали." "No copies, but the games on disk are intact — they never went anywhere.")"
  if [ "$orphaned_games" = 1 ]; then
    echo "  $(ru "Steam их не видит: папки с играми есть, а сведений о них нет." "Steam cannot see them: the game folders are there, the records are not.")"
    echo "  $(ru "Лечится так: в Steam нажать «Установить» ту же игру в ту же" "The way out: in Steam, press Install on the same game into the same")"
    echo "  $(ru "папку. Он найдёт файлы на месте, проверит их и докачает только" "folder. It finds the files, checks them and downloads only what is")"
    echo "  $(ru "недостающее — а не всё заново." "missing — not everything again.")"
  else
    echo "  $(ru "Сведения о играх тоже на месте. Если Steam их всё равно не" "The game records are there too. If Steam still does not show them,")"
    echo "  $(ru "показывает — дело во входе в учётную запись, а не в файлах." "the trouble is the account login, not the files.")"
  fi
else
  echo "  $(ru "Копий не нашлось. Сами игры Steam не потеряны: они привязаны" "No copies found. The Steam games themselves are not lost: they")"
  echo "  $(ru "к учётной записи и качаются заново. Сохранения — только если" "belong to your account and download again. Saves survive only")"
  echo "  $(ru "игра держит их в облаке Steam; не все так делают (Kenshi — нет)." "if the game keeps them in the Steam cloud; not all do (Kenshi does not).")"
  echo "  $(ru "Если включён Time Machine, сохранения есть в резервной копии:" "With Time Machine on, the saves are in the backup:")"
  echo "  $(ru "Библиотеки → Application Support → Amphora, за дату до сбоя." "Library → Application Support → Amphora, dated before the failure.")"
fi
