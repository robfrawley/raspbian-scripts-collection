#!/bin/bash

function bool_to_string() {
  local val="${1}"
  local str_t="${2:-ON}"
  local str_f="${3:-OFF}"
  local str

  if [[ ${val} -gt 0 ]]; then
    str="${str_t}"
  else
    str="${str_f}"
  fi

  printf -- '%-3s (%d)' "${str}" "${val}"
}

readonly _LIB_CALLER_PATH="$(
  realpath -e "${BASH_SOURCE[-1]}" 2> /dev/null || printf -- '%s' "${BASH_SOURCE[-1]}"
)"

readonly _LIB_CALLER_ROOT="$(
  dirname "${_LIB_CALLER_PATH}" 2> /dev/null
)"

readonly _LIB_CALLER_FILE="$(
  basename "${_LIB_CALLER_PATH}" 2> /dev/null
)"

readonly _LIB_CALLER_EXTS="$(
  grep -oE '\.[a-zA-Z0-9]+$' <<< "${_LIB_CALLER_PATH}" 2> /dev/null | \
    sed -E 's/^\.//'
)"

readonly _LIB_CALLER_NAME="$(
  basename "${_LIB_CALLER_PATH}" ".${_LIB_CALLER_EXTS}"
)"
