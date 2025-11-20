#!/bin/sh

set -eux

ARCH="$(uname -m)"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"

export VERSION="$(cat ~/version)"
export ADD_HOOKS="self-updater.bg.hook"
export ICON=/usr/share/icons/hicolor/scalable/apps/lmms.svg
export DESKTOP=/usr/share/applications/lmms.desktop
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export DEPLOY_PIPEWIRE=1
export DEPLOY_OPENGL=1
export DEPLOY_SYS_PYTHON=1
export EXEC_WRAPPER=1
export OUTPATH=./dist

# Deploy dependencies
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun
./quick-sharun \
	/usr/bin/lmms             \
	/usr/lib/lmms             \
	/usr/bin/carla*           \
	/usr/lib/carla            \
	/usr/share/carla          \
	/usr/lib/carla/jack/*     \
	/usr/lib/carla/styles/*   \
	/usr/lib/alsa-lib/*jack*  \
	/usr/lib/alsa-lib/*pulse*

sed -i \
	-e 's|INSTALL_PREFIX="/usr"|INSTALL_PREFIX="$APPDIR"|g' \
	-e 's|which python3|command -v python3|g'               \
	./AppDir/lib/carla/carla-*-modgui ./AppDir/bin/carla*

# MAKE APPIMAGE WITH URUNTIME
./quick-sharun --make-appimage
