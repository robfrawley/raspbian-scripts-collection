#!/bin/bash

function out_line_std() {
  local msg_assetion="${1:-Performing action...}"
  local msg_resulted="${2}"
  local msg_ext_args=("${@:3}")

  printf -- '[%s@%.3f] %s' "${_LIB_CALLER_NAME}" "$(date +%s\.%N)" "${msg_assetion}"

  if [[ -n ${msg_resulted} ]]; then
    printf -- ': %s' "${msg_resulted}"

    if [[ ${#msg_ext_args[@]} -gt 0 ]]; then
      for a in "${msg_ext_args[@]}"; do
        printf -- ' (%s)' "${a}"
      done
    fi
  fi

  printf '\n'
}

readonly _OUTS_LIB_FILE="$(
  realpath -e "${BASH_SOURCE[0]}" 2> /dev/null || printf -- '%s' "${BASH_SOURCE[0]}"
)"

readonly _OUTS_LIB_PATH="$(
  dirname "${_OUTS_LIB_FILE}" 2> /dev/null
)"

source "${_OUTS_LIB_PATH}/../core/core-lib.bash"
