#!/bin/sh
 
BASEDIR=$(dirname "$0")
cd $BASEDIR


for i in {1..50}
do
    ./smithwaterman 32 > trainset.out 2>> trainset.err
done
