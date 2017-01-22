export PATH="$HOME/.nenv/bin:$HOME/.rbenv/bin:$HOME/Library/Python/2.7/bin:$PATH"
export ZSH=~/.oh-my-zsh
export BULLETTRAIN_TIME_SHOW=false
export BULLETTRAIN_RUBY_SHOW=false
export BULLETTRAIN_NVM_SHOW=true
export BULLETTRAIN_NVM_PREFIX=''
export BULLETTRAIN_DIR_EXTENDED=0
export EDITOR='vim'

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

# for hannesdiem.de
tagesformupload() { aws s3 cp ~/Music/Tagesform/$1/tagesform_$1.mp3 s3://tagesform/tagesform_$1.mp3 }
diempostnew() { node ~/checkouts/Xiphe/hannesdiem.de/new_post.js $1 }

# https://github.com/Xiphe/js-dotfiles
nodejs-init() {
  git clone git@github.com:Xiphe/js-dotfiles.git $1 &&
  cd $1 &&
  rm -rf .git &&
  rm README.md &&
  git init &&
  git add . &&
  git commit -m'chore(js-dotfiles): initiate dotfiles' -m'https://github.com/Xiphe/js-dotfiles' &&
  npm init &&
  npm install --save-dev --save-exact eslint-config-airbnb-base eslint-plugin-import eslint &&
  git add . &&
  git commit -m'chore(package): add package.json'
}

source $ZSH/oh-my-zsh.sh
eval "$(nenv init -)"
eval "$(rbenv init -)"
. `brew --prefix`/etc/profile.d/z.sh
