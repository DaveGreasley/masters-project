ck set env tags=compiler,ctuning-cc bat_file=tmp-ck-env.sh --bat_new --print && . ./tmp-ck-env.sh

whereis $CK_CC
whereis $CK_F95

#gfortran -c   -fopenmp -mcmodel=medium ua.f

cd bwaves
$CK_F95 -O3 -c -fopenmp -fno-strict-aliasing -fno-range-check block_solver.fppized.f --ct-extract-features -lm

