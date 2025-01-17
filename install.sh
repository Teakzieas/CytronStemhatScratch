#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root. Re-running with sudo..."
    sudo "$0" "$@"
    exit $?
fi

# Detect architecture
ARCH=$(dpkg --print-architecture)

# Map architecture to the appropriate .deb file based on the detected architecture
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

# Base URL for downloading .deb files
REPO_URL="https://github.com/Teakzieas/CytronStemhatScratch/releases/download/V1,0"

# Check if Scratch3 is already installed
if dpkg -l | grep -q "scratch3"; then
    echo "An existing version of Scratch3 is detected. Removing it..."
    apt remove -y scratch3 &>/dev/null
    if [ $? -ne 0 ]; then
        echo "Error: Failed to remove the existing version of Scratch3."
        exit 1
    fi
    echo "Existing version of Scratch3 removed successfully."
fi

# Download the appropriate .deb file and show a progress bar
echo "Downloading ${FILE}..."
wget --show-progress -q "${REPO_URL}/${FILE}" -O "/tmp/${FILE}"
if [ $? -ne 0 ]; then
    echo "Error: Failed to download ${FILE}."
    exit 1
fi

# Install the downloaded .deb file silently
echo "Installing ${FILE}..."
DEBIAN_FRONTEND=noninteractive apt install -y "/tmp/${FILE}" &>/dev/null
if [ $? -ne 0 ]; then
    echo "Error: Failed to install ${FILE}."
    rm -f "/tmp/${FILE}" # Clean up
    exit 1
fi

# Clean up the downloaded file
rm -f "/tmp/${FILE}"
echo "${FILE} installation completed successfully."

# Enable I2C on Raspberry Pi
echo "Enabling I2C..."
raspi-config nonint do_i2c 0
if [ $? -ne 0 ]; then
    echo "Error: Failed to enable I2C. Please check your configuration."
    exit 1
fi

echo "I2C enabled successfully."

# Run the pigpio daemon
echo "Starting pigpio daemon..."
if command -v pigpiod &>/dev/null; then
    pigpiod
    echo "pigpiod started successfully."
else
    echo "Error: pigpiod command not found. Ensure pigpio is installed."
    exit 1
fi
