#!/bin/bash

set -u

CAMERA_NAME="${CAMERA_NAME:-Logitech StreamCam}"
POLL_INTERVAL_SECONDS="${POLL_INTERVAL_SECONDS:-2}"
LIGHT_ENDPOINT="${LIGHT_ENDPOINT:-http://192.168.1.132:9123/elgato/lights}"
LIGHT_BRIGHTNESS="${LIGHT_BRIGHTNESS:-40}"
LIGHT_TEMPERATURE_K="${LIGHT_TEMPERATURE_K:-2900}"
LIGHT_TEMPERATURE="${LIGHT_TEMPERATURE:-$((1000000 / LIGHT_TEMPERATURE_K))}"

log() {
  printf "%s %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

is_builtin_camera_active() {
  ioreg -r -c AppleH13CamIn -l -w0 2>/dev/null | grep -Eq '"FrontCamera(Streaming|Active)" = Yes'
}

is_usb_camera_active() {
  ioreg -r -n "$CAMERA_NAME" -l -w0 2>/dev/null | awk '
    /^[[:space:]]*\+-o IOUSBHostInterface@/ {
      if (in_if && iface_class == 14 && iface_subclass == 2 && alt_setting > 0) {
        found = 1
      }
      in_if = 1
      iface_class = -1
      iface_subclass = -1
      alt_setting = -1
      next
    }
    in_if && /"bInterfaceClass" =/ { iface_class = $NF + 0; next }
    in_if && /"bInterfaceSubClass" =/ { iface_subclass = $NF + 0; next }
    in_if && /"bAlternateSetting" =/ { alt_setting = $NF + 0; next }
    END {
      if (in_if && iface_class == 14 && iface_subclass == 2 && alt_setting > 0) {
        found = 1
      }
      exit(found ? 0 : 1)
    }
  '
}

is_camera_active() {
  is_builtin_camera_active || is_usb_camera_active
}

set_light_state() {
  local on="$1"
  local payload

  payload="{\"lights\":[{\"brightness\":${LIGHT_BRIGHTNESS},\"temperature\":${LIGHT_TEMPERATURE},\"on\":${on}}],\"numberOfLights\":1}"

  if ! curl --silent --show-error --fail --max-time 3 \
    --request PUT "$LIGHT_ENDPOINT" \
    --header 'Content-Type: application/json' \
    --data-raw "$payload" >/dev/null; then
    log "Failed to set Elgato light state to ${on}."
    return 1
  fi

  return 0
}

log "Monitoring camera activity. Built-in + USB camera fallback (${CAMERA_NAME})."

previous_state="off"

while true; do
  if is_camera_active; then
    if [[ "$previous_state" != "on" ]]; then
      log "Camera became active. Turning light on."
      set_light_state 1
      previous_state="on"
    fi
  else
    if [[ "$previous_state" != "off" ]]; then
      log "Camera became inactive. Turning light off."
      set_light_state 0
      previous_state="off"
    fi
  fi

  sleep "$POLL_INTERVAL_SECONDS"
done
