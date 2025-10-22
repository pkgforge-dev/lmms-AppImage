#!/bin/sh

set -eux

ARCH="$(uname -m)"
EXTRA_PACKAGES="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/get-debloated-pkgs.sh"

pacman -Syu --noconfirm \
	base-devel       \
	carla            \
	curl             \
	git              \
	lame             \
	libxcb           \
	libxcursor       \
	libxi            \
	libxkbcommon     \
	libxkbcommon-x11 \
	libxrandr        \
	libxtst          \
	pipewire-audio   \
	pulseaudio       \
	pulseaudio-alsa  \
	qt5ct            \
	qt5-wayland      \
	wget             \
	xorg-server-xvfb \
	zsync

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
wget --retry-connrefused --tries=30 "$EXTRA_PACKAGES" -O ./get-debloated-pkgs.sh
chmod +x ./get-debloated-pkgs.sh
./get-debloated-pkgs.sh --add-mesa --prefer-nano opus-mini

echo "Building lmms..."
echo "---------------------------------------------------------------"
sed -i -e 's|EUID == 0|EUID == 69|g' /usr/bin/makepkg
sed -i \
	-e 's|-O2|-O3|'                              \
	-e 's|MAKEFLAGS=.*|MAKEFLAGS="-j$(nproc)"|'  \
	-e 's|#MAKEFLAGS|MAKEFLAGS|'                 \
	/etc/makepkg.conf
cat /etc/makepkg.conf

echo '[multilib]
Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf

# We need wine32 first
git clone --depth 1 https://aur.archlinux.org/wine32.git ./wine32 && (
	cd ./wine32
	sed -i -e "s|x86_64|$ARCH|" ./PKGBUILD
	cat ./PKGBUILD
	makepkg -fs --noconfirm
	ls -la .
	pacman --noconfirm -U ./*.pkg.tar.*
)

git clone --depth 1 https://aur.archlinux.org/lmms-git.git ./lmms && (
	cd ./lmms
	sed -i \
		-e "s|x86_64|$ARCH|"   \
		-e "s|'wine|'wine32|g" \
		./PKGBUILD
	cat ./PKGBUILD
	makepkg -fs --noconfirm
	ls -la .
	pacman --noconfirm -U ./*.pkg.tar.*
)

pacman -Q lmms-git | awk '{print $2; exit}' > ~/version
