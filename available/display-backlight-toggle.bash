#!/bin/bash

if [[ ${1} == 'off' ]]; then
  printf 'Backlight state: OFF\n'
  sudo bash -c 'echo 1 > /sys/class/backlight/rpi_backlight/bl_power'
else
  printf 'Backlight state: ON\n'
  sudo bash -c 'echo 0 > /sys/class/backlight/rpi_backlight/bl_power'
fi
