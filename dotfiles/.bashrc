#!/usr/bin/bash
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias la='ls -A --color=auto'
alias lh='ls -lh --color=auto'
alias lha='ls -lhA --color=auto'
alias ll='ls -l --color=auto'
alias lla='ls -Al --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias less='less -R'
alias 'ps?'='ps aux | grep -v grep | grep'
alias besttrace='besttrace -q 1'
alias u='yaourt -Syua'
alias 'pacman?'='pacman -Q | grep'
alias 'yum?'='yum list installed | grep'
alias 'apt?'='dpkg -l | grep'
alias 'history?'='history | grep'

alias sr='screen'
alias srs='screen -S'
alias srl='screen -ls'
alias srr='screen -r'

alias b='bundle exec'
alias sb='RAILS_ENV=staging bundle exec'
alias pb='RAILS_ENV=production bundle exec'
alias bi='bundle install'
alias bo='bundle outdated'
alias bu='bundle update'
alias br='bundle exec rake'
alias brc='bundle exec rubocop'
alias bc='bundle exec cap'
alias bcs='bundle exec cap staging'
alias bcsd='bundle exec cap staging deploy'
alias bcp='bundle exec cap production'
alias bcpd='bundle exec cap production deploy'

alias weather='curl wttr.in'

# Avoid garbled characters when unzip files ziped on Windows. Depend on package unzip-iconv
# Change the charset as needed
export UNZIP='-O gb18030'
export ZIPINFO="-O gb18030"

export HISTIGNORE='history*'
export EDITOR=vim
export PS1="\[$(tput sgr0)\][\[$(tput setaf 2)\]\u\[$(tput sgr0)\]@\[$(tput setaf 5)\]\h \[$(tput sgr0)\]\[$(tput setaf 6)\]\W\[$(tput sgr0)\]] \[$(tput sgr0)\]"

backup(){
  if [[ -d "$1" ]]; then
    cp -rf "$1"{,.bak}
  else
    cp "$1"{,.bak}
  fi
}

extract(){
  if [[ -f "$1" ]] ; then
    case $1 in
      *.tar.bz2) tar vxjf "$1" ;;
      *.tar.gz) tar vxzf "$1" ;;
      *.tar.xz) tar vxf "$1" ;;
      *.bz2) bzip2 "$1" ;;
      *.rar) unrar e "$1" ;;
      *.gz) gunzip "$1" ;;
      *.tar) tar vxf "$1" ;;
      *.tbz2) tar vxjf "$1" ;;
      *.tgz) tar vxzf "$1" ;;
      *.zip) unzip  "$1" ;;
      *.Z) uncompress "$1" ;;
      *.7z) 7z x "$1" ;;
      *) echo "'$1' cannot be extracted via extract()" ;;
      esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Show ip and geographic location
# supported params types:
#   none: show ip and location of current network
#   one or more ip/domain name seperated by space: show location of each ip address
ipinfo(){
  if [[ -z "$*" ]]; then
    curl -Ss http://myip.ipip.net | sed 's#当前 IP：##' | sed 's#来自于：##' | sed 's#\t\+# #g'
    return
  fi

  ips=
  for ip in "$@"; do
    # IP
    if [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
      ips="$ips $ip"
    # Domain
    else
      new_ips=$(host "$ip" | grep 'has address' | cut -d' ' -f4)
      ips="$ips $new_ips"
    fi
  done

  count=$(echo "$ips" | gawk 'END{print NF}')
  i=0
  for ip in $ips; do
    info=$(curl -Ss http://freeapi.ipip.net/"$ip" |
           sed -r \
               -e 's#(\[|]|")##g' \
               -e 's#[,]{2,}#,#g' \
               -e 's#,$##' \
               -e 's#,#, #g' \
         )

    i=$((i + 1))
    # there is a an rate limit for the api access
    # https://www.ipip.net/download.html
    if [[ "$i" < "$count" ]]; then
      sleep 1
    fi

    echo "$ip  $info"
  done
}

# get absolute path
fullpath(){
  readlink -e "$1"
}

# show listening port
port(){
  sudo ss -tulpn | gawk '{printf "%-6s %-9s %-19s %s\n", $1, $2, $5, $7}'
}

hex2rgb(){
  value=$1
  if [ -z "$value" ]; then
    return 1
  fi
  value=${value//#/}
  if [[ "$value" =~ [0-9a-zA-Z]{3} || "$value" =~ [0-9a-zA-Z]{6} ]]; then
    python -c "value = '$value'; \
      print(len(value) == 3 and tuple(int(value[i] * 2, 16) for i in (0, 1, 2)) or tuple(int(value[i:i+2], 16) for i in (0, 2, 4)));"
  else
    echo "Invalid color"
  fi
}

random_password(){
  length=${1:-10}
  which openssl &> /dev/null && (openssl rand -base64 "$length" | head -c "$length") && echo
  < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c"${1:-$length}" && echo
}

[[ -f "$HOME/.bashrc_extra" ]] && source "$HOME/.bashrc_extra"
