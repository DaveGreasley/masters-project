specperl $SPEC/bin/specdiff -m -l 10  --abstol 1e-05  --reltol 0.01 $SPEC/benchspec/OMP2012/362.fma3d/data/train/output/fma3d.out fma3d.out > fma3d.out.cmp
specperl $SPEC/bin/specdiff -m -l 10  --abstol 1e-05  --reltol 0.01 $SPEC/benchspec/OMP2012/362.fma3d/data/train/output/fmaelo fmaelo > fmaelo.cmp

