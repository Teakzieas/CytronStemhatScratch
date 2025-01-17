#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root. Re-running with sudo..."
    sudo "$0" "$@"
    exit $?
fi

# Detect architecture
ARCH=$(dpkg --print-architecture)

# Map architecture to .deb file
case $ARCH in
    armhf)
        FILE="Scratch3-Pi4-32.deb"
        ;;
    arm64)
        FILE="Scratch3-Pi4-64.deb"
        ;;
    i386)
        FILE="Scratch3-Pi5-32.deb"
        ;;
    amd64)
        FILE="Scratch3-Pi5-64.deb"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac
# Download the appropriate .deb file from GitHub
REPO_URL="https://raw.githubusercontent.com/Teakzieas/CytronStemhatScratch/main/Dist"
wget -q "${REPO_URL}/${FILE}" -O "/tmp/${FILE}"

# Install the .deb file
if [ -f "/tmp/${FILE}" ]; then
    apt install -y "/tmp/${FILE}"
    rm "/tmp/${FILE}" # Clean up after installation
else
    echo "Failed to download the .deb file."
    exit 1
fi

# Run your desired command
pigpiod
