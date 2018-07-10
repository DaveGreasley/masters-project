export OMP_NUM_THREADS=34
export OMP_PROC_BIND=close
export OMP_PLACES=cores

nohup python3 ../scripts/combined_elimination.py  > /dev/null 2>&1 &
