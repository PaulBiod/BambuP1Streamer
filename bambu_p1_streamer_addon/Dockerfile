FROM debian:bookworm-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates wget unzip g++ git jq \
  && rm -rf /var/lib/apt/lists/*

# Clone du projet BambuP1Streamer
RUN git clone --depth 1 https://github.com/slynn1324/BambuP1Streamer.git /app/src

# Build du binaire
RUN g++ /app/src/src/BambuP1Streamer.cpp -o /app/BambuP1Streamer

# Dépendances Bambu
RUN wget -q https://public-cdn.bambulab.com/upgrade/studio/plugins/01.04.00.15/linux_01.04.00.15.zip \
  && unzip -q linux_01.04.00.15.zip -d /app/bambu_plugin \
  && rm linux_01.04.00.15.zip

# go2rtc
RUN wget -q -O /app/go2rtc https://github.com/AlexxIT/go2rtc/releases/download/v1.6.2/go2rtc_linux_amd64 \
  && chmod +x /app/go2rtc

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
