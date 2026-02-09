#!/usr/bin/env bash
set -e

PRINTER_ADDRESS=$(jq -r '.printer_address' /data/options.json)
PRINTER_ACCESS_CODE=$(jq -r '.printer_access_code' /data/options.json)

if [ -z "$PRINTER_ADDRESS" ] || [ "$PRINTER_ADDRESS" = "null" ]; then
  echo "ERROR: printer_address manquant"
  exit 1
fi
if [ -z "$PRINTER_ACCESS_CODE" ] || [ "$PRINTER_ACCESS_CODE" = "null" ]; then
  echo "ERROR: printer_access_code manquant"
  exit 1
fi

export PRINTER_ADDRESS
export PRINTER_ACCESS_CODE

echo "Starting BambuP1Streamer for ${PRINTER_ADDRESS}"
exec /app/BambuP1Streamer
