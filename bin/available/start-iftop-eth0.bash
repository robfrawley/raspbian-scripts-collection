#!/bin/bash

NCURSES_NO_UTF8_ACS=1 sudo iftop -i eth0 2> /dev/null
