export PATH="$HOME/.nenv/bin:$HOME/.rbenv/bin:$HOME/Library/Python/2.7/bin:$PATH"
export ZSH=~/.oh-my-zsh
export BULLETTRAIN_TIME_SHOW=false
export BULLETTRAIN_RUBY_SHOW=false
export BULLETTRAIN_NVM_SHOW=true
export BULLETTRAIN_NVM_PREFIX=''
export BULLETTRAIN_DIR_EXTENDED=0
export EDITOR='vim'
export IEVMS_VERSIONS="11 EDGE"
export ANSIBLE_HOSTS="$HOME/.ansiblehosts"

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

plugins=(password_generator)

# helpers
serve() { echo "http://localhost:${1:-8000}" && python -m SimpleHTTPServer ${1:-8000} $2 }
pidforport() { lsof -n -i :$1 }
deletemergedbranches() { git branch --merged | egrep -v "(^\*|master|dev)" | xargs git branch -d }
sha1() { openssl dgst -sha1 $1 }
sha256() { openssl dgst -sha256 $1 }
sha512() { openssl dgst -sha512 $1 }

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
  npm install --save-dev --save-exact eslint-config-airbnb-base eslint-plugin-import eslint-config-prettier eslint-plugin-prettier prettier eslint &&
  git add . &&
  git commit -m'chore(package): add package.json'
}

connect-home() {
  sshuttle -r xiphecloud2 0.0.0.0/0 -vv
}

link-keys() {
  setopt localoptions rmstarsilent
  local name

  for x in 0 1 2 3 4 5; do
    if [[ $x == 0 ]]; then
      name='keys'
    else
      name="keys-$x"
    fi
    
    if [[ -d "/Volumes/$name/ssh" ]]; then
      break
    fi
  done

  echo "Linking to '$name'"

  rm ~/.ssh &&
  rm ~/.zshenv &&
  rm ~/.gnupg/* &&
  rm ~/.ansiblehosts &&
  ln -s /Volumes/$name/ssh ~/.ssh &&
  ln -s /Volumes/$name/env/zshenv ~/.zshenv &&
  ln -s /Volumes/$name/gpg/v2/* ~/.gnupg &&
  ln -s /Volumes/$name/ansible/hosts ~/.ansiblehosts
}

setup-apps() {
  CASKS=(alfred bartender cryptomator firefox google-chrome hipchat iterm2 istat-menus java mattermost slack spectacle spotify thunderbird tunnelblick visual-studio-code ynab)
  ABSENT_CASKS=(atom)
  BREWS=(git gnupg the_silver_searcher wget z)
  ABSENT_BREWS=()

  echo "installing..."
  for i in "${CASKS[@]}"; do
    brew cask install $i 2> /dev/null
  done
  for i in "${ABSENT_CASKS[@]}"; do
    brew cask uninstall $i 2> /dev/null || true
  done
  for i in "${BREWS[@]}"; do
    brew install $i 2> /dev/null
  done
  for i in "${ABSENT_BREWS[@]}"; do
    brew uninstall $i 2> /dev/null || true
  done

  echo "OK"
}

source $ZSH/oh-my-zsh.sh
eval "$(nenv init -)"
eval "$(rbenv init -)"
. `brew --prefix`/etc/profile.d/z.sh
