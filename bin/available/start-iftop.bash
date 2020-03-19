#!/bin/bash


##
## READONLY INTERNAL VARIABLE DEFINITIONS
##

readonly _START_IFTOP_LEVELS_FILE="$(
  realpath -e "${BASH_SOURCE[0]}" 2> /dev/null || printf -- '%s' "${BASH_SOURCE[0]}"
)"

readonly _START_IFTOP_LEVELS_PATH="$(
  dirname "${_START_IFTOP_LEVELS_FILE}" 2> /dev/null
)"


##
## SOURCE VENDOR DEPENDENCIES
##

source "${_START_IFTOP_LEVELS_PATH}/../../lib/inc-all.bash"


##
## APP FUNCTION DEFINITIONS
##

#
# perform main function loop
#
function loop() {
  local eln_name="${1:-eth0}"
  local wln_name="${2:-wlan0}"
  local eln_code=0
  local wln_code=0
  local eln_path
  local wln_path
  local sln_name
  local bin_path

  if wln_path=$(build_sys_net_path "${wln_name}"); then
    wln_code=$(
      value_sys_net_file "${wln_name}" 'carrier' 0
    )

    if [[ ${wln_code} -eq 1 ]]; then
      sln_name="${wln_name}"
    fi
  fi

  if eln_path=$(build_sys_net_path "${eln_name}"); then
    eln_code=$(
      value_sys_net_file "${eln_name}" 'carrier' 0
    )

    if [[ ${eln_code} -eq 1 ]]; then
      sln_name="${eln_name}"
    fi
  fi

  out_info \
    'state of ELN device %5s: %s' \
    "${eln_name}" \
    "$(bool_to_string_verbose ${eln_code})"

  out_info \
    'state of WLN device %5s: %s' \
    "${wln_name}" \
    "$(bool_to_string_verbose ${wln_code})"

  if [[ -z ${sln_name} ]]; then
    out_fail 'interface resolution failure (unable to find any enabled interface devices)!'
    return 5
  fi

  bin_path="${_BINS_PATH_REAL}/start-iftop-${sln_name}"

  if [[ ! -x ${bin_path} ]]; then
    out_fail \
      'fail for SLN device %5s: "%s" (with command "%s")' \
      "${sln_name}" \
      "$(build_sys_net_path "${sln_name}")" \
      "${bin_path}"
    return 6
  fi

  out_info \
    'selected SLN device %5s: "%s" (with command "%s")' \
    "${sln_name}" \
    "$(build_sys_net_path "${sln_name}")" \
    "${bin_path}"

  sleep 5

  ${bin_path} 2> /dev/null
}


#
# main function definition
#
function main() {
  while true; do
    loop "${@}"
    sleep 2
  done
}


##
## INVOKE MAIN FUNCTION DEFINITION
##

main "${@}"
