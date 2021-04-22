
autoload -U add-zsh-hook

findup() { 
  local path="$(pwd)"
  local target="$1"

  while
      if [ -e "$path/$target" ]; then
          echo "$path/$target"
      fi
      [ "$path" ]
  do
      path="${path%/*}"
  done
}

bullet-train-magic-prompt() {
    BULLETTRAIN_PROMPT_ORDER=(
        time
        custom
        aws
    )

    if [ "$(findup package.json)" ]; then
        BULLETTRAIN_PROMPT_ORDER=($BULLETTRAIN_PROMPT_ORDER nvm)
    fi

    if [ "$(findup Gemfile)" ]; then
        BULLETTRAIN_PROMPT_ORDER=($BULLETTRAIN_PROMPT_ORDER ruby)
    fi

    BULLETTRAIN_PROMPT_ORDER=(
        $BULLETTRAIN_PROMPT_ORDER
        dir
        git
        cmd_exec_time
        status
    )
}


bullet-train-magic-prompt

add-zsh-hook chpwd bullet-train-magic-prompt