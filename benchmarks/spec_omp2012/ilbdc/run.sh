#!/bin/sh
 
BASEDIR=$(dirname "$0")
cd $BASEDIR

./ilbdc > ilbdc.out 2>> ilbdc.err

