./kmeans_openmp/kmeans -n $OMP_NUM_THREADS -i ~/rodinia_3.1/data/kmeans/kdd_cup 

#Usage: ./kmeans [switches] -i filename
#       -i filename          : file containing data to be clustered
#       -b                   : input file is in binary format
#       -k                   : number of clusters (default is 5) 
#       -t threshold     : threshold value
#       -n no. of threads    : number of threads
