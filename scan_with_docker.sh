#!/usr/bin/env bash

# Show usage
usage() {
  echo "Usage: $0 --bus BUS_ID --dev DEVICE_ID --output /path/to/output.tiff [-- any scanimage args]"
  echo "Example: $0 --bus 001 --dev 002 --output ./scan.tiff -- --resolution 300 --mode Color -x 210 -y 297"
  exit 1
}

# Parse fixed arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --bus) BUS="$2"; shift ;;
    --dev) DEV="$2"; shift ;;
    --output) OUTFILE="$2"; shift ;;
    --) shift; break ;;  # Stop parsing and forward the rest
    *) echo "Unknown parameter: $1"; usage ;;
  esac
  shift
done

# Validate required inputs
if [[ -z "$BUS" || -z "$DEV" || -z "$OUTFILE" ]]; then
  echo "Missing required arguments."
  usage
fi

# Get output directory and filename
OUTDIR="$(dirname "$(realpath "$OUTFILE")")"
OUTNAME="$(basename "$OUTFILE")"

# Detect docker or use sudo if needed
DOCKER="docker"
if ! groups "$USER" | grep -qw docker; then
  DOCKER="sudo docker"
fi

# Run scan inside container
$DOCKER run --rm \
  --device="/dev/bus/usb/${BUS}/${DEV}" \
  -v "${OUTDIR}:/scans" \
  arch-epsonscan2-locales \
  bash -c "scanimage $* > /scans/${OUTNAME}"

# Report status
if [[ $? -eq 0 ]]; then
  echo "✅ Scan saved to ${OUTFILE}"
else
  echo "❌ Scan failed."
fi
