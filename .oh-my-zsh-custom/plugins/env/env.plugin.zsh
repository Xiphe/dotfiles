## Look for .env file in current or parent dir and load it
## Update on dir change or restore previous state

autoload -U add-zsh-hook

load-local-conf() {
  local current_dir=$(pwd)
  local envfile=

  # Find .env in current or parent dir
  while
      if [ -e "$current_dir/.env" ]; then
          envfile="$current_dir/.env"
      fi
      [ "$current_dir" ]
  do
      current_dir="${current_dir%/*}"
  done

  # Do nothing if loaded
  if [ "$envfile" = "$DOT_ENV_LOADED" ]; then
    return
  fi

  # Restore previous state
  while IFS= read -r prevname; do
    if [ "$prevname" ]; then
      eval "$prevname=\$DOT_ENV_PREV_$prevname;DOT_ENV_PREV_$prevname="
    fi
  done <<< "$DOT_ENV_PREV_NAMES"

  # Reset
  DOT_ENV_PREV_NAMES=
  DOT_ENV_LOADED=

  # Load env
  if [ "$envfile" ]; then
    local vars="$(cat $envfile | grep -E '^[A-Z_]+=.+')"
    local nl=$'\n'
    while IFS= read -r var; do
      local name="$(echo $var | grep -oE '^[A-Z_]+')"
      # Store previous values
      DOT_ENV_PREV_NAMES="$DOT_ENV_PREV_NAMES$nl$name"
      eval "DOT_ENV_PREV_$name=\$$name"
    done <<< "$vars"

    source $envfile
    DOT_ENV_LOADED=$envfile
  fi
}

load-local-conf

add-zsh-hook chpwd load-local-conf