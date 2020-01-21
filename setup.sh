#!/usr/bin/bash
# print command before executing, and exit when any command fails
set -xe

hostname=arch
# regular user name
username=arch
# password for regular user. Password for root will not be set
password=123456

# Timezone
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc --utc

# Locale
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
sed -i 's/^#zh_CN/zh_CN/g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Hostname
echo $hostname > /etc/hostname

# Install intel-ucode for Intel CPU
is_intel_cpu=$(lscpu | grep 'Intel' &> /dev/null && echo 'yes' || echo '')
if [[ -n "$is_intel_cpu" ]]; then
  pacman -S --noconfirm intel-ucode
fi

# Bootloader
# Use system-boot for EFI mode, and grub for others
if [[ -d "/sys/firmware/efi/efivars" ]]; then
  bootctl install

  cat <<EOF > /boot/loader/entries/arch.conf
    title      Arch Linux
    linux      /vmlinuz-linux
    initrd     /intel-ucode.img
    initrd     /initramfs-linux.img
    options    root=/dev/sda2 rw
EOF

  cat <<EOF > /boot/loader/loader.conf
    default arch
    timeout 3
    editor no
EOF

  if [[ -z "$is_intel_cpu" ]]; then
    sed -i '/intel-ucode/d' /boot/loader/entries/arch.conf
  fi

  # remove leading spaces
  sed -i 's#^ \+##g' /boot/loader/entries/arch.conf
  sed -i 's#^ \+##g' /boot/loader/loader.conf

  # modify root partion in loader conf
  root_partition=$(mount  | grep 'on / ' | cut -d' ' -f1)
  root_partition=$(df / | tail -1 | cut -d' ' -f1)
  sed -i "s#/dev/sda2#$root_partition#" /boot/loader/entries/arch.conf
else
  disk=$(df / | tail -1 | cut -d' ' -f1 | sed 's#[0-9]\+##g')
  pacman --noconfirm -S grub os-prober
  grub-install --target=i386-pc "$disk"
  grub-mkconfig -o /boot/grub/grub.cfg
fi

# Config sudo
# allow users of group wheel to use sudo
sed -i 's/^# %wheel ALL=(ALL) ALL$/%wheel ALL=(ALL) ALL/' /etc/sudoers

# Create regular user
useradd -m -g users -G wheel -s /bin/bash $username
echo "$username:$password" | chpasswd

# Desktop Environment
# xorg
pacman -S --noconfirm xorg-server

# graphics driver
nvidia=$(lspci | grep -e VGA -e 3D | grep 'NVIDIA' 2> /dev/null || echo '')
amd=$(lspci | grep -e VGA -e 3D | grep 'AMD' 2> /dev/null || echo '')
intel=$(lspci | grep -e VGA -e 3D | grep 'Intel' 2> /dev/null || echo '')
if [[ -n "$nvidia" ]]; then
  pacman -S --noconfirm nvidia
fi

if [[ -n "$amd" ]]; then
  pacman -S --noconfirm xf86-video-amdgpu
fi

if [[ -n "$intel" ]]; then
  pacman -S --noconfirm xf86-video-intel
fi

if [[ -n "$nvidia" && -n "$intel" ]]; then
  pacman -S --noconfirm bumblebee
  gpasswd -a $username bumblebee
  systemctl enable bumblebeed
fi

# touchpad driver
# Seem no more needed as xf86-input-libinput can be a drop-in replacement
# if grep -q 'Synaptics TouchPad' /proc/bus/input/devices; then
#   pacman -S --noconfirm xf86-input-synaptics
# fi

# gnome
pacman -S --noconfirm gdm gnome-shell gnome-shell-extensions gnome-keyring seahorse gnome-backgrounds \
  gnome-control-center gnome-font-viewer gnome-screenshot xdg-user-dirs-gtk \
  gnome-power-manager gnome-system-monitor gnome-terminal nautilus gvfs-mtp eog evince \
  file-roller gnome-tweaks networkmanager

# Native browser connector for integration with extensions.gnome.org
pacman -S --noconfirm chrome-gnome-shell

# start gnome by default
systemctl enable gdm
systemctl enable NetworkManager

# compression/decompression tools
pacman -S --noconfirm unrar p7zip

# useful shell utils
pacman -S --noconfirm bash-completion vim bind-tools dos2unix rsync wget git openssh imagemagick tree
pacman -S --noconfirm net-tools whois screen inotify-tools perl-rename recode
pacman -S --noconfirm openbsd-netcat

# Use vim instead vi
pacman -Rsnc vi
ln -s /usr/bin/vim /usr/local/bin/vi
