#!/bin/sh

BASEDIR=$(dirname "$0")
cd $BASEDIR

specperl $SPEC/bin/specdiff -m -l 10  --reltol 1e-06 $SPEC/benchspec/OMP2012/372.smithwa/data/train/output/trainset.out trainset.out > trainset.out.cmp
