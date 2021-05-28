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
	fontconfig \
	fonts-ipafont-gothic \
	fonts-wqy-zenhei \
	fonts-thai-tlwg \
	fonts-kacst \
	fonts-symbola \
	fonts-noto \
	fonts-freefont-ttf

#RUN mkdir -pv /var/run/dbus

#RUN touch /var/run/dbus/system_bus_socket

RUN mkdir -pv /etc/inti.d

#RUN sysctl -w kernel.unprivileged_userns_clone=1

#COPY dependencies/chromium-common_90.0.4430.212-1~deb10u1_armhf.deb \
#chromium-common.deb
#COPY dependencies/chromium-driver_90.0.4430.212-1~deb10u1_armhf.deb \
#chrome-driver.deb
#COPY dependencies/chromium-sandbox_90.0.4430.212-1~deb10u1_armhf.deb \
#chromium-sandbox.deb
#COPY dependencies/chromium-shell_90.0.4430.212-1~deb10u1_armhf.deb \
#chromium-shell.deb
COPY dependencies/chromium_90.0.4430.212-1~deb10u1_armhf.deb \
chromium.deb

#xvfb workaround
#COPY dependencies/xvfbd /etc/init.d/xvfbd
#RUN chmod 0755 /etc/init.d/xvfbd
#RUN update-rc.d xvfbd defaults

#RUN echo "Installing Dependencies (Chromium Common)" && \
#dpkg --unpack chromium-common.deb

#RUN echo "Installing Dependencies (Chromium Driver)" && \
#dpkg --unpack chrome-driver.deb

#RUN echo "Installing Dependencies (Chromium Sandbox)" && \
#dpkg --unpack chromium-sandbox.deb

#RUN echo "Installing Dependencies (Chromium Shell)" && \
#dpkg --unpack chromium-shell.deb

RUN echo "Updating Chromium..." && \
dpkg --unpack chromium.deb

# Install packages
RUN apt-get install -fy

# Copy chromium settings
#COPY chromium-settings /.config/chrome-flags.conf
ENV CHROMIUM_FLAGS="$CHROMIUM_FLAGS --debug \   
--enable-logging=stderr \
--headless \
--v=1 \
--disable-dev-shm-usage \
--allow-insecure-localhost \
--remote-debugging-address=0.0.0.0 \
--remote-debugging-port=9222 \
--start-in-incognito \
--disable-gpu \
--user-data-dir=/home/chromium/downloads \
--single-process"

# Copy Pulseaudio config
#COPY pulse-client.conf /etc/pulse/client.conf

#Avoid idealTree error
WORKDIR /home/chromium

COPY dependencies/puppet-start.js ./puppeteer.js
COPY dependencies/puppet-start.min.js ./puppeteer-min.js
COPY dependencies/cdp.js ./cdp.js
COPY dependencies/cdp.min.js ./cdp.min.js

RUN npm i npm@7.14.0 \
    && npm i chrome-remote-interface \
    && npm i puppeteer \
    # Add Chrome as a user
    && groupadd -r chromium && useradd -r -g chromium -G audio,video chromium \
    && mkdir -p /home/chromium/downloads \
    && chown -R chromium:chromium /home/chromium \
    && chown -R chromium:chromium /home/chromium/node_modules

EXPOSE 9222
ENV CHROME_IPC_LOGGING=1
ENV CHROME_LOG_FILE=/chromium.log
ENV DBUS_SESSION_BUS_ADDRESS="disabled"
ENV DISPLAY=:1
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
ENV PUPPETEER_DOWNLOAD_PATH=/home/chromium/downloads
#ENV CHROME_DEVEL_SANDBOX=/usr/local/sbin/chromium-devel-sandbox

USER chromium

#ENTRYPOINT [ "/bin/bash -c" ]
CMD ["/bin/bash", "chromium"]
#CMD [ "npm", "start" ]
#CMD [ "node", "puppeteer.js" ]