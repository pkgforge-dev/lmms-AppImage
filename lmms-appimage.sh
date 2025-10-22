#!/bin/sh

set -eux

ARCH="$(uname -m)"
URUNTIME="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"
VERSION="$(cat ~/version)"

export ADD_HOOKS="self-updater.bg.hook"
export ICON=/usr/share/icons/hicolor/scalable/apps/lmms.svg
export DESKTOP=/usr/share/applications/lmms.desktop
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export DEPLOY_PIPEWIRE=1
export DEPLOY_OPENGL=1
export DEPLOY_PYTHON=1
export OUTNAME=lmms-"$VERSION"-anylinux-"$ARCH".AppImage

# Deploy dependencies
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun
./quick-sharun /usr/bin/lmms -- --allowroot
./quick-sharun \
	/usr/lib/lmms/*    \
	/usr/lib/lmms/*/*  \
	/usr/bin/carla*    \
	/usr/lib/carla/*   \
	/usr/lib/carla/*/*

# TODO remove me once quick-sharun add carla deployment
cp -r /usr/share/carla ./AppDir/share
cp -rn /usr/lib/carla  ./AppDir/lib

sed -i \
	-e 's|INSTALL_PREFIX="/usr"|INSTALL_PREFIX="$APPDIR"|' \
	./AppDir/lib/carla/carla-bridge-lv2-modgui ./AppDir/bin/carla*

echo "Sharunning the carla binaries..."
bins_to_find="$(find ./AppDir/lib/carla -exec file {} \; | grep -i 'elf.*executable' | awk -F':' '{print $1}')"
for plugin in $bins_to_find; do
	mv -v "$plugin" ./AppDir/shared/bin && ln -f ./AppDir/sharun "$plugin"
	echo "Sharan $plugin"
done

# MAKE APPIMAGE WITH URUNTIME
wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime2appimage
chmod +x ./uruntime2appimage
./uruntime2appimage

mkdir -p ./dist
mv -v ./*.AppImage* ./dist
mv -v ~/version     ./dist
