#!/bin/sh
set -e

if [ -z "$PRINTER_ADDRESS" ]; then
  echo "ERROR: printer_address manquant"
  exit 1
fi

if [ -z "$PRINTER_ACCESS_CODE" ]; then
  echo "ERROR: printer_access_code manquant"
  exit 1
fi

LIB_PATH="/app/bambu_plugin/libBambuSource.so"

echo "Starting BambuP1Streamer for $PRINTER_ADDRESS"

/app/BambuP1Streamer "$LIB_PATH" "$PRINTER_ADDRESS" "$PRINTER_ACCESS_CODE" &

exec /app/go2rtc
