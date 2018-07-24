#!/bin/sh

BASEDIR=$(dirname "$0")
cd $BASEDIR

specperl $SPEC/bin/specdiff -m -l 10  --abstol 3e-07  --reltol 3e-07 $SPEC/benchspec/OMP2012/350.md/data/ref/output/md.log.01228060000 md.log.01228060000 > md.log.01228060000.cmp
