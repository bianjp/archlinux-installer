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
alias tree="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'"
alias less='less -R'
alias ps?='ps aux | grep'
alias pacman?='pacman -Q | grep'
alias history?='history | grep'

alias sr='screen'
alias srs='screen -S'
alias srl='screen -ls'
alias srr='screen -r'

alias pc='proxychains'
alias b='bundle exec'
alias db='mysql -uroot -proot'
alias weather='curl wttr.in'

# Avoid garbled characters when unzip files ziped on Windows. Depend on package unzip-iconv
export UNZIP='-O gb18030'
export ZIPINFO="-O gb18030"

export HISTIGNORE=history*
export PYTHONSTARTUP=~/.pythonrc

export PS1="\[\e[00;37m\][\[\e[0m\]\[\e[00;32m\]\u\[\e[0m\]\[\e[00;37m\]@\[\e[0m\]\[\e[00;35m\]\h\[\e[0m\]\[\e[00;37m\] \[\e[0m\]\[\e[00;36m\]\W\[\e[0m\]\[\e[00;37m\]]\\$ \[\e[0m\]"

# Ruby and RVM
if [[ -d "$HOME/.rvm/bin" && -s "$HOME/.rvm/scripts/rvm" ]]; then
  if [[ "$PATH" != *.rvm/bin* ]]; then
    export PATH="$PATH:$HOME/.rvm/bin"
  fi
  source "$HOME/.rvm/scripts/rvm"
elif [[ -n "`which ruby`" ]]; then
  export GEM_HOME=~/.gem/ruby/"`ruby -v | cut -d' ' -f2 | cut -d'.' -f1,2`"
  export PATH="$PATH":"$GEM_HOME"/bin
fi

which go &> /dev/null && {
  export GOPATH=~/.go
  export PATH="$PATH":~/.go/bin
}

mcd(){
  mkdir -p "$1"
  cd "$1"
}

cls(){
  cd "$1"
  ls
}

backup(){
  if [[ -d "$1" ]]; then
    cp -rf "$1"{,.bak}
  else
    cp "$1"{,.bak}
  fi
}

extract(){
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2) tar vxjf $1 ;;
      *.tar.gz) tar vxzf $1 ;;
      *.tar.xz) tar vxf $1 ;;
      *.bz2) bzip2 $1 ;;
      *.rar) unrar e $1 ;;
      *.gz) gunzip $1 ;;
      *.tar) tar vxf $1 ;;
      *.tbz2) tar vxjf $1 ;;
      *.tgz) tar vxzf $1 ;;
      *.zip) unzip  $1 ;;
      *.Z) uncompress $1 ;;
      *.7z) 7z x $1 ;;
      *) echo "'$1' cannot be extracted via extract()" ;;
      esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Show ip and geographic location
# supported params types:
#   none: show ip and location of current network
#   one or more ips seperated by space: show location of each ip address
#   domain name: show all ips and corresponding locations of the domain name
ipinfo(){
  if [[ -z "$@" ]]; then
    # curl ip.cn
    # curl ipinfo.io
    # ip=`curl https://ifconfig.minidump.info/ 2> /dev/null`
    curl -Ss myip.ipip.net | sed 's#当前 IP：##' | sed 's#来自于：##' | sed 's#\t\+# #g'
  else
    if [[ "$@" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
      ips=$@
    else
      ips=`host $@ | grep 'has address' | cut -d' ' -f4`
    fi

    count=`echo $ips | gawk 'END{print NF}'`
    i=0
    for ip in $ips; do
      # info=`curl whois.pconline.com.cn/ip.jsp 2> /dev/null | iconv --from-code=gb2312 --to-code=utf-8 | tail -1`
      info=`curl -Ss http://freeapi.ipip.net/$ip | sed -r 's#(\[|]|")##g' | sed -r 's#[,]{2,}#,#g' | sed 's#,$##' | sed 's#,#, #g'`

      i=$((i + 1))
      # there is a an rate limit for the api access
      if [[ "$i" < "$count" ]]; then
        sleep 1
      fi

      echo "$ip  $info"
    done
  fi
}

# get absolute path
fullpath(){
  # realpath $1
  readlink -e $1
}

# show listening port
port(){
  sudo ss -tulpn | gawk '{printf "%-6s %-9s %-19s %s\n", $1, $2, $5, $7}'
}

hex2rgb(){
  value=$1
  if [ -n "$value" ]; then
    value=`echo $value | sed "s/^#//"`
    if [[ "$value" =~ [0-9a-zA-Z]{3} || "$value" =~ [0-9a-zA-Z]{6} ]]; then
      python -c "value = '$value'; \
        print(len(value) == 3 and tuple(int(value[i] * 2, 16) for i in (0, 1, 2)) or tuple(int(value[i:i+2], 16) for i in (0, 2, 4)));"
    else
      echo "Invalid color"
    fi
  fi
}

random_password(){
  length=${1:-10}
  which openssl &> /dev/null && (openssl rand -base64 $length | head -c $length) && echo
  < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-$length} && echo
}
