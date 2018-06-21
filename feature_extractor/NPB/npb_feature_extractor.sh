ck set env tags=compiler,ctuning-cc bat_file=tmp-ck-env.sh --bat_new --print && . ./tmp-ck-env.sh

whereis $CK_CC
whereis $CK_F95

#gfortran -c   -fopenmp -mcmodel=medium ua.f

cd BT
$CK_F95 -O3 -c -fopenmp -mcmodel=medium bt.f --ct-extract-features -lm

cd ../CG
$CK_F95 -O3 -c -fopenmp -mcmodel=medium cg.f --ct-extract-features -lm

cd ../EP
$CK_F95 -O3 -c -fopenmp -mcmodel=medium ep.f --ct-extract-features -lm

cd ../FT
$CK_F95 -O3 -c -fopenmp -mcmodel=medium ft.f --ct-extract-features -lm

cd ../IS
$CK_CC -O3 -c -fopenmp -mcmodel=medium is.c --ct-extract-features -lm

cd ../LU
$CK_F95 -O3 -c -fopenmp -mcmodel=medium lu.f --ct-extract-features -lm

cd ../MG
$CK_F95 -O3 -c -fopenmp -mcmodel=medium mg.f --ct-extract-features -lm

cd ../SP
$CK_F95 -O3 -c -fopenmp -mcmodel=medium sp.f --ct-extract-features -lm

cd ../UA
$CK_F95 -O3 -c -fopenmp -mcmodel=medium ua.f --ct-extract-features -lm

