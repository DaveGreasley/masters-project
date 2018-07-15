#!/bin/sh
 
BASEDIR=$(dirname "$0")
cd $BASEDIR

./bots-sparselu  -n  100 -m  25 > botsspar.out 2>> botsspar.err
