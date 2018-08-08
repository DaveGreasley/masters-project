#!/bin/sh
 
BASEDIR=$(dirname "$0")
cd $BASEDIR

for i in {1..8}
do
    ./convert -shear 31 -resize 1280x960 -negate -edge 14 -implode 1.2 -flop -convolve 1,2,1,4,3,4,1,2,1 -edge 100 input1.tga output1.tga > convert1.out 2>> convert1.err
    ./ImageValidator expected1.tga output1.tga > val1.out 2>> val1.err
done

