#!/usr/bin/env bash

# Show usage
usage() {
  echo "Usage: $0 --device-name scanner_v600_1 --output /path/to/output.tiff [-- any scanimage args]"
  echo "Example: $0 --device-name scanner_v600_1 --output ./scan.tiff -- --resolution 300 --mode Color -x 210 -y 297"
  exit 1
}

# Parse arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --device-name) DEVNAME="$2"; shift ;;
    --output) OUTFILE="$2"; shift ;;
    --) shift; break ;;  # Stop parsing and forward the rest
    *) echo "Unknown parameter: $1"; usage ;;
  esac
  shift
done

# Validate required inputs
if [[ -z "$DEVNAME" || -z "$OUTFILE" ]]; then
  echo "Missing required arguments."
  usage
fi

DEVICE_PATH="/dev/$DEVNAME"

if [[ ! -e "$DEVICE_PATH" ]]; then
  echo "❌ Device '$DEVICE_PATH' not found."
  exit 1
fi

# Extract bus and device numbers
BUS=$(udevadm info --query=property --name="$DEVICE_PATH" | grep BUSNUM | cut -d= -f2)
DEV=$(udevadm info --query=property --name="$DEVICE_PATH" | grep DEVNUM | cut -d= -f2)

if [[ -z "$BUS" || -z "$DEV" ]]; then
  echo "❌ Failed to extract bus/device IDs from $DEVICE_PATH"
  exit 1
fi

# Resolve output path
OUTDIR="$(dirname "$(realpath "$OUTFILE")")"
OUTNAME="$(basename "$OUTFILE")"

# Detect docker permissions
DOCKER="docker"
if ! groups "$USER" | grep -qw docker; then
  DOCKER="sudo docker"
fi

# Run scan
$DOCKER run --rm \
  --device="/dev/bus/usb/${BUS}/${DEV}" \
  -v "${OUTDIR}:/scans" \
  arch-epsonscan2 \
  bash -c "scanimage $* > /scans/${OUTNAME}"

# Status
if [[ $? -eq 0 ]]; then
  echo "✅ Scan saved to ${OUTFILE}"
else
  echo "❌ Scan failed."
fi
