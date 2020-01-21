#!/usr/bin/bash
# print command before executing, and exit when any command fails
set -xe

echo "This script should be run under Gnome Desktop Environment."
read -r -p "Are you sure to continue? [Y/n]" confirm
if [[ "$confirm" =~ ^(n|N) ]]; then
  exit
fi

# Add archlinuxcn repository
if ! grep 'archlinuxcn' /etc/pacman.conf &> /dev/null; then
  sudo tee -a /etc/pacman.conf <<EOF

[archlinuxcn]
SigLevel = Optional TrustedOnly
Server = https://mirrors.ustc.edu.cn/archlinuxcn/\$arch
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/\$arch
Server = http://mirrors.cqu.edu.cn/archlinux-cn/\$arch
Server = http://repo.archlinuxcn.org/\$arch
EOF
  sudo pacman -Syy
  sudo pacman -S --noconfirm archlinuxcn-keyring

  # Install AUR helper from archlinuxcn repo
  sudo pacman -S --noconfirm yay
  # Save yay options
  yay --save --answerclean None --answerdiff None --answeredit None
fi

sudo pacman -Syy

# Utils from archlinuxcn or AUR
yay -S --noconfirm besttrace

# Dotfiles
find dotfiles -type f -exec cp {} ~/ \;

# unzip-iconv
yes | yay -S unzip-iconv

# NTFS support
sudo pacman -S --noconfirm ntfs-3g

# Fonts
sudo pacman -S --noconfirm ttf-dejavu wqy-microhei noto-fonts-emoji adobe-source-code-pro-fonts adobe-source-han-sans-cn-fonts

# Web browsers
sudo pacman -S --noconfirm firefox
yay -S --noconfirm google-chrome

# Video Player
sudo pacman -S --noconfirm celluloid

# Gnome theme
yay -S --noconfirm numix-themes-darkblue numix-circle-icon-theme-git
gsettings set org.gnome.desktop.interface gtk-theme 'Numix-DarkBlue'
gsettings set org.gnome.desktop.interface icon-theme 'Numix-Circle-Light'
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

# automatic date and time
sudo systemctl enable systemd-timesyncd.service
# automatic timezone
gsettings set org.gnome.desktop.datetime automatic-timezone true
gsettings set org.gnome.desktop.interface clock-format '24h'

# Fcitx input method
sudo pacman -S --noconfirm fcitx-im fcitx-configtool
yay -S --noconfirm fcitx-sogoupinyin
cat <<EOF > ~/.pam_environment
XMODIFIERS DEFAULT=\@im=fcitx
GTK_IM_MODULE DEFAULT=fcitx
QT_IM_MODULE DEFAULT=fcitx
EOF
tar -zxf /archlinux-installer/sogou-qimpanel.tar.gz -C ~/.config/

# Sublime Text
curl -O https://download.sublimetext.com/sublimehq-pub.gpg && sudo pacman-key --add sublimehq-pub.gpg && sudo pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg
echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | sudo tee -a /etc/pacman.conf
sudo pacman -Syu sublime-text
if [[ ! -d ~/.config/sublime-text-3/ ]]; then
  # let subl initialize its config folder
  subl
  sleep 3
fi
rm -rf ~/.config/sublime-text-3/Packages/User/
git clone https://github.com/bianjp/sublime-settings.git ~/.config/sublime-text-3/Packages/User
# install package control
curl -sSL -o ~/.config/sublime-text-3/'Installed Packages'/'Package Control.sublime-package' 'https://packagecontrol.io/Package%20Control.sublime-package'

# Office
yay -S --noconfirm wps-office ttf-wps-fonts

# Set favorite apps in Activities
gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'firefox.desktop', 'sublime_text.desktop', 'google-chrome.desktop', 'gnome-system-monitor.desktop']"

# Developer softwares
# Nginx
sudo pacman -S --noconfirm nginx
sudo systemctl enable nginx

# MySQL
sudo pacman -S --noconfirm mariadb mariadb-clients
sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
sudo systemctl enable mysqld
sudo systemctl start mysqld
sudo mysql_secure_installation

# PostgreSQL
sudo pacman -S --noconfirm postgresql
sudo -i -u postgres initdb --locale "$LANG" -E UTF8 -D '/var/lib/postgres/data'
sudo systemctl start postgresql
sudo systemctl enable postgresql
sudo -i -u postgres createuser "$USER" --no-password --superuser

# PHP
# sudo pacman -S --noconfirm php php-fpm php-gd
# sudo systemctl enable php-fpm

# Node.js
sudo pacman -S --noconfirm nodejs npm yarn

# Ruby
sudo pacman -S --noconfirm ruby
source ~/.bash_profile
gem install bundler
bundle config mirror.https://rubygems.org https://gems.ruby-china.org

# Redis
sudo pacman -S --noconfirm redis
sudo systemctl enable redis

# Java
sudo pacman -S --noconfirm jdk10-openjdk openjdk10-doc openjdk10-src jdk8-openjdk openjdk8-doc openjdk8-src
sudo pacman -S --noconfirm gradle maven
sudo pacman -S --noconfirm kotlin
yay -S --noconfirm intellij-idea-ultimate-edition intellij-idea-ultimate-edition-jre

# SSH config
grep '^Host' /etc/ssh/ssh_config &> /dev/null || sudo tee -a /etc/ssh/ssh_config <<EOF
Host *
    ServerAliveCountMax 5
    ServerAliveInterval 10
EOF

read -r -p "Delete /archlinux-installer folder? [y/N]" confirm
if [[ "$confirm" =~ ^(y|Y) ]]; then
  sudo rm -rf /archlinux-installer
fi

echo "Finished successfully. It's recommended to reboot your systeml."
read -r -p "Reboot now? [Y/n]" confirm
if [[ ! "$confirm" =~ ^(n|N) ]]; then
  reboot
fi
