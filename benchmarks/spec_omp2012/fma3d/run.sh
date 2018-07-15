#!/bin/sh
 
BASEDIR=$(dirname "$0")
cd $BASEDIR

./fma3d > fma3d.out 2>> fma3d.err
