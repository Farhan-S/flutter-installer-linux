#!/bin/bash

# Flutter version and install location
FLUTTER_VERSION="3.41.0-stable"
FLUTTER_TAR="flutter_linux_${FLUTTER_VERSION}.tar.xz"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_TAR}"
INSTALL_DIR="/opt/flutter"

echo "==> Updating system packages..."
sudo dnf update -y

echo "==> Installing dependencies..."
sudo dnf install -y curl git unzip xz zip mesa-libGLU
sudo dnf install -y glibc.x86_64 libstdc++.x86_64 glibc.i686 bzip2-libs.x86_64

echo "==> Checking and installing Linux development toolchain..."
PACKAGES_TO_INSTALL=()

command -v clang++ >/dev/null 2>&1 || PACKAGES_TO_INSTALL+=(clang)
command -v cmake >/dev/null 2>&1 || PACKAGES_TO_INSTALL+=(cmake)
command -v ninja >/dev/null 2>&1 || PACKAGES_TO_INSTALL+=(ninja-build)
pkg-config --exists gtk+-3.0 >/dev/null 2>&1 || PACKAGES_TO_INSTALL+=(gtk3-devel)
command -v eglinfo >/dev/null 2>&1 || PACKAGES_TO_INSTALL+=(mesa-demos)

if [ ${#PACKAGES_TO_INSTALL[@]} -gt 0 ]; then
    echo "Installing: ${PACKAGES_TO_INSTALL[@]}"
    sudo dnf install -y "${PACKAGES_TO_INSTALL[@]}"
else
    echo "All Linux development tools already installed."
fi

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
