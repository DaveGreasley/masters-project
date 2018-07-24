#!/bin/sh

BASEDIR=$(dirname "$0")
cd $BASEDIR

specperl $SPEC/bin/specdiff -m -l 10  --abstol 1e-07 $SPEC/benchspec/OMP2012/360.ilbdc/data/ref/output/ilbdc.out ilbdc.out > ilbdc.out.cmp
