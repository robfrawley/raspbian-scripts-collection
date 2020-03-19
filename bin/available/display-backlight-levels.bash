#!/bin/bash


##
## READONLY INTERNAL VARIABLE DEFINITIONS
##

readonly _DPLY_BL_LEVELS_FILE="$(
  realpath -e "${BASH_SOURCE[0]}" 2> /dev/null || printf -- '%s' "${BASH_SOURCE[0]}"
)"

readonly _DPLY_BL_LEVELS_PATH="$(
  dirname "${_DPLY_BL_LEVELS_FILE}" 2> /dev/null
)"


##
## SOURCE VENDOR DEPENDENCIES
##

source "${_DPLY_BL_LEVELS_PATH}/../../lib/inc-all.bash"


##
## INTERNAL VARIABLES DEFINITIONS
##

#
# define the usys file path sections for display backlight
#
_DISPLAY_BACKLIGHT_LEVELS_USYS_PARTS=('class' 'backlight' 'rpi_backlight' 'brightness')


##
## APP FUNCTION DEFINITIONS
##

#
# normalize user level (0-100) to raw level (0-254)
#
function normalize_usr_to_raw_level() {
  local input_val="${1}"
  local precision="${2:-2}"

  [[ ${input_val} -gt 100 ]] && input_val=100
  [[ ${input_val} -lt   0 ]] && input_val=0

  number_floor $(
    number_base_switch "${input_val}" 100 254 ${precision}
  )
}

#
# normalize raw level (0-254) to user level (0-100)
#
function normalize_raw_to_usr_level() {
  local input_val="${1}"
  local precision="${2:-4}"

  number_ceil $(
    number_base_switch "${input_val}" 254 100 ${precision}
  )
}

#
# output backlight level assessor failure message
#
function out_display_backlight_level_accessor_failure() {
  local action="${1}"
  local extras="${2}"

  out_fail \
    'unable to perform "%s" action on display backlight level using "%s" file device%s' \
    "${action}" \
    "$(build_sys_file "${_DISPLAY_BACKLIGHT_LEVELS_USYS_PARTS[@]}")" \
    "$(
      [[ -n "${extras}" ]] && out_printf ' (%s)' "${extras}"
    )"
}

#
# output current backlight level information
#
function out_display_backlight_level() {
  local extra="${1}"
  local level

  if ! level="$(value_sys_file "${_DISPLAY_BACKLIGHT_LEVELS_USYS_PARTS[@]}")"; then
    out_display_backlight_level_accessor_failure 'read'
    return 1
  fi

  out_auto_nl_disable
  out_info \
    'display backlight levels: %03d/100 (as percentage); %03d/254 (as raw value); ' \
    "$(normalize_raw_to_usr_level "${level}")" \
    "${level}"
  out_auto_nl_enable

  if is_out_verb_level_ge 2; then
    if [[ ${extra} ]]; then
      out_printf 'value represents "%s" state; ' "${extra}"
    fi

    out_printf \
      'device file used "%s"' \
      "$(build_sys_file "${_DISPLAY_BACKLIGHT_LEVELS_USYS_PARTS[@]}")"

    out_nl
  fi
}

#
# assign backlight level
#
function set_display_backlight_level() {
  local level="${1}"

  if ! updts_sys_file "${level}" "${_DISPLAY_BACKLIGHT_LEVELS_USYS_PARTS[@]}"; then
    out_display_backlight_level_accessor_failure \
      'assignment' \
      "could not set to \"${level}\" value"
    return 1
  fi
}

#
# main function definition
#
function main() {
  local level="${1}"

  out_display_backlight_level 'existing'

  if [[ -n "${level}" ]]; then
    set_display_backlight_level "$(normalize_usr_to_raw_level "${level}")"
    out_display_backlight_level 'assigned'
  fi
}


##
## INVOKE MAIN FUNCTION DEFINITION
##

main "${@}"
