#!/bin/bash
# user="$(echo $line | cut -d : -f 1)"

variable=$(echo $SHELL)
# echo $variable

if [ "$variable" == "/bin/zsh" ]; then
    echo "string matches"
else
    echo "error"
fi
