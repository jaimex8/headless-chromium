#!/bin/bash

# Script must be run as root
if (( $EUID != 0 )); then
        echo "Please run as root. Exiting..."
        sleep 3
        exit
fi

printMsg() {
        echo
        echo $1
        sleep 0.5
}

printMsg "Making sure dependencies are in place..."
apt install -qq wget &> /dev/null

printMsg "To get the latest widevine library we must download the entire 2gb ChromeOS recovery image (will later be deleted). Please be patient, this may take a while..."
echo
echo
CHROMEOS_URL="https://dl.google.com/dl/edgedl/chromeos/recovery/chromeos_12739.111.0_cyan_recovery_stable-channel_mp-v3.bin.zip"
CHROMEOS_IMG="$(basename "$CHROMEOS_URL" .zip)"
echo "$CHROMEOS_URL"
echo "$CHROMEOS_IMG"
wget -O - "$CHROMEOS_URL" --no-check-certificate | zcat > "$CHROMEOS_IMG"

printMsg "Mounting the image to pull the files from it..."
mkdir -p chromeos_tmp
LOOPDEV="$(losetup -f)"
losetup -Pf "$CHROMEOS_IMG"
mount -o ro "${LOOPDEV}p3" chromeos_tmp

printMsg "Updating widevine..."
cp chromeos_tmp/opt/google/chrome/libwidevinecdm.so /usr/lib/chromium-browser
cp chromeos_tmp/opt/google/chrome/pepper /usr/lib/chromium-browser -r

printMsg "Cleaning up..."
umount chromeos_tmp
losetup -d "$LOOPDEV"
rm -f "$CHROMEOS_IMG"
rm -fr chromeos_tmp

printMsg "Widevine Updater Completed"
sleep 5
