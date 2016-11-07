export PATH="$HOME/.nenv/bin:$PATH"
export ZSH=~/.oh-my-zsh
export BULLETTRAIN_TIME_SHOW=false
export BULLETTRAIN_RUBY_SHOW=false
export BULLETTRAIN_NVM_SHOW=true
export BULLETTRAIN_NVM_PREFIX=''
export BULLETTRAIN_DIR_EXTENDED=0
export EDITOR='atom -n --'

HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
ZSH_THEME="bullet-train"
HYPHEN_INSENSITIVE="true"
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="dd.mm.yyyy"
ZSH_CUSTOM=~/.oh-my-zsh-custom

setopt appendhistory autocd extendedglob nomatch notify
unsetopt beep
bindkey -v
zstyle :compinstall filename '~/.zshrc'
autoload -Uz compinit
compinit

plugins=()

# for diem-musik.de
tagesformupload() { aws s3 cp ~/Music/Tagesform/$1/tagesform_$1.mp3 s3://tagesform/tagesform_$1.mp3 }
diempostnew() { node ~/checkouts/Xiphe/diem-musik.de/new_post.js $1 }

source $ZSH/oh-my-zsh.sh
eval "$(nenv init -)"
