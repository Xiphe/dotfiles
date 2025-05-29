eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="/opt/homebrew/opt/postgresql@15/bin:$HOME/.rbenv/bin:/Applications/Docker.app/Contents/Resources/bin:$PATH"
export NVM_DIR="$HOME/.nvm"
export ZSH=~/.oh-my-zsh

export BULLETTRAIN_NVM_PREFIX=''
export BULLETTRAIN_AWS_PREFIX=''
export BULLETTRAIN_RUBY_PREFIX=''
export BULLETTRAIN_DIR_EXTENDED=0
export BULLETTRAIN_TIME_BG=black
export BULLETTRAIN_TIME_FG=white
export BULLETTRAIN_PROMPT_ORDER=(
  time
  custom
  aws
  dir
  git
  cmd_exec_time
  status
)

export EDITOR='vim'
export IEVMS_VERSIONS="11 EDGE"
export ANSIBLE_HOSTS="$HOME/.ansiblehosts"
export HOMEBREW_BUNDLE_FILE="$HOME/dotfiles/Brewfile"

export LC_ALL=en_GB.UTF-8
export LC_NUMERIC=de_DE.UTF-8
export LC_TIME=de_DE.UTF-8
export LC_MONETARY=de_DE.UTF-8

export NPM_CONFIG_INIT_VERSION=0.0.0-development
export NPM_CONFIG_INIT_AUTHOR_NAME="Hannes Diercks"
export NPM_CONFIG_INIT_AUTHOR_EMAIL="node@xiphe.net"
export NPM_CONFIG_INIT_AUTHOR_URL="https://xiphe.net"
export NPM_CONFIG_INIT_LICENSE="UNLICENSED"
export PLAYWRIGHT_BROWSERS_PATH=$HOME/.playwright-browsers

HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
ZSH_THEME="bullet-train"
HYPHEN_INSENSITIVE="true"
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="dd.mm.yyyy"
ZSH_CUSTOM=~/dotfiles/.oh-my-zsh-custom

setopt appendhistory autocd extendedglob nomatch notify
unsetopt beep
bindkey -v
zstyle :compinstall filename '~/.zshrc'
autoload -Uz compinit
compinit

plugins=(password_generator env btmp translate)

[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh" # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

nvm use default --silent

# helpers
pidforport() { lsof -n -i :$1 }
killnodeport() {
  PORT=$(lsof -n -i :$1 | grep node | sed 's/node *//g' | sed 's/[^0-9]* .*//g')
  kill $PORT
}
deletemergedbranches() { git branch --merged | egrep -v "(^\*|master|dev)" | xargs git branch -d }
sha1() { openssl dgst -sha1 $1 }
sha256() { openssl dgst -sha256 $1 }
sha512() { openssl dgst -sha512 $1 }

# for hannesdiem.de
tagesformupload() { aws --profile tagesform_upload s3 cp ~/Tagesform/$1/tagesform_$1.mp3 s3://tagesform/tagesform_$1.mp3 }
diempostnew() { node ~/checkouts/github.com/Xiphe/hannesdiem.de/new_post.js $1 }

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
  npm install --save-dev --save-exact eslint-config-airbnb-base eslint-plugin-import eslint-config-prettier eslint-plugin-prettier prettier eslint &&
  git add . &&
  git commit -m'chore(package): add package.json'
}

link-keys() {
  setopt localoptions rmstarsilent

  rm ~/.ssh;
  rm ~/.zshenv;
  rm ~/.gnupg/*;
  rm ~/.aws;
  ln -s ~/.keys/ssh ~/.ssh &&
  ln -s ~/.keys/env/zshenv ~/.zshenv &&
  ln -s ~/.keys/gpg/v2/* ~/.gnupg &&
  ln -s ~/.keys/aws ~/.aws &&
}

source $ZSH/oh-my-zsh.sh

. `brew --prefix`/etc/profile.d/z.sh
# tabtab source for electron-forge package
# uninstall by removing these lines or running `tabtab uninstall electron-forge`
[[ -f /Users/xiphe/.npm/_npx/14790/lib/node_modules/electron-forge/node_modules/tabtab/.completions/electron-forge.zsh ]] && . /Users/xiphe/.npm/_npx/14790/lib/node_modules/electron-forge/node_modules/tabtab/.completions/electron-forge.zsh
# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/__tabtab.zsh ]] && . ~/.config/tabtab/__tabtab.zsh || true

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
