#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_SCRIPT="${SCRIPT_DIR}/elgato.sh"
SOURCE_PLIST="${SCRIPT_DIR}/com.RyanNickel.elgato.plist"

TARGET_SCRIPT="${HOME}/bin/elgato.sh"
TARGET_PLIST="${HOME}/Library/LaunchAgents/com.RyanNickel.elgato.plist"
LABEL="com.RyanNickel.elgato"
GUI_DOMAIN="gui/$(id -u)"

if [[ ! -f "${SOURCE_SCRIPT}" ]]; then
  echo "Missing source script: ${SOURCE_SCRIPT}" >&2
  exit 1
fi

if [[ ! -f "${SOURCE_PLIST}" ]]; then
  echo "Missing source plist: ${SOURCE_PLIST}" >&2
  exit 1
fi

mkdir -p "${HOME}/bin" "${HOME}/Library/LaunchAgents" "${HOME}/Library/Logs"

cp "${SOURCE_SCRIPT}" "${TARGET_SCRIPT}"
chmod 755 "${TARGET_SCRIPT}"

cp "${SOURCE_PLIST}" "${TARGET_PLIST}"
chmod 644 "${TARGET_PLIST}"

launchctl bootout "${GUI_DOMAIN}/${LABEL}" >/dev/null 2>&1 || true
launchctl bootstrap "${GUI_DOMAIN}" "${TARGET_PLIST}"
launchctl kickstart -k "${GUI_DOMAIN}/${LABEL}"

echo "Installed and started ${LABEL}."
launchctl print "${GUI_DOMAIN}/${LABEL}" | sed -n '1,40p'
