#!/bin/sh
 
BASEDIR=$(dirname "$0")
cd $BASEDIR

for i in {1..60}
do
    ./bots-sparselu  -n  100 -m  25 > botsspar.out 2>> botsspar.err
done
