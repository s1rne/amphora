#!/bin/bash
# Amphora installer.
#
#   curl -fsSL https://github.com/s1rne/amphora/releases/latest/download/install.sh | bash
#
# Why this works when downloading in a browser does not.
#
# What blocks a downloaded app is not the missing signature by itself — it is
# the "quarantine" attribute attached by whichever program fetched the file:
# a browser, a mail client, a messenger, AirDrop. Verified by running both: a
# copy without quarantine opens on an ordinary double-click, a copy with it is
# blocked, though the signature is identical.
#
# curl does not attach quarantine. So this script installs without a detour
# through System Settings. The trade is honest: instead of clicking a link you
# run a command — and you should be able to see what it does, which is why the
# script is short and reads end to end.

set -euo pipefail

# Release address.
#
# The file name carries no version on purpose: the `releases/latest/download/NAME`
# address only works on an exact name match, and a version inside it would mean
# editing the link in every message on every release.
#
# `${VAR-default}` without a colon: an address set to an empty string on purpose
# stays empty and is caught below. With a colon the shell treats empty as unset
# and silently downloads the real release — which is exactly how a test of this
# script once installed the product for real.
RELEASE="${AMPHORA_RELEASE-https://github.com/s1rne/amphora/releases/latest/download/Amphora.dmg}"
DESTINATION="${AMPHORA_DESTINATION:-/Applications}"

# Two languages, because the product itself speaks both. Picked from the system
# locale; AMPHORA_LANG overrides it.
LANGUAGE="${AMPHORA_LANG:-${LANG:-en}}"
case "$LANGUAGE" in ru*|RU*) RU=1 ;; *) RU=0 ;; esac
tr_() { if [ "$RU" = 1 ]; then printf '%s' "$2"; else printf '%s' "$1"; fi; }

say()  { printf '%s\n' "$*"; }
fail() { printf '\n%s: %s\n' "$(tr_ Error Ошибка)" "$*" >&2; exit 1; }

[ "$(uname -s)" = "Darwin" ] || fail "$(tr_ "this installer is for macOS" "это установщик для macOS")"

MAJOR=$(sw_vers -productVersion | cut -d. -f1)
[ "$MAJOR" -ge 14 ] 2>/dev/null || fail "$(tr_ "macOS 14 or later is required, you have $(sw_vers -productVersion)" \
                                              "нужна macOS 14 или новее, у вас $(sw_vers -productVersion)")"

# Rosetta. Part of the compatibility engine is Intel code; on Apple Silicon it
# runs through Rosetta, which a new Mac usually does not have. Nothing works
# without it, and it is better said here than as an obscure failure ten minutes
# later.
if [ "$(uname -m)" = "arm64" ] && ! /usr/bin/arch -x86_64 /usr/bin/true 2>/dev/null; then
  say ""
  say "$(tr_ "Rosetta is required — the compatibility engine will not start without it." \
           "Нужна Rosetta — без неё движок совместимости не запустится.")"
  say "$(tr_ "It installs in under a minute and asks for an administrator password." \
           "Установка занимает меньше минуты и спросит пароль администратора.")"
  say ""
  printf "%s [Y/n] " "$(tr_ "Install it now?" "Установить сейчас?")"
  # The script is often run through a pipe, and then stdin is taken by the pipe
  # itself: ask the terminal directly.
  if [ -r /dev/tty ]; then read -r answer < /dev/tty; else answer="n"; fi
  case "${answer:-Y}" in
    [Nn]*) fail "$(tr_ "nothing to continue with. Command: softwareupdate --install-rosetta --agree-to-license" \
                       "без Rosetta продолжать нечего. Команда: softwareupdate --install-rosetta --agree-to-license")" ;;
    *) softwareupdate --install-rosetta --agree-to-license \
         || fail "$(tr_ "Rosetta did not install" "Rosetta не установилась")" ;;
  esac
fi

[ -n "$RELEASE" ] || fail "$(tr_ "no release address given (set AMPHORA_RELEASE)" \
                                 "не задан адрес выпуска (переменная AMPHORA_RELEASE)")"

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

say "$(tr_ "Downloading Amphora…" "Скачиваю Amphora…")"
curl -fL --retry 3 --progress-bar -o "$WORK/amphora.dmg" "$RELEASE" \
  || fail "$(tr_ "download failed: $RELEASE" "не скачалось: $RELEASE")"

say "$(tr_ "Checking the image…" "Проверяю образ…")"
hdiutil verify "$WORK/amphora.dmg" >/dev/null 2>&1 \
  || fail "$(tr_ "the image is damaged — download it again" "образ повреждён — скачайте заново")"

MOUNT="$WORK/mnt"
mkdir -p "$MOUNT"
hdiutil attach "$WORK/amphora.dmg" -nobrowse -readonly -mountpoint "$MOUNT" >/dev/null \
  || fail "$(tr_ "the image will not mount" "образ не монтируется")"
trap 'hdiutil detach "$MOUNT" >/dev/null 2>&1 || true; rm -rf "$WORK"' EXIT

[ -d "$MOUNT/Amphora.app" ] || fail "$(tr_ "no Amphora.app inside the image" "в образе нет Amphora.app")"

if [ -d "$DESTINATION/Amphora.app" ]; then
  say "$(tr_ "Replacing the previous version…" "Заменяю прежнюю версию…")"
  # Environments and settings live in Library, not inside the bundle: removing
  # the app touches nothing that was installed.
  rm -rf "$DESTINATION/Amphora.app"
fi

say "$(tr_ "Installing into ${DESTINATION}…" "Устанавливаю в ${DESTINATION}…")"
# /bin/cp rather than cp: a user alias of `cp -i` would turn the copy into an
# interactive prompt that nobody sees inside a pipe.
/bin/cp -R "$MOUNT/Amphora.app" "$DESTINATION/" \
  || fail "$(tr_ "could not copy" "не удалось скопировать")"

# curl does not set quarantine, but if the image arrived some other way, clear it.
xattr -dr com.apple.quarantine "$DESTINATION/Amphora.app" 2>/dev/null || true

codesign --verify --strict "$DESTINATION/Amphora.app" >/dev/null 2>&1 \
  || say "$(tr_ "Note: the signature did not verify. Continuing, but this is worth looking into." \
               "Внимание: подпись не проверилась. Продолжаю, но это стоит выяснить.")"

say ""
say "$(tr_ "Done: $DESTINATION/Amphora.app" "Готово: $DESTINATION/Amphora.app")"
say "$(tr_ "Launch it:" "Запустить:") open -a Amphora"
say "$(tr_ "From a terminal:" "Из терминала:") $DESTINATION/Amphora.app/Contents/Resources/amphora-cli --help"
