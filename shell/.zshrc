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

mount-keys() {
  hdiutil attach "$HOME/Keys.sparsebundle" -mountpoint /Volumes/Keys
}

gitCopyFromBranch() {
    # Check for correct number of arguments
    if [ $# -ne 2 ]; then
        echo "Usage: gitCopyFromBranch source_branch path/to/file"
        return 1
    fi

    local source_branch=$1
    local file_path=$2
    local dir_path=$(dirname "$file_path")

    # Check if the source branch exists
    if ! git rev-parse --verify $source_branch > /dev/null 2>&1; then
        echo "Error: Branch '$source_branch' does not exist."
        return 1
    fi

    # Ensure the directory exists
    if [ ! -d "$dir_path" ]; then
        echo "Directory '$dir_path' does not exist. Creating directory..."
        mkdir -p "$dir_path"
    fi

    # Copy the file from the source branch
    git show $source_branch:$file_path > $file_path
}

checkout-pr() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: checkout-pr <user:branch>"
    return 1
  fi

  # Split input into username and branch
  local GH_USER="${1%%:*}"
  local GH_BRANCH="${1#*:}"

  if [[ -z "$GH_USER" || -z "$GH_BRANCH" ]]; then
    echo "Invalid format. Use: checkout-pr user:branch"
    return 1
  fi

  local REMOTE_URL
  local NEW_REMOTE="$GH_USER"

  # Get the origin remote URL
  REMOTE_URL=$(git remote get-url origin)

  # Replace the existing owner/org with the given GH_USER
  NEW_REMOTE_URL=$(echo "$REMOTE_URL" | sed -E "s|([^/:]+)/([^/]+)\.git$|$GH_USER/\2.git|")

  # Check if the remote already exists
  if ! git remote | grep -q "^$NEW_REMOTE\$"; then
    echo "Adding remote '$NEW_REMOTE' -> $NEW_REMOTE_URL"
    git remote add "$NEW_REMOTE" "$NEW_REMOTE_URL"
  fi

  # Fetch the branch from the new remote
  git fetch "$NEW_REMOTE" "$GH_BRANCH"

  # Create a local branch and check it out
  git checkout -b "$GH_BRANCH" "$NEW_REMOTE/$GH_BRANCH"

  # Set upstream correctly
  git branch --set-upstream-to="$NEW_REMOTE/$GH_BRANCH"
}

source $ZSH/oh-my-zsh.sh

~/dotfiles/protect-keys.sh --check-log

. `brew --prefix`/etc/profile.d/z.sh
# tabtab source for electron-forge package
# uninstall by removing these lines or running `tabtab uninstall electron-forge`
[[ -f /Users/xiphe/.npm/_npx/14790/lib/node_modules/electron-forge/node_modules/tabtab/.completions/electron-forge.zsh ]] && . /Users/xiphe/.npm/_npx/14790/lib/node_modules/electron-forge/node_modules/tabtab/.completions/electron-forge.zsh
# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/__tabtab.zsh ]] && . ~/.config/tabtab/__tabtab.zsh || true

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
