#!/usr/bin/bash

# Ruby and RVM
if [[ -d "$HOME/.rvm/bin" && -s "$HOME/.rvm/scripts/rvm" ]]; then
  if [[ "$PATH" != *.rvm/bin* ]]; then
    export PATH="$PATH:$HOME/.rvm/bin"
  fi
  source "$HOME/.rvm/scripts/rvm"
elif which ruby &> /dev/null; then
  export GEM_HOME="$HOME"/.gem/ruby/$(ruby -e 'print RUBY_VERSION[/^\d+\.\d+/]')
  if [[ ":$PATH:" != *":$GEM_HOME/bin:"* ]]; then
    export PATH="$PATH":"$GEM_HOME"/bin
  fi
fi

# Golang
which go &> /dev/null && {
  export GOPATH="$HOME"/.go
  if [[ ":$PATH:" != *":$GOPATH/bin:"* ]]; then
    export PATH="$PATH":"$GOPATH"/bin
  fi
}

[[ -f "$HOME/.bashrc" ]] && . "$HOME"/.bashrc
