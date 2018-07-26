#!/bin/sh
 
BASEDIR=$(dirname "$0")
cd $BASEDIR

specperl $SPEC/bin/specdiff -m -l 10  --reltol 0.01 $SPEC/benchspec/OMP2012/367.imagick/data/train/output/val1.out val1.out > val1.out.cmp
