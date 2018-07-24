#!/bin/sh
    
BASEDIR=$(dirname "$0")
cd $BASEDIR

specperl $SPEC/bin/specdiff -m -l 10 $SPEC/benchspec/OMP2012/376.kdtree/data/ref/output/refset.out refset.out > refset.out.cmp
