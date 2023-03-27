#!/bin/bash
#usuario="$(echo $line | cut -d : -f 1)"

variable=$(echo $SHELL)
# echo $variable

if [ "$variable" == "/bin/zsh" ]; then
    echo "string igual"
else
    echo "erro"
fi