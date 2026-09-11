#!/bin/bash
# Спрятать сохранения игр в безопасное место.
#
#   curl -fsSL https://github.com/s1rne/amphora/releases/latest/download/saves.sh | bash
#
# Копирует — не переносит и ничего не удаляет. Оригиналы остаются на месте.
#
# Нужен в одном случае: Steam сказал, что не сошлась синхронизация с облаком.
# В этот момент он предлагает выбрать, какую копию оставить, и неверная
# кнопка затирает сохранения на диске облачными — иногда недельной давности.
# Пока выбор не сделан, копию надо иметь свою.

set -u

A="$HOME/Library/Application Support/Amphora"
OUT="$HOME/Desktop/Сохранения Amphora $(date +%Y-%m-%d-%H%M)"

ru() { case "${AMPHORA_LANG:-${LANG:-en}}" in ru*|RU*) printf '%s' "$1";; *) printf '%s' "$2";; esac; }

[ -d "$A/Apps" ] || { echo "$(ru "Amphora на этом Маке не находится." "Amphora is not installed on this Mac.")"; exit 1; }

echo "$(ru "Ищу сохранения…" "Looking for saves…")"
found=0

copy() {
  local src="$1" label="$2"
  [ -d "$src" ] || return 0
  [ -n "$(ls -A "$src" 2>/dev/null)" ] || return 0
  local dst="$OUT/$label"
  mkdir -p "$(dirname "$dst")"
  if cp -Rc "$src" "$dst" 2>/dev/null || cp -R "$src" "$dst" 2>/dev/null; then
    echo "  $(du -sh "$dst" 2>/dev/null | cut -f1)  $label"
    found=1
  fi
}

for app in "$A/Apps"/*/; do
  [ -d "$app" ] || continue
  id=$(basename "$app")
  C="$app/prefix/drive_c"
  [ -d "$C" ] || continue

  # Сохранения внутри самих игр: так делает Kenshi и многие другие.
  while IFS= read -r s; do
    [ -n "$s" ] || continue
    game=$(basename "$(dirname "$s")")
    copy "$s" "$id/$game"
  done <<EOF
$(find "$C" -maxdepth 7 -type d \( -iname save -o -iname saves -o -iname savegames \) 2>/dev/null)
EOF

  # Облачные сохранения Steam и общие места, куда пишут игры.
  copy "$C/Program Files (x86)/Steam/userdata" "$id/Steam-userdata"
  for u in "$C/users"/*/; do
    [ -d "$u" ] || continue
    who=$(basename "$u")
    copy "$u/AppData/Local/kenshi/save" "$id/kenshi-$who"
    copy "$u/Documents/My Games" "$id/My Games-$who"
    copy "$u/Saved Games" "$id/Saved Games-$who"
  done
done

echo
if [ "$found" = 1 ]; then
  echo "$(ru "Сохранения скопированы на рабочий стол:" "Saves copied to your Desktop:")"
  echo "  $OUT"
  echo
  echo "$(ru "Оригиналы на месте — ничего не перемещалось и не удалялось." "The originals are untouched — nothing was moved or deleted.")"
  echo "$(ru "Теперь со Steam можно разговаривать спокойно." "Now you can deal with Steam without worrying.")"
else
  rmdir "$OUT" 2>/dev/null
  echo "$(ru "Сохранений в обычных местах не нашлось." "No saves in the usual places.")"
  echo "$(ru "Это не значит, что их нет: часть игр прячет их по-своему." "That does not mean there are none: some games hide them in their own way.")"
fi
