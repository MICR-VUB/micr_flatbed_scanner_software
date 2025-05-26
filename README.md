# MICR Scanner Software

## Description
This package utilises docker, sane, and epsonscan2-non-free-plugin to allow simultaneous scanning with multiple epson scanners. The bash script enclosed allows the use of all the regular sane and epsonscan2 backend configuration parameters.

## Setup
1. Build the Dockerfile `docker build -t arch-epsonscan2 .` (this will take some time as epsonscan2 needs to be built from source)
2. Run the scan_with_docker script. e.g.`./scan_with_docker.sh --bus 001 --dev 002 --output ./scan.tiff -- --resolution 300 --mode Color -x 120 -y 100 --format=tiff`

## 3D Printed Five-Plate Template
Below is a table of approximate coordinates and scan dimensions for each section. Refer to the reference image to relate each section to its number. 

![Reference](./whole_page.tiff)

section 1: `./scan_with_docker.sh --bus 001 --dev 002 --output ./sec2_scan.tiff -- --format=tiff --resolution 300 --mode Color -y 100 -x 130`

section 2: `./scan_with_docker.sh --bus 001 --dev 002 --output ./sec2_scan.tiff -- --format=tiff --resolution 300 --mode Color -t 100 -l 0 -y 0 -x 130`

section 3: `./scan_with_docker.sh --bus 001 --dev 002 --output ./sec3_scan.tiff -- --format=tiff --resolution 300 --mode Color -t 200 -l 0 -y 0 -x 130`

section 4: `./scan_with_docker.sh --bus 001 --dev 002 --output ./sec5_scan.tiff -- --format=tiff --resolution 300 --mode Color -t 130 -l 130 -y 130 -x 100`

section 5: `./scan_with_docker.sh --bus 001 --dev 002 --output ./sec5_scan.tiff -- --format=tiff --resolution 300 --mode Color -t 150 -l 130 -y 0 -x 100`
