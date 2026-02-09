# Bambu P1 Camera Streamer – Home Assistant Add-on

> ⚠️ **This is a Home Assistant add-on**
>
> It wraps the original **BambuP1Streamer** project by @slynn1324.  
> The original standalone project (Docker / Debian) is available here:  
> https://github.com/slynn1324/BambuP1Streamer
>
> ℹ️ This add-on starts a **dedicated internal go2rtc instance** whose sole purpose is to **produce** the video stream.

This document explains how to use the **built-in camera** of a **Bambu P1S / P1P** inside Home Assistant, with a focus on:
- print monitoring
- TV display / PIP
- Frigate / go2rtc integration (view-only)

---

## 🎯 What this add-on does

This add-on allows you to:
- access the **built-in camera** of a **Bambu Lab P1S / P1P**
- expose it as a **standard video stream**
- use it with:
  - Home Assistant dashboards
  - TV / Android TV / browser / Picture-in-Picture
  - Frigate (view-only)

👉 No external camera required.

---

## ❗ Important limitations (by design)

The Bambu P1 camera:
- runs at very low FPS (~1–2 fps)
- has irregular frame timing
- was not designed for surveillance

Because of this:

| Feature | Status |
|---|---|
| Frigate detection | ❌ Not supported |
| Continuous recording | ❌ Not recommended |
| Reliable snapshots | ❌ |
| Live monitoring / viewing | ✅ Perfect |

➡️ This add-on is intended only for print monitoring.

---

## ✅ Supported printers

- ✅ Bambu Lab P1S
- ✅ Bambu Lab P1P
- ❌ X1 / X1C (different codecs, LAN streaming not supported)

---

## 🖥️ Supported platforms

- Home Assistant OS
- x86_64 / amd64 only
- ❌ Raspberry Pi / ARM (not supported)

---

## 🚀 Installation

### 1️⃣ Add the add-on repository

In Home Assistant:

1. **Settings → Add-ons**
2. **⋮ → Repositories**
3. Add this repository URL:

```text
https://github.com/PaulBiod/BambuP1Streamer
```
### 2️⃣ Install the add-on

Install Bambu P1 Camera Streamer

Do not start it yet

### 3️⃣ Configure the add-on

Open the Configuration tab and enter:

```yaml
printer_address: 192.168.1.50
printer_access_code: 12345678
```
Where:

printer_address = IP address of the printer

printer_access_code = Access Code shown on the printer screen

### 4️⃣ Start the add-on

Once started, the camera stream becomes available.

🔍 Test the camera stream

From a browser:
```text
http://<HOME_ASSISTANT_IP>:1985/
```
Or directly (recommended):
```text
http://<HOME_ASSISTANT_IP>:1985/api/stream.mjpeg?src=p1s
```
If you see the video → the add-on is working.

---

🎥 Recommended usage with Frigate / go2rtc
Why go2rtc?

go2rtc is much more tolerant than Frigate when dealing with:

very low FPS

irregular MJPEG streams

### 1️⃣ Add the stream to go2rtc (inside Frigate)

In frigate.yml:
```yaml
go2rtc:
  streams:
    bambulab:
      - http://192.168.1.135:1985/api/stream.mjpeg?src=p1s
```
Restart Frigate.

Test in a browser:
```text
http://<HOME_ASSISTANT_IP>:1984/stream.html?src=bambulab
```

(Optional) Add the camera to Frigate (view-only)

If you want the camera to appear in the Frigate UI or use /api/<camera> endpoints:

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

---

📺 Display on a TV (recommended)

MJPEG (most compatible):
```text
http://<HOME_ASSISTANT_IP>:1984/api/stream.mjpeg?src=bambulab
```
Works very well for:

Android TV
Web views
Picture-in-Picture systems

---

🧯 Troubleshooting
“No frames received” / “Unable to read frames”

Make sure detect.enabled: false

Do not use roles: detect

Use MJPEG/RTSP via go2rtc only

Disable hardware decoding (hwaccel_args: [])

Port conflicts (1984 / 1985)

You will have two go2rtc instances:

inside this add-on (producer, port 1985)

inside Frigate (consumer, port 1984)

➡️ This is expected and supported.

⚖️ Legal / Disclaimer

This add-on downloads and uses proprietary Bambu Lab components from official Bambu servers at runtime.
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


---


## 📺 Display the stream on a TV with **PiPup** (recommended)

This setup lets you display the Bambu camera stream as a **Picture-in-Picture (PiP)** overlay on a TV.

### ✅ Prerequisites (PiPup)

- Install **PiPup** on your TV / Android TV device
- Ensure PiPup shows something like: `The server is running on: <TV_IP>:7979`
- Your Home Assistant must be able to reach that IP/port

PiPup project: https://github.com/rogro82/pipup

---

## 1) Choose the stream URL (MJPEG)

**MJPEG is the most compatible** with TVs (HLS often opens a player that fails).

### Option A — via Frigate go2rtc (port 1984)
```text
http://<HOME_ASSISTANT_IP>:1984/api/stream.mjpeg?src=bambulab
```

### Option B — directly from this add-on (port 1985)
```text
http://<HOME_ASSISTANT_IP>:1985/api/stream.mjpeg?src=p1s
```

## 2) Add the rest_command (Home Assistant)

Create or edit rest_commands.yaml:
```yaml
pipup_url_on_tv:
  url: http://192.168.1.31:7979/notify  # <-- PiPup server shown on the TV screen
  content_type: "application/json"
  verify_ssl: false
  method: post
  timeout: 20
  payload: >
    {
      "duration": {{ duration | default(20) }},
      "position": {{ position | default(0) }},
      "title": "{{ title | default('') }}",
      "titleColor": "{{ titleColor | default('#50BFF2') }}",
      "titleSize": {{ titleSize | default(10) }},
      "message": "{{ message | default('') }}",
      "messageColor": "{{ messageColor | default('#fbf5f5') }}",
      "messageSize": {{ messageSize | default(14) }},
      "backgroundColor": "{{ backgroundColor | default('#0f0e0e') }}",
      "media": {
        "web": {
          "uri": "{{ url }}",
          "width": {{ width | default(640) }},
          "height": {{ height | default(480) }}
        }
      }
    }
```

And make sure Home Assistant loads it in configuration.yaml:
```yaml
rest_command: !include rest_commands.yaml
```

## 3) Create a reusable script (Home Assistant)

```yaml
alias: PIP video on TV
sequence:
  - if:
      - condition: not
        conditions:
          - condition: state
            entity_id: media_player.philips_tv_2
            state: "off"
    then:
      - action: rest_command.pipup_url_on_tv
        data:
          title: "{{ title }}"
          message: "{{ message }}"
          width: 640
          height: 480
          url: "{{ url }}"
```

## 4) Example automation / button call
Using the add-on (port 1985):
```yaml
action: script.pip_video_on_tv
data:
  title: "Bambu P1S"
  message: "Print monitoring"
  url: "http://192.168.1.135:1985/api/stream.mjpeg?src=p1s"
```

Or using Frigate go2rtc (port 1984):
```yaml
action: script.pip_video_on_tv
data:
  title: "Bambu P1S"
  message: "Print monitoring"
  url: "http://192.168.1.135:1984/api/stream.mjpeg?src=bambulab"
```
