#!/bin/bash


##
## FUNCTION DEFINITIONS
##

#
# invoke printf using the shell interpreter passed as the first argument
#
function out_printf_using_shell() {
  local try_shell_name="${1:-zsh}"
  local try_shell_path

  if ! try_shell_path=$(which "${try_shell_name}" 2> /dev/null); then
    return 1
  fi

  ${try_shell_path} -c 'printf -- "${@}"' out_printf "${@:2}" 2> /dev/null
}

#
# redefined printf to enable ordered arguments by calling zsh interpreter version if possible
#
function out_printf() {
  for try_shell_name in 'zsh' 'ksh93' 'bash'; do
    if out_printf_using_shell "${try_shell_name}" "${@}"; then
      return
    fi
  done
}

#
# normalize boolean value
#
function bool_normalize() {
  local state="${1}"

  case "${state,,}" in
    t|true|enable|enabled|on|operational)    state=1 ;;
    f|false|disable|disabled|off|deactivated) state=0 ;;
  esac

  out_printf '%d' "${state}"
}

#
# reverse boolean value
#
function bool_reverse() {
  local state="${1}"

  case "$(bool_normalize "${state}")" in
    0) state=1 ;;
    1) state=0 ;;
  esac

  out_printf '%d' "${state}"
}

#
# convert integer or boolean keywords to human-readable strings, formatted as either short or verbose strings
#
function bool_to_string() {
  local state="${1}"
  local str_t="${2:-operational}"
  local str_f="${3:-deactivated}"
  local exact="${4:-0}"
  local level="${5:-1}"
  local str_r

  state="$(bool_normalize "${state}")"

  if [[ ${exact} -eq 1 ]] && [[ ${state} -eq 1 ]]; then
    str_r="${str_t}"
  elif [[ ${exact} -eq 0 ]] && [[ ${state} -ge 1 ]]; then
    str_r="${str_t}"
  else
    str_r="${str_f}"
  fi

  if [[ ${level} -eq 2 ]]; then
    out_printf 'state="%s"/value="%s"' "${state}" "${str_r}"
  elif [[ ${level} -eq 1 ]]; then
    out_printf '%d -> %s' "${state}" "${str_r}"
  elif [[ ${level} -eq -1 ]]; then
    out_printf '%d' "${state}"
  else
    out_printf '%s' "${str_r}"
  fi
}

#
# convert integer or boolean keywords to human-readable strings as concise-length string
#
function bool_to_string_integer() {
  bool_to_string "${1}" "${2}" "${3}" 0 -1
}

#
# convert integer or boolean keywords to human-readable strings as concise-length string
#
function bool_to_string_concise() {
  bool_to_string "${1}" "${2}" "${3}" 0 0
}

#
# convert integer or boolean keywords to human-readable strings as regular-length string
#
function bool_to_string_regular() {
  bool_to_string "${1}" "${2}" "${3}" 0 1
}

#
# convert integer or boolean keywords to human-readable strings as verbose-length string
#
function bool_to_string_verbose() {
  bool_to_string "${1}" "${2}" "${3}" 0 2
}

#
# try calling commands and return on first successful
#
function attemp_call_list() {
  local call_type="${1}"
  local call_opts="${2}"
  local call_cmds=("${@:3}")

  if ! call_type="$(which "${call_type}" 2> /dev/null)"; then
    return 1
  fi

  for ((i = 0; i < ${#call_cmds[@]}; i++)); do
    if ${call_type} -c "${call_cmds[${i}]} ${call_opts} 2> /dev/null"; then
      return
    fi
  done

  return 1
}

#
# determine real path of directory or file
#
function resolve_path_real() {
  local res_path="${1}"
  local try_cmds=('realpath -e --' 'realpath -m --' 'readlink -e --' 'readlink -m --' 'out_printf "%s"' 'printf "%s"')

  attemp_call_list 'bash' "${res_path}" "${try_cmds[@]}"
}

#
# resolve base directory name of path
#
function resolve_path_base() {
  local res_path="$(resolve_path_real "${1}")"
  local try_cmds=('dirname' 'grep -oE "^/?([^/]+/)+" <<< ' 'out_printf "%s"' 'printf "%s"')

  attemp_call_list 'bash' "${res_path}" "${try_cmds[@]}"
}

#
# resolve file name of path
#
function resolve_file_name() {
  local res_path="$(resolve_path_real "${1}")"
  local try_cmds=('basename' 'out_printf "%s"' 'printf "%s"')

  attemp_call_list 'bash' "${res_path}" "${try_cmds[@]}"
}

#
# resolve file name of path
#
function resolve_file_root() {
  local res_file="$(resolve_file_name "${1}")"

  out_printf '%s' "${res_file%.*}"
}

#
# resolve extention of file name or file path
#
function resolve_file_exts() {
  local res_file="$(resolve_file_name "${1}")"

  out_printf '%s' "${res_file##*.}"
}


##
## READONLY SCRIPT PATH VARIABLES
##

#
# resolve the main script relative file path (as determind by the bash interpreter)
#
readonly _MAIN_PATH_RELT="${BASH_SOURCE[-1]}"

#
# resolve the main script absolute, resolved, real file path
#
readonly _MAIN_PATH_REAL="$(
  resolve_path_real "${_MAIN_PATH_RELT}"
)"

#
# resolve the main script absolute, resolved, real directory path
#
readonly _MAIN_PATH_BASE="$(
  resolve_path_base "${_MAIN_PATH_REAL}"
)"

#
# resolve the main script resolved, real file name
#
readonly _MAIN_FILE_NAME="$(
  resolve_file_name "${_MAIN_PATH_REAL}"
)"

#
# resolve the main script file extension
#
readonly _MAIN_FILE_EXTS="$(
  resolve_file_exts "${_MAIN_PATH_REAL}"
)"

#
# resolve the main script file base name
#
readonly _MAIN_FILE_BASE="$(
  resolve_file_root "${_MAIN_PATH_REAL}"
)"

#
# resolve the libraries relative file path (as determind by the bash interpreter)
#
readonly _LIBS_PATH_RELT="$(
  resolve_path_base "${BASH_SOURCE[0]}"
)/.."

#
# resolve the libraries absolute, resolved, real file path
#
readonly _LIBS_PATH_REAL="$(
  resolve_path_real "${_LIBS_PATH_RELT}"
)"

#
# resolve the libraries relative file path (as determind by the bash interpreter)
#
readonly _BINS_PATH_RELT="$(
  resolve_path_base "${BASH_SOURCE[0]}"
)/../../bin/activated"

#
# resolve the libraries absolute, resolved, real file path
#
readonly _BINS_PATH_REAL="$(
  resolve_path_real "${_BINS_PATH_RELT}"
)"
