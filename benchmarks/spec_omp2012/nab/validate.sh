#!/bin/sh
 
BASEDIR=$(dirname "$0")
cd $BASEDIR

specperl $SPEC/bin/specdiff -m -l 10  --reltol 0.04 $SPEC/benchspec/OMP2012/352.nab/data/train/output/aminos.out aminos.out > aminos.out.cmp
specperl $SPEC/bin/specdiff -m -l 10  --reltol 0.04 $SPEC/benchspec/OMP2012/352.nab/data/train/output/gcn4.out gcn4.out > gcn4.out.cmp
