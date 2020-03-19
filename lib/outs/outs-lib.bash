#!/bin/bash


##
## INTERNAL VARIABLE DEFINITION
##

#
# assign the verbosity level of script, following the below numerical rules
#
# -1 = silent
#  0 = fail
#  1 = warn,fail
#  2 = info,warn,fail
#  3 = debg,info,warn,fail
#
readonly _LIBS_OUTS_VERB_LEVEL="${VERBOSITY:-2}"

#
# assign the boolean state of debug, which is equivalant to a verbosity level of 3
#
readonly _LIBS_OUTS_VERB_DEBUG="${DEBUG:-0}"


##
## CORE OUTPUT FUNCTIONS
##

#
# auto-newline state accessor (getter or setter)
#
function out_auto_nl_accessor() {
  local assignment="${1:-false}"

  if [[ -z ${_LIBS_OUTS_AUTO_NEWLINE} ]]; then
    typeset -g _LIBS_OUTS_AUTO_NEWLINE=1
  fi

  if [[ ${assignment} != 'false' ]]; then
    _LIBS_OUTS_AUTO_NEWLINE="${assignment}"
  else
    out_printf '%s' "${_LIBS_OUTS_AUTO_NEWLINE}"
  fi
}

#
# enable auto-newline state
#
function out_auto_nl_enable() {
  out_auto_nl_accessor 1
}

#
# disable auto-newline state
#
function out_auto_nl_disable() {
  out_auto_nl_accessor 0
}

#
# checks if auto-newline behavior matches passed state
#
function is_out_auto_nl() {
  local state="${1:-1}"

  test $(out_auto_nl_accessor) -eq ${state}
}

#
# output newline
#
function out_newline() {
  local count="${1:-1}"

  for i in $(seq 1 "${count}"); do
    printf -- '\n'
  done
}

#
# output newline alias
#
function out_nl() {
  out_newline "${1}"
}

#
# output text using printf argument format
#
function out_printf() {
  printf -- "${@}" 2> /dev/null
}

#
# output text line using printf argument format
#
function out_printn() {
  out_printf "${1}" "${@:2}"

  if is_out_auto_nl; then
    out_newline
  fi
}


##
## VERBOSITY FUNCTIONS
##

#
# output verbosity level
#
function out_verb_level() {
  out_printf "${_LIBS_OUTS_VERB_LEVEL}"
}

#
# checks if output verbosity level is greater-than the passed level
#
function is_out_verb_level_gt() {
  local level="${1}"

  test ${_LIBS_OUTS_VERB_LEVEL} -gt ${level}
}

#
# checks if output verbosity level is greater-than or equal-to the passed level
#
function is_out_verb_level_ge() {
  local level="${1}"

  test ${_LIBS_OUTS_VERB_LEVEL} -ge ${level}
}

#
# output verbosity debug state
#
function out_verb_debug() {
  out_printf "${_LIBS_OUTS_VERB_DEBUG}"
}

#
# checks if output verbosity debug state is true
#
function is_out_verb_debug() {
  test ${_LIBS_OUTS_VERB_DEBUG} -eq 1
}


##
## INDENT FUNCTIONS
##

#
# output indentation accessor (getter or setter)
#
function out_indent_accessor() {
  local assignment="${1:-false}"

  if [[ -z ${_LIBS_OUTS_INDENT_SIZE} ]]; then
    typeset -g _LIBS_OUTS_INDENT_SIZE=0
  fi

  if [[ ${assignment} != 'false' ]]; then
    _LIBS_OUTS_INDENT_SIZE="${assignment}"
  else
    out_printf '%s' "${_LIBS_OUTS_INDENT_SIZE}"
  fi
}

#
# output indentation resetter to zero
#
function out_indent_reset() {
  out_indent_accessor 0
}

#
# output indentiation indent increment (add one to current integer value)
#
function out_indent_increment() {
  out_indent_accessor $(($(out_indent_accessor) + 1))
}

#
# output indentiation indent decrement (del one to current integer value)
#
function out_indent_decrement() {
  out_indent_accessor $(($(out_indent_accessor) - 1))

  if [[ $(out_indent_accessor) -lt 0 ]]; then
    out_indent_reset
  fi
}


##
## OUTPUT FUNCTIONS
##

#
# output any character sequence repeated x number of times
#
function out_repeat() {
  local text="${1}"
  local iter="${2:-2}"

  for i in $(seq 1 ${iter}); do
    out_printf '%s' "${text}"
  done
}


#
# output unix timestamp with a specified amount of nano-second precision
#
function out_unixtime() {
  local unix_nano_prec="${1:-0}"
  local outs_formatter="%.0${unix_nano_prec}f"
  local unix_nano_secs

  unix_nano_secs="$(
    date +%s\.%N 2> /dev/null
  )"

  out_printf "${outs_formatter}" "${unix_nano_secs}"
}

#
# output prefix for formatted lines (includes script basename, unixtime with 4-digit nano-second precision, and optional type/char qualifier)
#
function out_prefix() {
  local type="${1:-}"
  local char="${2:-}"

  out_printf '%s (' "${_MAIN_FILE_BASE}"

  if [[ -n ${char} ]] && [[ -n ${type} ]]; then
    out_printf '%s@' "${type,,}"
  fi

  out_printf '%s)' "$(out_unixtime "$(out_verb_level)")"

  if [[ -n ${char} ]] && [[ -n ${type} ]]; then
    out_printf ' %s' "$(out_repeat "${char}" 3)"
  fi

  out_printf '%s ' "$(
    out_repeat ' ' "$(out_indent_accessor)"
  )"
}

#
# output a title section opening line and increment indentation counter
#
function out_title_start() {
  if is_out_verb_level_ge 2 || is_out_verb_debug; then
    out_prefix 'head' '#'
    out_printn "START: ${1^^}" "${@:2}"
    out_indent_increment
  fi
}

#
# output a title section ending line and decrement indentation counter
#
function out_title_close() {
  if is_out_verb_level_ge 2 || is_out_verb_debug; then
    out_prefix 'head' '#'
    out_printn "CLOSE: ${1^^}" "${@:2}"
    out_indent_decrement
  fi
}

#
# output a line of prefixed, formatted text
#
function out_line() {
  out_prefix '' ''
  out_printn "${@}"
}


#
# output a line of debug-prefixed, formatted text
#
function out_debg() {
  if is_out_verb_level_ge 3 || is_out_verb_debug; then
    out_prefix 'debg' '*'
    out_printn "${@}"
  fi
}

#
# output a line of informational-prefixed, formatted text
#
function out_info() {
  if is_out_verb_level_ge 2 || is_out_verb_debug; then
    out_prefix 'info' '-'
    out_printn "${@}"
  fi
}

#
# output a line of warning-prefixed, formatted text
#
function out_warn() {
  if is_out_verb_level_ge 1 || is_out_verb_debug; then
    out_prefix 'warn' '!'
    out_printn "${@}"
  fi
}

#
# output a line of failure-prefixed, formatted text
#
function out_fail() {
  if is_out_verb_level_ge 0 || is_out_verb_debug; then
    out_prefix 'fail' '#'
    out_printn "${@}"
  fi
}


#
# output the beginning of a line for an action pending a result (with no following newline to allow for result output later)
#
function out_acts_init() {
  if is_out_verb_level_ge 2 || is_out_verb_debug; then
    out_prefix 'acts' '-'
    out_printf "${@}"
    out_printf ' ... '
  fi
}

#
# output the specified action result (followed by a newline)
#
function out_acts_rslt() {
  local text="${1^^}"
  local term="${2:-1}"
  local more

  if is_out_verb_level_ge 2 || is_out_verb_debug; then
    out_printf '[%s]' "${text}"

    if [[ $# -gt 2 ]]; then
      out_printf ' (%s)' "$(
        out_printf "${@:3}"
      )"
    fi

    if [[ ${term} -eq 1 ]] && is_out_auto_nl; then
      out_newline
    fi
  fi
}

#
# output a success action result (followed by a newline)
#
function out_acts_rslt_okay() {
  out_acts_rslt 'success' 1 "${@}"
}

#
# output a failure action result (followed by a newline)
#
function out_acts_rslt_fail() {
  out_acts_rslt 'failure' 1 "${@}"
}

#
# output a failure action result (followed by a newline)
#
function out_acts_rslt_unkn() {
  out_acts_rslt 'unknown' 1 "${@}"
}

#
# output an okay action result (followed by a newline)
#
function out_acts_rslt_auto() {
  local status_code="${1}"

  if [[ ${status_code} -eq 0 ]]; then
    out_acts_rslt_okay
  elif [[ ${status_code} -lt 0 ]]; then
    out_acts_rslt_unkn 'unrecognized return status code of "%d" was received' "${status_code}"
  else
    out_acts_rslt_fail 'return status code of "%d" was received' "${status_code}"
  fi
}

#
# legacy output function
#
function out_line_std() {
  local msg_assetion="${1:-Performing action...}"
  local msg_resulted="${2}"
  local msg_ext_args=("${@:3}")

  out_printf '[%s@%.3f] %s' "${_LIB_CALLER_NAME}" "$(date +%s\.%N)" "${msg_assetion}"

  if [[ -n ${msg_resulted} ]]; then
    out_printf ': %s' "${msg_resulted}"

    if [[ ${#msg_ext_args[@]} -gt 0 ]]; then
      for a in "${msg_ext_args[@]}"; do
        out_printf ' (%s)' "${a}"
      done
    fi
  fi

  if is_out_auto_nl; then
    out_printf '\n'
  fi
}
