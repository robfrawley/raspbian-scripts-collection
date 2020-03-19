#!/bin/bash


##
## FUNCTION DEFINITIONS
##

#
# round number to configured precision
#
function number_round() {
  local float_val="${1}"
  local precision="${2:-2}"

  out_printf "%.${precision}f" "${float_val}"

  #  out_printf "%.${precision}f" $(
  #    run_math_stmt \
  #      'scale=%1$d;(((10^%1$d)*%2$f)+0.5)/(10^%1$d)' \
  #      -1 \
  #      "${precision}" \
  #      "${float_val}"
  #  )

  #$(
  #    echo "scale=${precision};(((10^${precision})*${float_val})+0.5)/(10^${precision})" \
  #      | bc
  #  )

}

#
# run bc math calculation providing statement format, precision, followed by any replacement values
#
function run_math_stmt() {
  local statement="${1}"
  local precision="${2:-2}"
  local arguments=("${@:3}")
  local final_res

  number_round $(
    out_printf \
      "scale=%d;$(out_printf "${statement}" "${arguments[@]}" || out_printf "${statement}")\n" \
      "${precision}" | \
    bc
  ) "${precision}"
}

#function run_math_stmt_OLD() {
#  local statement="${1}"
#  local precision="${2:-2}"
#  local arguments=("${@:3}")
#
#  number_round $(
#    echo "scale=${precision};$(
#      out_printf "${statement}" "${arguments[@]}" || out_printf "${statement}"
#    )" | bc
#  ) ${precision}
#}

#
# calculate integer for switched base integer
#
function number_base_switch() {
  local numerator="${1}"
  local denom_cur="${2:-100}"
  local denom_new="${3:-100}"
  local precision="${4:-2}"

  run_math_stmt "${numerator}*${denom_new}/${denom_cur}" ${precision}
}

#
# round float down to nearest whole integer
#
function number_floor() {
  awk '{print int($0)}' <<< "${1}"
}

#
# round float up to nearest whole integer
#
function number_ceil() {
  awk '{print ($0-int($0)>0)?int($0)+1:int($0)}' <<< "${1}"
}
