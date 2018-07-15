#!/bin/sh
 
BASEDIR=$(dirname "$0")
cd $BASEDIR

./swim < swim.in > swim.out 2>> swim.err

