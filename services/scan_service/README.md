# ScanService

## Description
This service is a lightweight, containerized API designed to interface with scanner hardware. Upon receiving a request, it launches a dedicated Docker container in parallel, passing in the necessary scan configuration parameters (such as scan area, resolution, and other options). The scan is then executed using the SANE (Scanner Access Now Easy) backend within the container.

## Starting the server (local development)
Run:
1. `mix deps.get`
2. `iex -S mix`

## Starting the server (prod)
First build the docker image with `docker build -t scan_service .`
Then run the container with:
  ```bash
  docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /dev:/dev \
  -v /run/udev:/run/udev \
  --privileged \
  -p 4001:4001 \
  scan_service
  ```

## API Parameters

The API accepts the following query parameters when initiating a scan. If a parameter is not provided, a default value will be used.

| Parameter   | Type    | Default   | Description                                                   |
|-------------|---------|-----------|---------------------------------------------------------------|
| `device` | String | none, must be specified | device name specific to udev rules on the host machine e.g. `scanner_v600_1`, `scanner_v600_2`, `scanner_v550_1` |
| `output` | String | none, must be specified | output save directoy on the host machine e.g. `/home/user/scans` |
| `resolution` (`res`) | Integer | `300`     | Scan resolution in DPI.                                      |
| `mode`      | String  | `"Color"` | Scan mode. Common values: `Color`, `Gray`, `Lineart`.        |
| `t`         | Integer   | `0`       | Top margin (in millimeters).                                 |
| `l`         | Integer   | `0`       | Left margin (in millimeters).                                |
| `x`         | Integer   | `210`     | Width of scan area (in millimeters).                         |
| `y`         | Integer   | `297`     | Height of scan area (in millimeters).                        |

These parameters define the scan area and quality settings for each scan request. They are passed as JSON in the body of a POST request.

---

### Example Request

```bash
curl -X POST http://10.240.47.255:4001/scan \
  -H "Content-Type: application/json" \
  -d '{
    "device": "scanner_v600_1",
    "output": "/home/scanners/mac_test.tiff"
    "resolution": 600,
    "mode": "Gray",
    "t": 10,
    "l": 10,
    "x": 100,
    "y": 150
  }'
```
