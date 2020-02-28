#!/bin/bash

readonly _DPLY_BL_LEVELS_FILE="$(
  realpath -e "${BASH_SOURCE[0]}" 2> /dev/null || printf -- '%s' "${BASH_SOURCE[0]}"
)"
readonly _DPLY_BL_LEVELS_PATH="$(
  dirname "${_DPLY_BL_LEVELS_FILE}" 2> /dev/null
)"

source "${_DPLY_BL_LEVELS_PATH}/../../lib/inc-all.bash"

function normalize_input_level() {
  local input="${1:-100}"

  if [[ ${input} -gt 100 ]]; then
    input=100
  fi

  if [[ ${input} -lt 0 ]]; then
    input=0
  fi

  printf '%s' $(
    printf '%d * 255 / 100\n' ${input} | bc 2> /dev/null \
      || printf '%s' "${input}"
  )
}

function out_dply_level() {
  local extra="${1:-}"
  local level

  if ! level="$(value_sys_file 'class' 'backlight' 'rpi_backlight' 'brightness')"; then
    return 1
  fi

  out_line_std \
    'Brightness level' \
    "$(printf -- '%3d%%' "${level}")" \
    "${extra}"
}

function main() {
  out_dply_level 'prior assigned value'

  updts_sys_file "$(
    normalize_input_level "${1}"
  )" 'class' 'backlight' 'rpi_backlight' 'brightness'

  out_dply_level 'newly assigned value'
}

main "${@}"
