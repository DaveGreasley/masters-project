#!/bin/sh
 
BASEDIR=$(dirname "$0")
cd $BASEDIR

./md_omp > 1.out 2>> 1.err
