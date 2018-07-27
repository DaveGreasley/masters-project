#!/bin/sh
 
BASEDIR=$(dirname "$0")
cd $BASEDIR


for i in {1..3}
do
    ./bwaves 2>> bwaves.err
done
