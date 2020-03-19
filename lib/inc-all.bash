#!/bin/bash

readonly _INC_ALL_FILE="$(
  realpath -e "${BASH_SOURCE[0]}" 2> /dev/null || printf -- '%s' "${BASH_SOURCE[0]}"
)"
readonly _INC_ALL_PATH="$(
  dirname "${_INC_ALL_FILE}" 2> /dev/null
)"

source "${_INC_ALL_PATH}/core/core-lib.bash"
source "${_INC_ALL_PATH}/math/math-lib.bash"
source "${_INC_ALL_PATH}/outs/outs-lib.bash"
source "${_INC_ALL_PATH}/usys/usys-lib.bash"
