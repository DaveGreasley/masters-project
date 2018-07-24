#!/bin/sh
 
BASEDIR=$(dirname "$0")
cd $BASEDIR

specperl $SPEC/bin/specdiff -m -l 10  --reltol 0.04 $SPEC/benchspec/OMP2012/352.nab/data/ref/output/1ea0.out 1ea0.out > 1ea0.out.cmp
