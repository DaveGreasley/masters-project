#!/bin/sh
 
BASEDIR=$(dirname "$0")
cd $BASEDIR

for i in {1..10}
do
    ./swim < swim.in > swim.out 2>> swim.err
done
