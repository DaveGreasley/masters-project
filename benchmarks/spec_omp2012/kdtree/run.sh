#!/bin/sh
 
BASEDIR=$(dirname "$0")
cd $BASEDIR

./kdtree 400000 10 2 > trainset.out 2>> trainset.err
