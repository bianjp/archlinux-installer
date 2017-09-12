#!/usr/bin/bash
# print command before executing, and exit when any command fails
set -xe

echo "This script should be run under Gnome Desktop Environment."
read -r -p "Are you sure to continue? [Y/n]" confirm
if [[ "$confirm" =~ ^(n|N) ]]; then
  exit
fi

sudo pacman -Syy

# Dotfiles
find dotfiles -type f -exec cp {} ~/ \;

# yaourt. Provided by archlinuxcn repo
sudo pacman -S --noconfirm yaourt
# don't bother to prompt whether to edit PKGBUILD when installing aur package
sudo sed -i 's/^#EDITFILES.\+/EDITFILES=0/' /etc/yaourtrc

# unzip-iconv
yes | yaourt -S unzip-iconv

# NTFS support
sudo pacman -S --noconfirm ntfs-3g

# Fonts
sudo pacman -S --noconfirm ttf-dejavu wqy-microhei noto-fonts-emoji

# Web browsers
sudo pacman -S --noconfirm firefox flashplugin
yaourt -S --noconfirm google-chrome

# Video Player
sudo pacman -S --noconfirm gnome-mplayer

# Gnome theme
yaourt -S --noconfirm numix-gtk-theme numix-circle-icon-theme-git
gsettings set org.gnome.desktop.interface gtk-theme 'Numix'
gsettings set org.gnome.desktop.interface icon-theme 'Numix-Circle-Light'
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
cat <<EOF > ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-application-prefer-dark-theme=1
EOF

# automatic date and time
sudo systemctl enable systemd-timesyncd.service
# automatic timezone
gsettings set org.gnome.desktop.datetime automatic-timezone true
gsettings set org.gnome.desktop.interface clock-format '24h'

# Fcitx input method
sudo pacman -S --noconfirm fcitx-im fcitx-configtool
yaourt -S --noconfirm fcitx-sogoupinyin
cat <<EOF > ~/.xprofile
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"

gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "{'Gtk/IMModule':<'fcitx'>}"
EOF
tar -zxf /archlinux-installer/sogou-qimpanel.tar.gz -C ~/.config/

# Sublime Text
yaourt -S --noconfirm sublime-text-dev-imfix2
sudo pacman -S --noconfirm gksu
if [[ ! -d ~/.config/sublime-text-3/ ]]; then
  # let subl initialize its config folder
  subl3
  sleep 3
fi
rm -rf ~/.config/sublime-text-3/Packages/User/
git clone https://github.com/bianjp/sublime-settings.git ~/.config/sublime-text-3/Packages/User
# install package control
curl -sSL -o ~/.config/sublime-text-3/'Installed Packages'/'Package Control.sublime-package' 'https://packagecontrol.io/Package%20Control.sublime-package'

# Office
sudo yaourt -S --noconfirm wps-office

# Reflector-timer
yaourt -S --noconfirm reflector-timer-weekly
sudo systemctl enable reflector.timer

# Set favorite apps in Activities
gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'firefox.desktop', 'sublime_text_3.desktop', 'google-chrome.desktop', 'gnome-system-monitor.desktop']"

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
sudo pacman -S postgresql
sudo -i -u postgres initdb --locale "$LANG" -E UTF8 -D '/var/lib/postgres/data'
sudo systemctl start postgresql
sudo systemctl enable postgresql
sudo -i -u postgres createuser "$USER" --no-password --superuser

# PHP
sudo pacman -S --noconfirm php php-fpm php-gd
sudo systemctl enable php-fpm

# Node.js
sudo pacman -S --noconfirm nodejs npm

# Ruby
sudo pacman -S --noconfirm ruby
source ~/.bash_profile
gem install bundler
bundle config mirror.https://rubygems.org https://gems.ruby-china.org

# Redis
sudo pacman -S --noconfirm redis
sudo systemctl enable redis

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
