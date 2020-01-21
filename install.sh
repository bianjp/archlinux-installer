#!/usr/bin/bash
# print command before executing, and exit when any command fails
set -xe

# Update the system clock
timedatectl set-ntp true

read -r -p "Have you already partitioned your disk, built filesystem, and mounted to /mnt correctly? [y/N]" confirm
if [[ ! "$confirm" =~ ^(y|Y) ]]; then
  exit
fi

pacman -S pacman-contrib

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
pacstrap /mnt base base-devel
pacstrap /mnt base linux linux-firmware


# Generate fstab
genfstab /mnt >> /mnt/etc/fstab

# Setup new system
rm -rf /mnt/archlinux-installer && mkdir /mnt/archlinux-installer
cp -r ./* /mnt/archlinux-installer/
arch-chroot /mnt /archlinux-installer/setup.sh

if [[ "$?" == "0" ]]; then
  echo "Finished successfully."
  read -r -p "Reboot now? [Y/n]" confirm
  if [[ ! "$confirm" =~ ^(n|N) ]]; then
    reboot
  fi
fi
