#!/bin/bash


##
## READONLY INTERNAL VARIABLE DEFINITIONS
##

readonly _DPLY_BL_TOGGLE_FILE="$(
  realpath -e "${BASH_SOURCE[0]}" 2> /dev/null || printf -- '%s' "${BASH_SOURCE[0]}"
)"

readonly _DPLY_BL_TOGGLE_PATH="$(
  dirname "${_DPLY_BL_TOGGLE_FILE}" 2> /dev/null
)"


##
## SOURCE VENDOR DEPENDENCIES
##

source "${_DPLY_BL_TOGGLE_PATH}/../../lib/inc-all.bash"


##
## INTERNAL VARIABLES DEFINITIONS
##

#
# define the usys file path sections for display backlight
#
_DISPLAY_BACKLIGHT_TOGGLE_USYS_PARTS=('class' 'backlight' 'rpi_backlight' 'bl_power')


##
## APP FUNCTION DEFINITIONS
##

#
# output backlight level assessor failure message
#
function out_display_backlight_power_accessor_failure() {
  local action="${1}"
  local extras="${2}"

  out_fail \
    'unable to perform "%s" action on display backlight state using "%s" file device%s' \
    "${action}" \
    "$(build_sys_file_force "${_DISPLAY_BACKLIGHT_TOGGLE_USYS_PARTS[@]}")" \
    "$(
      [[ -n "${extras}" ]] && out_printf ' (%s)' "${extras}" || out_printf ' '
    )"
}

#
# display current backlight power state
#
function out_display_backlight_power_state() {
  local extra="${1:-}"
  local state

  if ! state="$(value_sys_file "${_DISPLAY_BACKLIGHT_TOGGLE_USYS_PARTS[@]}")"; then
    out_display_backlight_power_accessor_failure 'read'
    return 1
  fi

  state="$(bool_reverse "$(bool_to_string_integer "${state}")")"

  out_auto_nl_disable
  out_info 'display backlight status: "%d" (as boolean state); "%s" (as boolean description); ' "${state}" "$(bool_to_string_concise "${state}")"
  out_auto_nl_enable

  if is_out_verb_level_ge 2; then
    if [[ ${extra} ]]; then
      out_printf 'value represents "%s" state; ' "${extra}"
    fi

    out_printf \
      'device file used "%s"' \
      "$(build_sys_file_force "${_DISPLAY_BACKLIGHT_TOGGLE_USYS_PARTS[@]}")"

    out_nl
  fi
}

#
# set backlight power state to enabled
#
function set_display_backlight_power_state() {
  local state="${1}"

  if ! updts_sys_file "${state}" "${_DISPLAY_BACKLIGHT_TOGGLE_USYS_PARTS[@]}"; then
    out_display_backlight_power_accessor_failure 'assignment' "could not set to \"$(bool_to_string_regular "${state}")\" boolean state"
    return 1
  fi
}

#
# set backlight power state to enabled
#
function set_display_backlight_power_state_enabled() {
  set_display_backlight_power_state '0'
}

#
# set backlight power state to disabled
#
function set_display_backlight_power_state_disabled() {
  set_display_backlight_power_state '1'
}

#
# main function definition
#
function main() {
  local state="${1}"

  out_display_backlight_power_state 'existing'

  if [[ -n ${state} ]]; then
    case "$(bool_to_string_integer "${state}")" in
      0) set_display_backlight_power_state_disabled ;;
      1) set_display_backlight_power_state_enabled  ;;
    esac

    out_display_backlight_power_state 'assigned'
  fi
}


##
## INVOKE MAIN FUNCTION DEFINITION
##

main "${@}"
