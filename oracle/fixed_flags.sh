export OMP_NUM_THREADS=35
export OMP_PROC_BIND=close
export OMP_PLACES=cores

python3 ../scripts/fixed_flags.py
