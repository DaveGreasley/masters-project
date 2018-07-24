#!/bin/sh
 
BASEDIR=$(dirname "$0")
cd $BASEDIR

specperl $SPEC/bin/specdiff -m -l 10  --reltol 0.01 $SPEC/benchspec/OMP2012/367.imagick/data/ref/output/val11.out val11.out > val11.out.cmp
specperl $SPEC/bin/specdiff -m -l 10  --reltol 0.01 $SPEC/benchspec/OMP2012/367.imagick/data/ref/output/val2.out val2.out > val2.out.cmp
specperl $SPEC/bin/specdiff -m -l 10  --reltol 0.01 $SPEC/benchspec/OMP2012/367.imagick/data/ref/output/val9.out val9.out > val9.out.cmp
