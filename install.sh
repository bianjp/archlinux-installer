#!/usr/bin/bash
# exit when any command fails
set -e

read -r -p "Have you already partitioned your disk, built filesystem, and mounted to /mnt correctly? [y/N]" confirm
if [[ ! "$confirm" =~ ^(y|Y) ]]; then
  exit
fi

update_mirrorlist(){
  curl -sSL 'https://www.archlinux.org/mirrorlist/?country=CN&protocol=http&protocol=https&ip_version=4&use_mirror_status=on' | sed 's/^#Server/Server/g' | rankmirrors - > /etc/pacman.d/mirrorlist
}

while true; do
  update_mirrorlist
  cat /etc/pacman.d/mirrorlist
  read -r -p "Is this mirrorlist OK? [Y/n]" confirm
  if [[ ! "$confirm" =~ ^(n|N) ]]; then
    break
  fi
done

pacman -Syy

# Install the base packages
pacstrap -i /mnt base base-devel --noconfirm

# Generate fstab
genfstab -U -p /mnt >> /mnt/etc/fstab

# Setup new system
mkdir /mnt/archlinux-installer
cp -r ./* /mnt/archlinux-installer/
arch-chroot /mnt /archlinux-installer/setup.sh

if [[ "$?" == "0" ]]; then
  echo "Finished successfully."
  read -r -p "Reboot now? [Y/n]" confirm
  if [[ ! "$confirm" =~ ^(n|N) ]]; then
    reboot
  fi
fi
