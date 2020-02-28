#!/bin/bash

function build_sys_path() {
  local sys_path="/sys"

  for p in "${@}"; do
    sys_path+="/${p}"
  done

  if [[ ! -d ${sys_path} ]]; then
    return 110
  fi

  printf -- '%s' "${sys_path}"
}

function build_sys_file() {
  local sys_args=("${@}")
  local sys_root
  local sys_path

  if ! sys_root="$(build_sys_path "${@:1:$((${#} - 1))}")"; then
    return 111
  fi

  sys_path="$(
    printf -- '%s/%s' "${sys_root}" "${sys_args[-1]}"
  )"

  if [[ ! -f ${sys_path} ]]; then
    return 112
  fi

  printf -- '%s' "${sys_path}"
}

function value_sys_file() {
  local sys_path

  if ! sys_path=$(build_sys_file "${@}"); then
    return 113
  fi

  cat "${sys_path}" 2> /dev/null
}

function updts_sys_file() {
  local sys_sets="${1}"
  local sys_args=("${@:2}")

  if ! sys_path=$(build_sys_file "${sys_args[@]}"); then
    return 114
  fi

  sudo bash -c "echo \"${sys_sets}\" > \"${sys_path}\""
}

function build_sys_net_path() {
  local sys_name="${1}"
  local sys_path

  if ! sys_path="$(build_sys_path 'class' 'net' "${sys_name}")"; then
    return 120
  fi

  printf -- '%s' "${sys_path}"
}

function build_sys_net_file() {
  local sys_name="${1}"
  local sys_file="${2}"
  local sys_root
  local sys_path

  if ! sys_root="$(build_sys_net_path "${sys_name}")"; then
    return 121
  fi

  if ! sys_path="$(build_sys_file 'class' 'net' "${sys_name}" "${sys_file}")"; then
    return 122
  fi

  printf -- '%s' "${sys_path}"
}

function value_sys_net_file() {
  local sys_name="${1}"
  local sys_file="${2}"
  local sys_vals

  if ! sys_vals="$(value_sys_file 'class' 'net' "${sys_name}" "${sys_file}")"; then
    return 123
  fi

  printf -- '%s' "${sys_vals}"
}
