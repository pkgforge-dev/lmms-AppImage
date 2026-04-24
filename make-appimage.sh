#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q lmms-git | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook:host-libjack.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/scalable/apps/lmms.svg
export DESKTOP=/usr/share/applications/lmms.desktop
export DEPLOY_PIPEWIRE=1
export DEPLOY_OPENGL=1
export DEPLOY_PYTHON=1

# Deploy dependencies
quick-sharun \
	/usr/bin/lmms             \
	/usr/lib/lmms             \
	/usr/lib/libsuil*.so*     \
	/usr/lib/suil-*/*x11.so*  \
	/usr/lib/suil-*/*qt5.so*  \
	/usr/bin/carla*           \
	/usr/lib/carla            \
	/usr/share/carla          \
	/usr/lib/alsa-lib/*jack*  \
	/usr/lib/alsa-lib/*pulse*

sed -i \
	-e 's|INSTALL_PREFIX="/usr"|INSTALL_PREFIX="$APPDIR"|g' \
	-e 's|which python3|command -v python3|g'               \
	./AppDir/lib/carla/carla-*-modgui ./AppDir/bin/carla*

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --test ./dist/*.AppImage
