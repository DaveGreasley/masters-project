#!/bin/sh
 
BASEDIR=$(dirname "$0")
cd $BASEDIR

./kdtree 1400000 4 2 > refset.out 2>> refset.err
