ck set env tags=compiler,ctuning-cc bat_file=tmp-ck-env.sh --bat_new --print && . ./tmp-ck-env.sh

whereis $CK_CC
whereis $CK_F95
whereis $CK_CXX


#$CK_CC -O3 -c -DSPEC -DSPEC_OMP -DSPEC_OPENMP -DNDEBUG -I. -fopenmp  magick_effect.c --ct-extract-features -lm


$CK_CC -I/home/masters-project/benchmarks/parboil/common/include -O3  -D_OPENMP -fopenmp -c /home/masters-project/benchmarks/parboil/benchmarks/lbm/src/omp_base/lbm.c --ct-extract-features
