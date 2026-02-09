FROM debian:bookworm-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates wget unzip g++ jq \
  && rm -rf /var/lib/apt/lists/*

COPY . /app

RUN g++ /app/src/BambuP1Streamer.cpp -o /app/BambuP1Streamer

RUN wget -q https://public-cdn.bambulab.com/upgrade/studio/plugins/01.04.00.15/linux_01.04.00.15.zip \
  && unzip -q linux_01.04.00.15.zip -d /app/bambu_plugin \
  && rm linux_01.04.00.15.zip

RUN wget -q -O /app/go2rtc https://github.com/AlexxIT/go2rtc/releases/download/v1.6.2/go2rtc_linux_amd64 \
  && chmod +x /app/go2rtc

COPY bambu_p1_streamer_addon/run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
