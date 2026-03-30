# Elgato Camera Auto-Light

Automatically turns your Elgato light on when camera activity is detected and turns it off when camera activity stops.

## What this uses

- Script: `elgato.sh`
- LaunchAgent: `com.RyanNickel.elgato.plist`
- Installer: `install-elgato.sh`

Installed runtime locations:

- Script: `~/bin/elgato.sh`
- LaunchAgent: `~/Library/LaunchAgents/com.RyanNickel.elgato.plist`
- Logs:
  - `~/Library/Logs/elgato.standard.log`
  - `~/Library/Logs/elgato.error.log`

## Install or Reinstall

From this folder:

```bash
./install-elgato.sh
```

This copies the scrit/plist into the active locations and reloads the LaunchAgent.

## Current Defaults

In `elgato.sh`:

- `CAMERA_NAME=Logitech StreamCam`
- `POLL_INTERVAL_SECONDS=2`
- `LIGHT_ENDPOINT=http://192.168.1.132:9123/elgato/lights`
- `LIGHT_BRIGHTNESS=40`
- `LIGHT_TEMPERATURE_K=2900`

Note: Elgato's API uses mired values for `temperature`; the script converts from Kelvin.

## Check Status

```bash
launchctl print gui/$(id -u)/com.RyanNickel.elgato | rg "state =|pid =|job state ="
```

## View Logs

```bash
tail -f ~/Library/Logs/elgato.standard.log
tail -f ~/Library/Logs/elgato.error.log
```

## Troubleshooting

- Camera triggers but light does not change:
  - Verify `LIGHT_ENDPOINT` IP/port in `elgato.sh`.
  - Confirm the light is reachable on your LAN.
- No log updates:
  - Re-run `./install-elgato.sh` to redeploy and restart.
  - Check LaunchAgent status with `launchctl print ...`.
