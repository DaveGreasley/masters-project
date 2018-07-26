#!/bin/sh
 
BASEDIR=$(dirname "$0")
cd $BASEDIR

specperl $SPEC/bin/specdiff -m -l 10  --abstol 1e-07 $SPEC/benchspec/OMP2012/358.botsalgn/data/train/output/botsalgn.out botsalgn.out > botsalgn.out.cmp

