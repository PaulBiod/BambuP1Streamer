# Bambu P1 Camera Streamer – Home Assistant Add-on

> ⚠️ This is a **Home Assistant add-on**.
>  
> It wraps the original **BambuP1Streamer** project by @slynn1324.  
> The original standalone project (Docker / Debian) is here:  
> https://github.com/slynn1324/BambuP1Streamer

This document explains **how to use the Bambu P1 camera inside Home Assistant**,
especially with **Frigate / go2rtc** and for **display on a TV**.

“This add-on starts an internal go2rtc instance used only as a producer.”
---

## 🎯 What this add-on does

This add-on allows you to:
- access the **built-in camera** of a **Bambu Lab P1S / P1P**
- expose it as a **standard video stream**
- use it with:
  - **Frigate (view-only)**
  - **go2rtc**
  - **Home Assistant dashboards**
  - **TV / Android TV / browser / PIP**

👉 No external camera required.

---

## ❗ Important limitations (by design)

The Bambu P1 camera:
- runs at **very low FPS** (~1–2 fps)
- has **irregular frame timing**
- is **not a surveillance camera**

Because of this:

| Feature | Status |
|------|------|
| Frigate detection | ❌ Not supported |
| Continuous recording | ❌ Not recommended |
| Reliable snapshots | ❌ |
| Monitoring / viewing | ✅ Perfect |

This add-on is intended for **print monitoring only**.

---

## ✅ Supported printers

- ✅ **Bambu Lab P1S**
- ✅ **Bambu Lab P1P**
- ❌ X1 / X1C (different codecs, LAN streaming not supported)

---

## 🖥️ Supported platforms

- Home Assistant OS
- **x86_64 / amd64 only**
- ❌ Raspberry Pi / ARM (not supported at this time)

---

## 🚀 Installation

### 1️⃣ Add the add-on repository
In Home Assistant:

1. **Settings → Add-ons**
2. **⋮ → Repositories**
3. Add this repository URL:

https://github.com/PaulBiod/BambuP1Streamer


---

### 2️⃣ Install the add-on
- Install **Bambu P1 Camera Streamer**
- Do **not** start it yet

---

### 3️⃣ Configure the add-on

Open the **Configuration** tab and enter:

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
http://<HOME_ASSISTANT_IP>:1985/
Or directly:
http://<HOME_ASSISTANT_IP>:1985/api/stream.mjpeg?src=p1s

If you see the video → the add-on is working.

🎥 Recommended usage with Frigate / go2rtc
Why go2rtc?

go2rtc is much more tolerant than Frigate when dealing with:

low FPS

irregular MJPEG streams

1️⃣ Add the stream to go2rtc (Frigate)

In frigate.yml:
```yaml
go2rtc:
  streams:
    bambulab:
      - http://192.168.1.135:1985/api/stream.mjpeg?src=p1s
```

Restart Frigate.

Test:
http://<HOME_ASSISTANT_IP>:1984/stream.html?src=bambulab

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
          roles: [record]
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

http://<HOME_ASSISTANT_IP>:1984/api/stream.mjpeg?src=bambulab

This works very well for:

Android TV

Web views

PIP / picture-in-picture systems

🧯 Troubleshooting
“No frames received” / “Unable to read frames”

Make sure detect.enabled: false

Do not use roles: detect

Use MJPEG or RTSP via go2rtc only

Port conflicts (1984 / 1985)

You should have only one go2rtc:

the one integrated in Frigate

Do not run multiple go2rtc instances in parallel

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

Yes, the Bambu P1 camera can be used

No, it is not suitable for detection

go2rtc + view-only = stable & reliable

Perfect for print monitoring and TV display
