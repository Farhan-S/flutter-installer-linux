#!/bin/bash

# Flutter version and install location
FLUTTER_VERSION="3.32.0-stable"
FLUTTER_TAR="flutter_linux_${FLUTTER_VERSION}.tar.xz"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_TAR}"
INSTALL_DIR="/opt/flutter"

echo "==> Updating system packages..."
sudo apt-get update -y && sudo apt-get upgrade -y

echo "==> Installing dependencies..."
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa
sudo apt-get install -y libc6:amd64 libstdc++6:amd64 lib32z1 libbz2-1.0:amd64

echo "==> Downloading Flutter SDK..."
curl -o ~/Downloads/${FLUTTER_TAR} ${FLUTTER_URL}

echo "==> Extracting Flutter SDK to ${INSTALL_DIR}..."
sudo mkdir -p ${INSTALL_DIR}
sudo tar -xf ~/Downloads/${FLUTTER_TAR} -C ${INSTALL_DIR} --strip-components=1
sudo chown -R $(whoami):$(whoami) ${INSTALL_DIR}

echo "==> Detecting your shell..."
CURRENT_SHELL=$(basename "$SHELL")
FLUTTER_PATH="export PATH=\"${INSTALL_DIR}/bin:\$PATH\""

if [[ "$CURRENT_SHELL" == "bash" ]]; then
    PROFILE_FILE="$HOME/.bash_profile"
    echo "$FLUTTER_PATH" >> "$PROFILE_FILE"
    echo "=> Added Flutter to PATH in $PROFILE_FILE"
elif [[ "$CURRENT_SHELL" == "zsh" ]]; then
    PROFILE_FILE="$HOME/.zshenv"
    echo "$FLUTTER_PATH" >> "$PROFILE_FILE"
    echo "=> Added Flutter to PATH in $PROFILE_FILE"
else
    echo "⚠️ Unknown shell. Please manually add the following line to your shell config file:"
    echo "$FLUTTER_PATH"
fi

echo "==> Reloading your shell environment..."
source "$PROFILE_FILE"

echo "==> Verifying Flutter installation..."
flutter --version

echo "==> Accepting Android licenses..."
flutter doctor --android-licenses

echo "==> Running flutter doctor..."
flutter doctor

echo "✅ Flutter installation completed successfully!"
