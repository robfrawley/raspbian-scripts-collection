#!/bin/bash

function get_sys_net_path() {
  local sys_net_name="${1}"
  local sys_net_path="/sys/class/net/${sys_net_name}"

  if [[ ! -d ${sys_net_path} ]]; then
    return 1
  fi

  printf -- '%s' "${sys_net_path}"
}

function get_sys_net_file() {
  local sys_net_name="${1}"
  local sys_net_file="${2}"
  local sys_net_file_root
  local sys_net_file_path

  if ! sys_net_file_root="$(get_sys_net_path "${sys_net_name}")"; then
    return 2
  fi

  sys_net_file_path="$(
    printf -- '%s/%s' "${sys_net_file_root}" "${sys_net_file}"
  )"

  if [[ ! -f ${sys_net_file_path} ]]; then
    return 3
  fi

  printf -- '%s' "${sys_net_file_path}"
}

function get_sys_net_file_value() {
  local sys_net_name="${1}"
  local sys_net_file="${2}"
  local def_returned="${3:-}"
  local sys_net_file_path

  if ! sys_net_file_path=$(get_sys_net_file "${sys_net_name}" "${sys_net_file}"); then
    printf -- "${def_returned}"
    return 4
  fi

  cat "${sys_net_file_path}" 2> /dev/null || printf -- "${def_returned}"
}
