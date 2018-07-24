#!/bin/sh
     
BASEDIR=$(dirname "$0")
cd $BASEDIR

specperl $SPEC/bin/specdiff -m -l 10  --abstol 1e-06  --reltol 0.2 $SPEC/benchspec/OMP2012/363.swim/data/ref/output/SWIM7 SWIM7 > SWIM7.cmp
specperl $SPEC/bin/specdiff -m -l 10  --abstol 1e-06  --reltol 0.001 $SPEC/benchspec/OMP2012/363.swim/data/ref/output/swim.out swim.out > swim.out.cmp
