#!/bin/sh

if [ $# -ne 2 ]; then
    echo "the number of the argument should be 2, the first is a file, and second is a string"
    exit 1
fi


mkdir -p $(dirname $1)

echo $2 > $1