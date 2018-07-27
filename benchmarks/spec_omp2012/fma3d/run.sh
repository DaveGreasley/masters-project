#!/bin/sh
 
BASEDIR=$(dirname "$0")
cd $BASEDIR


for i in {1..5}
do
    ./fma3d > fma3d.out 2>> fma3d.err
done
