#!/bin/bash
# Установка Amphora без Developer ID.
#
#   curl -fsSL https://github.com/s1rne/amphora/releases/latest/download/install.sh | bash
#
# Почему это работает, а скачивание браузером — нет.
#
# Запуск чужого приложения блокирует не отсутствие подписи само по себе,
# а атрибут «карантин», который вешает на файл та программа, что его
# скачала: браузер, почта, мессенджер, AirDrop. Проверено запуском: копия
# без карантина открывается обычным щелчком, копия с карантином —
# блокируется, хотя подпись у них одна и та же.
#
# curl карантин не ставит. Поэтому установка через этот скрипт проходит
# без плясок в системных настройках. Обмен честный: человек вместо щелчка
# по ссылке выполняет команду в терминале — и должен понимать, что
# выполняет, поэтому скрипт короткий и читается целиком.

set -euo pipefail

# Адрес выпуска.
#
# Имя файла постоянное, без версии: адрес `releases/latest/download/ИМЯ`
# работает только при точном совпадении имени, а версия в нём означала бы,
# что ссылку надо править в каждом сообщении при каждом выпуске.
RELEASE="${AMPHORA_RELEASE:-https://github.com/s1rne/amphora/releases/latest/download/Amphora.dmg}"
DESTINATION="${AMPHORA_DESTINATION:-/Applications}"

say()  { printf '%s\n' "$*"; }
fail() { printf '\nОшибка: %s\n' "$*" >&2; exit 1; }

[ "$(uname -s)" = "Darwin" ] || fail "это установщик для macOS"

MAJOR=$(sw_vers -productVersion | cut -d. -f1)
[ "$MAJOR" -ge 14 ] 2>/dev/null || fail "нужна macOS 14 или новее, у вас $(sw_vers -productVersion)"

# Rosetta. Движок Wine собран под Intel; на Apple Silicon его исполняет
# Rosetta, а на новом Маке её обычно нет. Без неё ничего не заработает,
# и лучше сказать это здесь, чем оставить человека с невнятной ошибкой
# Wine через десять минут.
if [ "$(uname -m)" = "arm64" ] && ! /usr/bin/arch -x86_64 /usr/bin/true 2>/dev/null; then
  say ""
  say "Нужна Rosetta — без неё движок Wine не запустится."
  say "Установка занимает меньше минуты и спросит пароль администратора."
  say ""
  printf "Установить сейчас? [Y/n] "
  # Скрипт часто запускают через конвейер, и тогда stdin занят им самим:
  # спрашиваем у терминала напрямую.
  if [ -r /dev/tty ]; then read -r answer < /dev/tty; else answer="n"; fi
  case "${answer:-Y}" in
    [Nn]*) fail "без Rosetta продолжать нечего. Команда: softwareupdate --install-rosetta --agree-to-license" ;;
    *) softwareupdate --install-rosetta --agree-to-license || fail "Rosetta не установилась" ;;
  esac
fi

if [ -z "$RELEASE" ]; then
  fail "не задан адрес выпуска.
Укажите его переменной AMPHORA_RELEASE или впишите в скрипт:
  AMPHORA_RELEASE=https://.../Amphora-1.0.0.dmg bash install.sh"
fi

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

say "Скачиваю Amphora…"
curl -fL --retry 3 --progress-bar -o "$WORK/amphora.dmg" "$RELEASE" \
  || fail "не скачалось: $RELEASE"

say "Проверяю образ…"
hdiutil verify "$WORK/amphora.dmg" >/dev/null 2>&1 \
  || fail "образ повреждён — скачайте заново"

MOUNT="$WORK/mnt"
mkdir -p "$MOUNT"
hdiutil attach "$WORK/amphora.dmg" -nobrowse -readonly -mountpoint "$MOUNT" >/dev/null \
  || fail "образ не монтируется"
trap 'hdiutil detach "$MOUNT" >/dev/null 2>&1 || true; rm -rf "$WORK"' EXIT

[ -d "$MOUNT/Amphora.app" ] || fail "в образе нет Amphora.app"

if [ -d "$DESTINATION/Amphora.app" ]; then
  say "Заменяю прежнюю версию…"
  # Окружения и настройки лежат в Library, а не внутри бандла:
  # удаление приложения ничего из установленного не трогает.
  rm -rf "$DESTINATION/Amphora.app"
fi

say "Устанавливаю в ${DESTINATION}…"
# /bin/cp, а не cp: пользовательский алиас `cp -i` увёл бы копирование
# в интерактивный запрос, которого в конвейере никто не увидит.
/bin/cp -R "$MOUNT/Amphora.app" "$DESTINATION/" || fail "не удалось скопировать"

# curl карантин не ставит, но если образ попал сюда другим путём — снимаем.
xattr -dr com.apple.quarantine "$DESTINATION/Amphora.app" 2>/dev/null || true

codesign --verify --strict "$DESTINATION/Amphora.app" >/dev/null 2>&1 \
  || say "Внимание: подпись не проверилась. Продолжаю, но это стоит выяснить."

say ""
say "Готово: $DESTINATION/Amphora.app"
say "Запустить:  open -a Amphora"
say "Из терминала: $DESTINATION/Amphora.app/Contents/Resources/amphora-cli --help"
