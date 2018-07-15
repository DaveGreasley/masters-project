#!/bin/sh
 
BASEDIR=$(dirname "$0")
cd $BASEDIR

./smithwaterman 32 > trainset.out 2>> trainset.err
