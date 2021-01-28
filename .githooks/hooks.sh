#!/bin/bash

execute_hooks() {
  for script in .githooks/$1.d/*; do
    if [ -f $script -a -x $script ]; then
      $script || return $?
    fi
  done
}
