#!/bin/sh
      
BASEDIR=$(dirname "$0")
cd $BASEDIR

specperl $SPEC/bin/specdiff -m -l 10  --abstol 1e-07  --reltol 1e-07 $SPEC/benchspec/OMP2012/359.botsspar/data/ref/output/botsspar.out botsspar.out > botsspar.out.cmp
