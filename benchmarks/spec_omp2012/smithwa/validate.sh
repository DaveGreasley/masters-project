#!/bin/sh

BASEDIR=$(dirname "$0")
cd $BASEDIR

specperl $SPEC/bin/specdiff -m -l 10  --reltol 1e-06 $SPEC/benchspec/OMP2012/372.smithwa/data/ref/output/refset1.out refset1.out > refset1.out.cmp
specperl $SPEC/bin/specdiff -m -l 10  --reltol 1e-06 $SPEC/benchspec/OMP2012/372.smithwa/data/ref/output/refset2.out refset2.out > refset2.out.cmp
