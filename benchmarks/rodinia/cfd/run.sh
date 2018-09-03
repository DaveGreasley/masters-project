#!/bin/sh
 
BASEDIR=$(dirname "$0")
cd $BASEDIR


for i in {1..5}
do
    ./euler3d_cpu ~/rodinia_3.1/data/cfd/fvcorr.domn.193K
done
