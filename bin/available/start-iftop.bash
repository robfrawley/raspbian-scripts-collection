#!/bin/bash

readonly _START_IFTOP_FILE="$(
  realpath -e "${BASH_SOURCE[0]}" 2> /dev/null || printf -- '%s' "${BASH_SOURCE[0]}"
)"
readonly _START_IFTOP_PATH="$(
  dirname "${_START_IFTOP_FILE}" 2> /dev/null
)"

source "${_START_IFTOP_PATH}/../../lib/inc-all.bash"

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

  out_line_std \
    "$(printf 'State of ELN device %5s' "${eln_name}")" \
    "$(bool_to_string ${eln_code})"
  out_line_std \
    "$(printf 'State of WLN device %5s' "${wln_name}")" \
    "$(bool_to_string ${wln_code})"

  if [[ -z ${sln_name} ]]; then
    out_line_std \
      'Failed to locate any enabled interfaces...\n'
    return 5
  fi

  bin_path="${_LIB_CALLER_ROOT}/../activated/start-iftop-${sln_name}"

  if [[ ! -x ${bin_path} ]]; then
    out_line_std \
      "$(printf 'Failures for device %5s' "${sln_name}")" \
      "$(build_sys_net_path "${sln_name}")" \
      "${bin_path}" \
      "could not locate executable at expected path..."
    return 6
  fi

  out_line_std \
      "$(printf 'Selected SLN device %5s' "${sln_name}")" \
      "$(build_sys_net_path "${sln_name}")" \
      "${bin_path}" \
      "executing in 5 seconds..."

  sleep 5

  ${bin_path} 2> /dev/null
}

function main() {
  while true; do
    loop "${@}"
    sleep 2
  done
}

main "${@}"
