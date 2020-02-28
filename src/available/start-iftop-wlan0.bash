#!/bin/bash

NCURSES_NO_UTF8_ACS=1 sudo iftop -i wlan0 2> /dev/null
