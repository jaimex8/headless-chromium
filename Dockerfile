#!/bin/bash

FROM arm32v7/node:latest

# Install dependencies
RUN apt-get update && apt-get install \
    --yes --no-install-recommends \
    curl wget nano gdebi sudo apt-transport-https gnupg \ 
    && apt-get update && apt-get install \
    --yes --no-install-recommends \
    ca-certificates fonts-liberation libappindicator3-1 libasound2 libatk-bridge2.0-0 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libgcc1 libglib2.0-0 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 lsb-release wget xdg-utils \
	&& apt-get update && apt-get install \
    --yes --no-install-recommends \
	fontconfig fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-symbola fonts-noto fonts-freefont-ttf

RUN mkdir -pv /etc/inti.d

COPY dependencies/chromium-common_90.0.4430.212-1~deb10u1_armhf.deb \
chromium-common.deb
COPY dependencies/chromium_90.0.4430.212-1~deb10u1_armhf.deb \
chromium.deb

RUN echo "Unpacking Dependencies (Chromium Common)" && \
dpkg --unpack chromium-common.deb

RUN echo "Unpacking Chromium..." && \
dpkg --unpack chromium.deb

# Install packages
RUN apt-get install -fy

RUN echo "Cleanup..." && \
    rm chromium-common.deb && rm chromium.deb

# Set default chromium flags
#COPY chromium-settings /.config/chrome-flags.conf
ENV CHROMIUM_FLAGS="$CHROMIUM_FLAGS --headless \
--debug \   
--enable-logging=stderr \
--v=1 \
--disable-dev-shm-usage \
--allow-insecure-localhost \
--remote-debugging-address=0.0.0.0 \
--remote-debugging-port=9222 \
--start-in-incognito \
--disable-gpu \
--single-process"

# Copy pulseaudio config
COPY pulse-client.conf /etc/pulse/client.conf

# Copy test scripts
COPY dependencies/puppeteer/puppeteer-screenshot.min.js ./screenshot.js
COPY dependencies/puppeteer/cdp.min.js ./cdp.js
COPY dependencies/puppeteer/puppeteer-launch.min.js ./launch.js

# Avoid idealTree error
WORKDIR /home/chromium

RUN npm i npm@7.14.0 \
    && npm i chrome-remote-interface \
    && npm i puppeteer \
    # Add chromium as a user
    && groupadd -r chromium && useradd -r -g chromium -G audio,video chromium \
    && mkdir -p /home/chromium/downloads \
    && chown -R chromium:chromium /home/chromium \
    && chown -R chromium:chromium /home/chromium/node_modules

EXPOSE 9222
ENV CHROMIUM_FLAGS="$CHROMIUM_FLAGS --user-data-dir=/home/chromium/downloads"
ENV CHROME_IPC_LOGGING=1
ENV CHROME_LOG_FILE=/chromium.log
ENV DBUS_SESSION_BUS_ADDRESS="disabled"
ENV DISPLAY=:1
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
ENV PUPPETEER_DOWNLOAD_PATH=/home/chromium/downloads

USER chromium

CMD ["/bin/bash", "chromium"]