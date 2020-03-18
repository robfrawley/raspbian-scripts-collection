#!/bin/bash

readonly _DPLY_BL_TOGGLE_FILE="$(
  realpath -e "${BASH_SOURCE[0]}" 2> /dev/null || printf -- '%s' "${BASH_SOURCE[0]}"
)"
readonly _DPLY_BL_TOGGLE_PATH="$(
  dirname "${_DPLY_BL_TOGGLE_FILE}" 2> /dev/null
)"

source "${_DPLY_BL_TOGGLE_PATH}/../../lib/inc-all.bash"

function out_dply_power() {
  local extra="${1:-}"
  local state

  if ! state="$(value_sys_file 'class' 'backlight' 'rpi_backlight' 'bl_power')"; then
    return 1
  fi

  if [[ ${state} -eq 0 ]]; then
    state=1
  else
    state=0
  fi

  out_line_std \
    'Back light status' \
    "$(bool_to_string "${state}")" \
    "${extra}"
}

function set_dply_power_on() {
  if ! updts_sys_file '0' 'class' 'backlight' 'rpi_backlight' 'bl_power'; then
    return 1
  fi
}

function set_dply_power_off() {
  if ! updts_sys_file '1' 'class' 'backlight' 'rpi_backlight' 'bl_power'; then
    return 1
  fi
}

function main() {
    out_dply_power 'prior assigned value'

    case "${1}" in
        on|enable|true|1) set_dply_power_on  ;;
        off|disable|false|0) set_dply_power_off ;;
    esac

    out_dply_power 'newly assigned value'
}

main "${@}"
