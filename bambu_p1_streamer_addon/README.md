Bambu P1 Camera Streamer – Home Assistant Add-on

⚠️ This is a Home Assistant add-on.

It wraps the original BambuP1Streamer project by @slynn1324.
The original standalone project (Docker / Debian) is available here:
https://github.com/slynn1324/BambuP1Streamer

This document explains how to use the built-in camera of a Bambu P1 printer inside Home Assistant,
with a focus on print monitoring, TV display, and Frigate / go2rtc integration.

ℹ️ This add-on starts a dedicated internal go2rtc instance whose sole purpose is to produce the video stream.

🎯 What this add-on does

This add-on allows you to:

access the built-in camera of a Bambu Lab P1S / P1P

expose it as a standard video stream

use it with:

Home Assistant dashboards

TV / Android TV / browser / Picture-in-Picture

Frigate (view-only)

👉 No external camera required.

❗ Important limitations (by design)

The Bambu P1 camera:

runs at very low FPS (~1–2 fps)

has irregular frame timing

was not designed for surveillance

Because of this:

Feature	Status
Frigate detection	❌ Not supported
Continuous recording	❌ Not recommended
Reliable snapshots	❌
Live monitoring / viewing	✅ Perfect

➡️ This add-on is intended only for print monitoring.

✅ Supported printers

✅ Bambu Lab P1S

✅ Bambu Lab P1P

❌ X1 / X1C (different codecs, LAN streaming not supported)

🖥️ Supported platforms

Home Assistant OS

x86_64 / amd64 only

❌ Raspberry Pi / ARM (not supported)

🚀 Installation
1️⃣ Add the add-on repository

In Home Assistant:

Settings → Add-ons

⋮ → Repositories

Add this repository URL:
```yaml
https://github.com/PaulBiod/BambuP1Streamer
```

2️⃣ Install the add-on

Install Bambu P1 Camera Streamer

Do not start it yet

3️⃣ Configure the add-on

Open the Configuration tab and enter:
```yaml
printer_address: 192.168.1.50
printer_access_code: 12345678
```

Where:

printer_address = IP address of the printer

printer_access_code = Access Code shown on the printer screen

4️⃣ Start the add-on

Once started, the camera stream becomes available.

🔍 Test the camera stream

From a browser:
```yaml
http://<HOME_ASSISTANT_IP>:1985/
```

Or directly (recommended):
```yaml
http://<HOME_ASSISTANT_IP>:1985/api/stream.mjpeg?src=p1s
```

If you see the video → the add-on is working.

🎥 Recommended usage with Frigate / go2rtc
Why go2rtc?

go2rtc is much more tolerant than Frigate when dealing with:

very low FPS

irregular MJPEG streams

1️⃣ Add the stream to go2rtc (inside Frigate)

In frigate.yml:
```yaml
go2rtc:
  streams:
    bambulab:
      - http://192.168.1.135:1985/api/stream.mjpeg?src=p1s
```

Restart Frigate.

Test in a browser:
```yaml
http://<HOME_ASSISTANT_IP>:1984/stream.html?src=bambulab
```
(Optional) Add the camera to Frigate (view-only)

If you want the camera to appear in the Frigate UI
or use /api/<camera> endpoints:
```yaml
cameras:
  bambulab:
    enabled: true
    ffmpeg:
      hwaccel_args: []   # IMPORTANT: disable hardware decoding
      inputs:
        - path: rtsp://127.0.0.1:8554/bambulab
          input_args: preset-rtsp-restream
          roles: [record]   # used only to expose the camera
    detect:
      enabled: false
    record:
      enabled: false
    snapshots:
      enabled: false
```

⚠️ Never enable detection on this camera.

📺 Display on a TV (recommended)
MJPEG (most compatible)
```yaml
http://<HOME_ASSISTANT_IP>:1984/api/stream.mjpeg?src=bambulab
```

Works very well for:

Android TV

Web views

Picture-in-Picture systems

🧯 Troubleshooting
“No frames received” / “Unable to read frames”

Make sure detect.enabled: false

Do not use roles: detect

Use MJPEG or RTSP via go2rtc only

Disable hardware decoding (hwaccel_args: [])

Port conflicts (1984 / 1985)

You will have two go2rtc instances:

one inside this add-on (producer, port 1985)

one inside Frigate (consumer, port 1984)

➡️ This is expected and supported.
Do not run multiple Frigate instances.

⚖️ Legal / Disclaimer

This add-on downloads and uses proprietary Bambu Lab components
from official Bambu servers at runtime.

No proprietary files are redistributed in this repository.

This project is not affiliated with Bambu Lab.

❤️ Credits

Original project: BambuP1Streamer by @slynn1324
https://github.com/slynn1324/BambuP1Streamer

go2rtc by @AlexxIT

Home Assistant & Frigate communities

📝 Summary

✅ The Bambu P1 camera can be used in Home Assistant

❌ It is not suitable for detection

✅ go2rtc + view-only = stable & reliable

🎯 Perfect for print monitoring and TV display
