#!/bin/sh
set -e

PRINTER_ADDRESS="$(jq -r '.printer_address // empty' /data/options.json)"
PRINTER_ACCESS_CODE="$(jq -r '.printer_access_code // empty' /data/options.json)"

if [ -z "$PRINTER_ADDRESS" ]; then
  echo "ERROR: printer_address manquant"
  exit 1
fi

if [ -z "$PRINTER_ACCESS_CODE" ]; then
  echo "ERROR: printer_access_code manquant"
  exit 1
fi

# Trouve la lib (au cas où le zip change de structure)
LIB_PATH="$(find /app -name libBambuSource.so 2>/dev/null | head -n 1)"

if [ -z "$LIB_PATH" ]; then
  echo "ERROR: libBambuSource.so introuvable"
  exit 1
fi

echo "Starting go2rtc for P1S at ${PRINTER_ADDRESS}"
echo "Using lib: ${LIB_PATH}"

cat > /dev/shm/go2rtc.yaml <<EOF
api:
  listen: ":1985"
streams:
  p1s: "exec:/app/BambuP1Streamer ${LIB_PATH} ${PRINTER_ADDRESS} ${PRINTER_ACCESS_CODE}"
EOF

exec /app/go2rtc -config /dev/shm/go2rtc.yaml
