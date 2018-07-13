ck set env tags=compiler,ctuning-cc bat_file=tmp-ck-env.sh --bat_new --print && . ./tmp-ck-env.sh

whereis $CK_CC
whereis $CK_F95

#gfortran -c   -fopenmp -mcmodel=medium ua.f

cd bwaves
$CK_F95 -O3 -c -fopenmp -fno-strict-aliasing -fno-range-check block_solver.fppized.f --ct-extract-features -lm

cd ../botsalgn
$CK_CC -O3 -c -DSPEC -DSPEC_OMP -DSPEC_OPENMP -DNDEBUG -fopenmp alignment.c --ct-extract-features -lm

cd ../botsspar
$CK_CC -O3 -c -DSPEC -DSPEC_OMP -DSPEC_OPENMP -DNDEBUG -fopenmp sparselu.c --ct-extract-features -lm

cd ../ilbdc
/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c  -fopenmp -fno-strict-aliasing -fno-range-check mod_constants.fppized.f90
$CK_F95 -O3 -c -fopenmp -fno-strict-aliasing -fno-range-check mod_relax.fppized.f90 --ct-extract-features -lm

#cd ../../../benchmarks/spec_omp2012/fma3d/
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o fma3d.o -fopenmp -fno-strict-aliasing -fno-range-check fma3d.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o beam_.o -fopenmp -fno-strict-aliasing -fno-range-check beam_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o come_from_arrays_.o -fopenmp -fno-strict-aliasing -fno-range-check come_from_arrays_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o include_file_.o -fopenmp -fno-strict-aliasing -fno-range-check include_file_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o penta_.o -fopenmp -fno-strict-aliasing -fno-range-check penta_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o segment_set_.o -fopenmp -fno-strict-aliasing -fno-range-check segment_set_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o body_force_.o -fopenmp -fno-strict-aliasing -fno-range-check body_force_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o indx_.o -fopenmp -fno-strict-aliasing -fno-range-check indx_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o periodic_bc_.o -fopenmp -fno-strict-aliasing -fno-range-check periodic_bc_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o sliding_interface_.o -fopenmp -fno-strict-aliasing -fno-range-check sliding_interface_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o constrained_node_.o -fopenmp -fno-strict-aliasing -fno-range-check constrained_node_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o layering_.o -fopenmp -fno-strict-aliasing -fno-range-check layering_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o plate_pair_.o -fopenmp -fno-strict-aliasing -fno-range-check plate_pair_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o sliding_node_.o -fopenmp -fno-strict-aliasing -fno-range-check sliding_node_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o contact_node_.o -fopenmp -fno-strict-aliasing -fno-range-check contact_node_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o location_.o -fopenmp -fno-strict-aliasing -fno-range-check location_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o platq_.o -fopenmp -fno-strict-aliasing -fno-range-check platq_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o spot_weld_.o -fopenmp -fno-strict-aliasing -fno-range-check spot_weld_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o contact_surface_.o -fopenmp -fno-strict-aliasing -fno-range-check contact_surface_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o lsold_.o -fopenmp -fno-strict-aliasing -fno-range-check lsold_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o platt_.o -fopenmp -fno-strict-aliasing -fno-range-check platt_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o spring_.o -fopenmp -fno-strict-aliasing -fno-range-check spring_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o coord_.o -fopenmp -fno-strict-aliasing -fno-range-check coord_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o massprop_.o -fopenmp -fno-strict-aliasing -fno-range-check massprop_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o pressure_bc_.o -fopenmp -fno-strict-aliasing -fno-range-check pressure_bc_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o spring_bc_.o -fopenmp -fno-strict-aliasing -fno-range-check spring_bc_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o damper_.o -fopenmp -fno-strict-aliasing -fno-range-check damper_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o material_.o -fopenmp -fno-strict-aliasing -fno-range-check material_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o property_.o -fopenmp -fno-strict-aliasing -fno-range-check property_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o state_variables_.o -fopenmp -fno-strict-aliasing -fno-range-check state_variables_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o damper_bc_.o -fopenmp -fno-strict-aliasing -fno-range-check damper_bc_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o mean_stress_.o -fopenmp -fno-strict-aliasing -fno-range-check mean_stress_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o shared_common_data.o -fopenmp -fno-strict-aliasing -fno-range-check shared_common_data.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o stress_.o -fopenmp -fno-strict-aliasing -fno-range-check stress_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o displacement_bc_.o -fopenmp -fno-strict-aliasing -fno-range-check displacement_bc_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o membq_.o -fopenmp -fno-strict-aliasing -fno-range-check membq_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o qa_record_.o -fopenmp -fno-strict-aliasing -fno-range-check qa_record_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o tabulated_function_.o -fopenmp -fno-strict-aliasing -fno-range-check tabulated_function_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o element_set_.o -fopenmp -fno-strict-aliasing -fno-range-check element_set_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o membt_.o -fopenmp -fno-strict-aliasing -fno-range-check membt_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o relink_scratch_.o -fopenmp -fno-strict-aliasing -fno-range-check relink_scratch_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o tetra_.o -fopenmp -fno-strict-aliasing -fno-range-check tetra_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o enumerated_sets_.o -fopenmp -fno-strict-aliasing -fno-range-check enumerated_sets_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o motion_.o -fopenmp -fno-strict-aliasing -fno-range-check motion_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o results_.o -fopenmp -fno-strict-aliasing -fno-range-check results_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o tied_bc_.o -fopenmp -fno-strict-aliasing -fno-range-check tied_bc_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o force_.o -fopenmp -fno-strict-aliasing -fno-range-check force_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o nodal_point_mass_.o -fopenmp -fno-strict-aliasing -fno-range-check nodal_point_mass_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o rigid_body_.o -fopenmp -fno-strict-aliasing -fno-range-check rigid_body_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o truss_.o -fopenmp -fno-strict-aliasing -fno-range-check truss_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o force_bc_.o -fopenmp -fno-strict-aliasing -fno-range-check force_bc_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o node_.o -fopenmp -fno-strict-aliasing -fno-range-check node_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o rigid_body_mass_.o -fopenmp -fno-strict-aliasing -fno-range-check rigid_body_mass_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o value_.o -fopenmp -fno-strict-aliasing -fno-range-check value_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o gauge1d_.o -fopenmp -fno-strict-aliasing -fno-range-check gauge1d_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o node_set_.o -fopenmp -fno-strict-aliasing -fno-range-check node_set_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o rigid_wall_bc_.o -fopenmp -fno-strict-aliasing -fno-range-check rigid_wall_bc_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o velocity_ic_.o -fopenmp -fno-strict-aliasing -fno-range-check velocity_ic_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o gauge2d_.o -fopenmp -fno-strict-aliasing -fno-range-check gauge2d_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o nonreflecting_bc_.o -fopenmp -fno-strict-aliasing -fno-range-check nonreflecting_bc_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o section_1d_.o -fopenmp -fno-strict-aliasing -fno-range-check section_1d_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o gauge3d_.o -fopenmp -fno-strict-aliasing -fno-range-check gauge3d_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o nrbc_data_.o -fopenmp -fno-strict-aliasing -fno-range-check nrbc_data_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o section_2d_.o -fopenmp -fno-strict-aliasing -fno-range-check section_2d_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o hexah_.o -fopenmp -fno-strict-aliasing -fno-range-check hexah_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o output_.o -fopenmp -fno-strict-aliasing -fno-range-check output_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o segment_.o -fopenmp -fno-strict-aliasing -fno-range-check segment_.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o lsold.o -fopenmp -fno-strict-aliasing -fno-range-check lsold.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o damper.o -fopenmp -fno-strict-aliasing -fno-range-check damper.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o spring.o -fopenmp -fno-strict-aliasing -fno-range-check spring.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o material_00.o -fopenmp -fno-strict-aliasing -fno-range-check material_00.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o material_10.o -fopenmp -fno-strict-aliasing -fno-range-check material_10.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o material_11.o -fopenmp -fno-strict-aliasing -fno-range-check material_11.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o material_17.o -fopenmp -fno-strict-aliasing -fno-range-check material_17.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o material_22.o -fopenmp -fno-strict-aliasing -fno-range-check material_22.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o material_25.o -fopenmp -fno-strict-aliasing -fno-range-check material_25.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o material_32.o -fopenmp -fno-strict-aliasing -fno-range-check material_32.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o material_33.o -fopenmp -fno-strict-aliasing -fno-range-check material_33.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o material_34a.o -fopenmp -fno-strict-aliasing -fno-range-check material_34a.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o material_36.o -fopenmp -fno-strict-aliasing -fno-range-check material_36.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o material_38.o -fopenmp -fno-strict-aliasing -fno-range-check material_38.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o material_dm.o -fopenmp -fno-strict-aliasing -fno-range-check material_dm.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o material_sp.o -fopenmp -fno-strict-aliasing -fno-range-check material_sp.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o sort.o -fopenmp -fno-strict-aliasing -fno-range-check sort.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o pdb.o -fopenmp -fno-strict-aliasing -fno-range-check pdb.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o beam.o -fopenmp -fno-strict-aliasing -fno-range-check beam.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o membq.o -fopenmp -fno-strict-aliasing -fno-range-check membq.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o membt.o -fopenmp -fno-strict-aliasing -fno-range-check membt.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o penta.o -fopenmp -fno-strict-aliasing -fno-range-check penta.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o tetra.o -fopenmp -fno-strict-aliasing -fno-range-check tetra.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o hexah.o -fopenmp -fno-strict-aliasing -fno-range-check hexah.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o platq.o -fopenmp -fno-strict-aliasing -fno-range-check platq.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o truss.o -fopenmp -fno-strict-aliasing -fno-range-check truss.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o platt.o -fopenmp -fno-strict-aliasing -fno-range-check platt.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o fma1.o -fopenmp -fno-strict-aliasing -fno-range-check fma1.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o getirv.o -fopenmp -fno-strict-aliasing -fno-range-check getirv.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o relink.o -fopenmp -fno-strict-aliasing -fno-range-check relink.f90
#/CK-TOOLS/gcc-milepost-4.4.4-linux-64/bin/gfortran -c -o output.o -fopenmp -fno-strict-aliasing -fno-range-check output.f90
#
#cd ../../../feature_extractor/SPEC/fma3d/
#$CK_F95 -c -o fma2.o -I/home/masters-project/benchmarks/spec_omp2012/fma3d -O3 -fopenmp -fno-strict-aliasing -fno-range-check --ct-extract-features ../../../benchmarks/spec_omp2012/fma3d/fma2.f90
