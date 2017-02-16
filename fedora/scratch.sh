#!/bin/bash
set -eo pipefail
__bootstrap() {
	dnf install --releasever=rawhide --installroot=/docker-base --setopt=install_weak_deps=no --assumeyes bash tar dnf dnf-yum fedora-release rootfiles sssd-client vim-minimal	glibc-minimal-langpack
	dnf install --assumeyes tar xz
}

__cleanup() {
	chroot /docker-base <<'__cleanup'
LANG="C"
echo "%_install_langs $LANG" > /etc/rpm/macros.image-language-conf

# https://bugzilla.redhat.com/show_bug.cgi?id=1400682
echo "Import RPM GPG key"
releasever=$(rpm -q --qf '%{version}\n' fedora-release)
basearch=$(uname -i)
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$releasever-$basearch

echo "# fstab intentionally empty for containers" > /etc/fstab

# remove some extraneous files
rm -rf /usr/share/doc/*
rm -rf /usr/share/man/*
rm -rf /var/cache/dnf/*
rm -rf /tmp/*

#Mask mount units and getty service so that we don't get login prompt
systemctl mask systemd-remount-fs.service dev-hugepages.mount sys-fs-fuse-connections.mount systemd-logind.service getty.target console-getty.service

# https://bugzilla.redhat.com/show_bug.cgi?id=1343138
# Fix /run/lock breakage since it's not tmpfs in docker
# This unmounts /run (tmpfs) and then recreates the files
# in the /run directory on the root filesystem of the container
umount /run
systemd-tmpfiles --create --boot

# Remove machine-id on pre generated images
rm -f /etc/machine-id
touch /etc/machine-id
__cleanup
}

__compress() {
	cd /docker-base
	tar c * | xz -9e
}

__bootstrap >&2
__cleanup >&2
__compress