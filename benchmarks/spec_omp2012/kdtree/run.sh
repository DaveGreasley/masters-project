#!/bin/sh
 
BASEDIR=$(dirname "$0")
cd $BASEDIR


for i in {1..11}
do
    ./kdtree 400000 10 2 > trainset.out 2>> trainset.err
done
