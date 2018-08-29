./sc_omp 10 20 256 524288 65536 1000 none output.txt $OMP_NUM_THREADS

#usage: ./sc_omp k1 k2 d n chunksize clustersize infile outfile nproc
#  k1:          Min. number of centers allowed
#  k2:          Max. number of centers allowed
#  d:           Dimension of each data point
#  n:           Number of data points
#  chunksize:   Number of data points to handle per step
#  clustersize: Maximum number of intermediate centers
#  infile:      Input file (if n<=0)
#  outfile:     Output file
#  nproc:       Number of threads to use
#
#if n > 0, points will be randomly generated instead of reading from infile.
