#!/bin/sh

BASEDIR=$(dirname "$0")
cd $BASEDIR


./hotspot 1024 1024 500000 $OMP_NUM_THREADS ~/rodinia_3.1/data/hotspot/temp_1024 ~/rodinia_3.1/data/hotspot/power_1024 output.out

# Usage: ./hotspot <grid_rows> <grid_cols> <sim_time> <no. of threads><temp_file> <power_file>
#  2         <grid_rows>         - number of rows in the grid (positive integer)
#  3         <grid_cols>         - number of columns in the grid (positive integer)
#  4         <sim_time>          - number of iterations
#  5         <no. of threads>    - number of threads
#  6         <temp_file>         - name of the file containing the initial temperature values of each cell
#  7         <power_file>        - name of the file containing the dissipated power values of each cell

