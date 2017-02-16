#!/bin/bash

set -eo pipefail

__compress() {
	cd /coreos-base
	tar c * | xz --best	> /coreos-${1}-${release:-$2}.tar.xz
	tar cC / "coreos-${1}-${release:-$2}.tar"*
}

__detect_current() {
	curl -sL http://$1.release.core-os.net/amd64-usr/ | grep '[dir]' | grep -B1 'current/' | head -1 | awk -F'href="' '{print $2}' | cut -f1 -d/
}

__prepare() {
	local version=$1
	local release=$2
	mkdir /coreos-base
	pushd /coreos-base
	dnf install -y curl tar squashfs-tools cpio xz
	[[ $release = 'current' ]] && release=$(__detect_current $version)
	curl -sL http://$version.release.core-os.net/amd64-usr/$release/coreos_production_pxe_image.cpio.gz | zcat | cpio -idmv
	unsquashfs -no-xattrs usr.squashfs
	rm usr.squashfs
	mv squashfs-root usr
	ln -s usr/lib   lib
	ln -s usr/lib64 lib64
	ln -s usr/sbin  sbin
	ln -s usr/bin   bin
	chroot /coreos-base <<'__prepare'
systemctl mask systemd-remount-fs.service dev-hugepages.mount sys-fs-fuse-connections.mount
rm -f /etc/machine-id
touch /etc/machine-id
__prepare
	popd
}

__cleanup() {
	chroot /coreos-base <<'__cleanup'
rm -rf usr/boot usr/lib/modules
__cleanup
}

__prepare "$@" >&2
__cleanup >&2
__compress "$@"