#!/bin/sh
 
BASEDIR=$(dirname "$0")
cd $BASEDIR

#for i in {1..100}
#do
srad_v2/srad 8192 8192 0 127 0 127 $OMP_NUM_THREADS 0.5 500
#done


#128 //number of rows in the domain
#128 //number of cols in the domain
#0   //y1 position of the speckle
#31  //y2 position of the speckle
#0   //x1 position of the speckle
#31  //x2 position of the speckle
#4   //number of threads
#0.5 //Lambda value
#2   //number of iterations

