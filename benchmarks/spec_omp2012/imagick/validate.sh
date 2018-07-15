#!/bin/sh
 
BASEDIR=$(dirname "$0")
cd $BASEDIR

specperl /home/dave/Documents/project/benchmarks/omp2012-1.0/bin/specdiff -m -l 10  --reltol 0.01 /home/dave/Documents/project/benchmarks/omp2012-1.0/benchspec/OMP2012/367.imagick/data/train/output/val1.out val1.out > val1.out.cmp
