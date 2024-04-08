#!/usr/bin/env bash

HOME=$(pwd) bash -c ".local/bin/nvim -u .config/nvim/init.lua --headless -c 'colorscheme | qall' +cq $2 && echo 'Test pass'"
