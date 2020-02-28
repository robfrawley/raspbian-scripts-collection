#!/bin/bash

function main() {
  local level="${1:-100}"

  if [[ ${level} -gt 100 ]]; then
    level=100
  fi
  if [[ ${level} -lt 0 ]]; then
    level=0
  fi

  level=$(
    printf '%d * 255 / 100\n' ${level} \
      | bc 2> /dev/null
  )

  printf 'Backlight levels: %d\n' ${level}

  sudo bash -c "$(
    printf 'echo %d > /sys/class/backlight/rpi_backlight/brightness' ${level}
  )"
}

main "${1}"
