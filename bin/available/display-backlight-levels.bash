#!/bin/bash

readonly _DPLY_BL_LEVELS_FILE="$(
  realpath -e "${BASH_SOURCE[0]}" 2> /dev/null || printf -- '%s' "${BASH_SOURCE[0]}"
)"
readonly _DPLY_BL_LEVELS_PATH="$(
  dirname "${_DPLY_BL_LEVELS_FILE}" 2> /dev/null
)"

source "${_DPLY_BL_LEVELS_PATH}/../../lib/inc-all.bash"

function normalize_puts_level_from_input() {
  local input_val="${1}"
  local precision="${2:-2}"

  [[ ${input_val} -gt 100 ]] && input_val=100
  [[ ${input_val} -lt   0 ]] && input_val=0

  number_floor $(
    number_base_switch "${input_val}" 100 254 ${precision}
  )
}

function normalize_gets_level_from_reads() {
  local input_val="${1}"
  local precision="${2:-4}"

  number_ceil $(
    number_base_switch "${input_val}" 254 100 ${precision}
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
    "$(normalize_gets_level_from_reads "${level}")%" \
    "${extra}"
}

function main() {
  out_dply_level 'prior assigned value'

  updts_sys_file \
    "$(normalize_puts_level_from_input $(number_round "${1}" 0))" \
    'class' \
    'backlight' \
    'rpi_backlight' \
    'brightness'

  out_dply_level 'newly assigned value'
}

main "${@}"
