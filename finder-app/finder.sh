#!/bin/sh
echo $1 $2

if [ $# -ne 2 ];then
    echo "You should pass two argument, the first is a directory, and the second is a directory or a file"
    exit 1
fi

if [ ! -d "$1" ]; then
    echo $1 should be a directory
    exit 1
fi

x=$(find $1 -type f | wc -l)

y=`grep -R "$2" $1 | wc -l`

echo "The number of files are $x and the number of matching lines are $y"