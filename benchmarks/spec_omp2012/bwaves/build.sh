../tools/specperl ../tools/specpp   -DSPEC -DSPEC_OMP -DSPEC_OPENMP -DNDEBUG   block_solver.F -o block_solver.fppized.f
gfortran -c -o block_solver.fppized.o -O2 -fopenmp -fno-strict-aliasing -fno-range-check block_solver.fppized.f
../tools/specperl ../tools/specpp   -DSPEC -DSPEC_OMP -DSPEC_OPENMP -DNDEBUG   flow_lam.F -o flow_lam.fppized.f
gfortran -c -o flow_lam.fppized.o -O2 -fopenmp -fno-strict-aliasing -fno-range-check flow_lam.fppized.f
../tools/specperl ../tools/specpp   -DSPEC -DSPEC_OMP -DSPEC_OPENMP -DNDEBUG   flux_lam.F -o flux_lam.fppized.f
gfortran -c -o flux_lam.fppized.o -O2 -fopenmp -fno-strict-aliasing -fno-range-check flux_lam.fppized.f
../tools/specperl ../tools/specpp   -DSPEC -DSPEC_OMP -DSPEC_OPENMP -DNDEBUG   jacobian_lam.F -o jacobian_lam.fppized.f
gfortran -c -o jacobian_lam.fppized.o -O2 -fopenmp -fno-strict-aliasing -fno-range-check jacobian_lam.fppized.f
../tools/specperl ../tools/specpp   -DSPEC -DSPEC_OMP -DSPEC_OPENMP -DNDEBUG   shell_lam.F -o shell_lam.fppized.f
gfortran -c -o shell_lam.fppized.o -O2 -fopenmp -fno-strict-aliasing -fno-range-check shell_lam.fppized.f
../tools/specperl ../tools/specpp   -DSPEC -DSPEC_OMP -DSPEC_OPENMP -DNDEBUG   fill1.F -o fill1.fppized.f
gfortran -c -o fill1.fppized.o -O2 -fopenmp -fno-strict-aliasing -fno-range-check fill1.fppized.f
../tools/specperl ../tools/specpp   -DSPEC -DSPEC_OMP -DSPEC_OPENMP -DNDEBUG   fill2.F -o fill2.fppized.f
gfortran -c -o fill2.fppized.o -O2 -fopenmp -fno-strict-aliasing -fno-range-check fill2.fppized.f
gfortran  -O2 -fopenmp -fno-strict-aliasing -fno-range-check          block_solver.fppized.o flow_lam.fppized.o flux_lam.fppized.o jacobian_lam.fppized.o shell_lam.fppized.o fill1.fppized.o fill2.fppized.o                     -o bwaves
