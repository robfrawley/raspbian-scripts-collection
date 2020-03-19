#!/bin/bash

function build_sys_path_force() {
  local sys_path="/sys"
  local sys_code=0

  for p in "${@}"; do
    sys_path+="/${p}"
  done

  [[ ! -e ${sys_path} ]] && sys_code=110

  out_printf '%s' "${sys_path}"

  return ${sys_code}
}

function build_sys_path() {
  local sys_path

  if ! sys_path="$(build_sys_path_force "${@}")"; then
    return ${PIPESTATUS[0]}
  fi

  out_printf '%s' "${sys_path}"
}

function build_sys_file_force() {
  local sys_args=("${@}")
  local sys_root
  local sys_path
  local sys_code=0

  if ! sys_root="$(build_sys_path_force "${@:1:$((${#} - 1))}")"; then
    sys_code=111
  fi

  sys_path="$(
    out_printf '%s/%s' "${sys_root}" "${sys_args[-1]}"
  )"

  [[ ! -f ${sys_path} ]] && sys_code=112

  out_printf '%s' "${sys_path}"

  return ${sys_code}
}

function build_sys_file() {
  local sys_args=("${@}")
  local sys_path

  if ! sys_path="$(build_sys_file_force "${sys_args[@]}")"; then
    return ${PIPESTATUS[0]}
  fi

  out_printf '%s' "${sys_path}"
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

  out_printf '%s' "${sys_path}"
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

  out_printf '%s' "${sys_path}"
}

function value_sys_net_file() {
  local sys_name="${1}"
  local sys_file="${2}"
  local sys_vals

  if ! sys_vals="$(value_sys_file 'class' 'net' "${sys_name}" "${sys_file}")"; then
    return 123
  fi

  out_printf '%s' "${sys_vals}"
}
