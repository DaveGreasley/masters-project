program ilbdc_kernel

  !=======================================================================
  !
  !     Sequential benchmark kernel for ILBDC-like data structures
  !
  !=======================================================================
  !
  !     Author: Thomas ZEISER (thomas.zeiser@rrze.uni-erlangen.de)
  !             Regionales Rechenzentrum Erlangen
  !             Martensstrasse 1, 91058 Erlangen, GERMANY
  !
  !             THIS "SEQUENTIAL BENCHMARK KERNEL" IS CURRENTLY
  !             CONSIDERED AS A NON-CORE EXTENSION.
  !             ALL RIGHTS RESERVED BY RRZE - IN PARTICULAR FOR
  !             USE WITHIN BMBF-SKALB.
  !
  !     originally motivated and based on sequential version (2004-2007) by
  !
  !             Joerg BERNSDORF (bernsdorf@ccrl-nece.de)
  !             C&C Research Laboratories, NEC Europe Ltd.,
  !             Rathausallee 10, D-53757 St.Augustin, GERMANY
  !
  !     and based on cache optimizations (2005-2008) by
  !
  !             Thomas ZEISER (thomas.zeiser@rrze.uni-erlangen.de)
  !             Regionales Rechenzentrum Erlangen
  !             Martensstrasse 1, 91058 Erlangen, GERMANY
  !
  !             Stefan DONATH (stefan.donath@rrze.uni-erlangen.de)
  !             Regionales Rechenzentrum Erlangen
  !             Martensstrasse 1, 91058 Erlangen, GERMANY
  !
  !=======================================================================
  !
  ! Special benchmark kernel derived from ILBDC data structures
  ! compiled by Thomas Zeiser, RRZE
  !
  ! Release: $Id: 0.1 $
  !
  !=======================================================================

  use mod_benchgeo
  use mod_constants
  use mod_preproc
  use mod_relax

  implicit none

  ! size of the computational domain and blocking factor
  integer :: gx,gy,gz,blockingfactor

  ! geometry type
  character(len=30) :: geonme

  ! number of fluid nodes
  integer :: n_cells

  ! maximal runtime or iterations
  integer :: max_runtime, max_iterat

  ! global index array (gx,gy,gz)
  integer, allocatable :: cidx(:,:,:)

  ! connectivity vector (QN19*n_cells)
  integer, allocatable :: send(:)

  ! actual data (Q19*n_cells,0:1)
  real(fpsize), allocatable :: f_data(:,:)

#if !defined(SPEC)
#ifdef __INTEL_COMPILER
  ! http://www.blogs.uni-erlangen.de/hager/stories/1737/
!DEC$ ATTRIBUTES ALIGN: 16 :: send
!DEC$ ATTRIBUTES ALIGN: 16 :: f_data
#endif
#endif

  real(fpsize) :: omega,aomega

  integer :: t_now,t_nxt
  real*8  :: time_wall_loop_end, time_wall_loop_start, run_time
  integer :: iterat, iterat_done, i_ct,i_dir

#if defined(SPEC_OMP) || defined(_OPENMP)
  external omp_get_num_procs,omp_get_max_threads
  integer  omp_get_num_procs,omp_get_max_threads
#endif   /* _OPENMP */

    ! formula functions for index access
    integer POS_IDX,F_IDX,Fnode,Fdir
    POS_IDX(Fnode,Fdir) = (Fnode-1)*QN19 + Fdir
    ! RISC optimized
    F_IDX(Fnode,Fdir)   = (Fdir-1)*n_cells + Fnode

  write(*,*) "============================================================"
  write(*,*)
  write(*,*) " sequential benchmark kernel for ILBDC-like data structures"
  write(*,*)
  write(*,*) "   (c) Thomas Zeiser, 2008-2011"
  write(*,*) "       THIS SEQUENTIAL BENCHMARK KERNEL IS CURRENTLY"
  write(*,*) "       CONSIDERED AS A NON-CORE EXTENSION OF ILBDC."
  write(*,*) "       ALL RIGHTS RESERVED BY RRZE - IN PARTICULAR"
  write(*,*) "       FOR USE WITHIN BMBF-SKALB OR OTHER PROJECTS."
  write(*,*)
  write(*,*) "  motivated and originally based on serial ILBDC code by"
  write(*,*) "          Joerg BERNSDORF, NLE-IT, 2004-2007"
  write(*,*) "          Thomas ZEISER, RRZE, 2005-2008"
  write(*,*) "          and others"
  write(*,*)
  write(*,*) "============================================================"
  write(*,*) "  FP-size = ", fpsize
  write(*,*) "  using Structure-of-Arrays ijkQ"
  write(*,*) "  using NO-SPLIT"
#if defined(SPEC) 
  write(*,*) "  OpenMP: num_procs   = ", 0
  write(*,*) "          max_threads = ", 0
#elif defined(_OPENMP)
  write(*,*) "  OpenMP: num_procs   = ", omp_get_num_procs()
  write(*,*) "          max_threads = ", omp_get_max_threads()
#endif   /* _OPENMP */
  write(*,*) "============================================================"

  ! === do preprocessing =======================================================

  write(*,*) "reading input parameters ..."
  call read_param(gx,gy,gz,geonme,blockingfactor,max_runtime,max_iterat,omega,aomega)

  write(*,*) "setting up geometric structure ..."
  allocate( cidx(gx,gy,gz) )  ! (temporary) node information
  call benchgeo_setup(gx,gy,gz,geonme,cidx,n_cells)

#ifdef VECTOR_ALIGNED
  ! ensure proper alignment by padding if necessary; unused cells
  ! will exchange data locally with themselves, thus, do not hurt
  if ( mod(n_cells,2) .ne. 0 ) then
     n_cells = n_cells + 1
     write(*,*) "... padding to have even number of fluid cells and proper alignment"
  end if
#endif

  write(*,*) "... sorting cells"
  call define_local_numbering(gx,gy,gz,blockingfactor,cidx)

  write(*,*) "... generating connectivity list"
  allocate(send(QN19*n_cells)) ! allocate connectivity vector
  ! NUMA-init
#if defined(SPEC_OMP) || defined(_OPENMP)
!$OMP PARALLEL DO DEFAULT(NONE) SCHEDULE(RUNTIME)                              &
!$OMP&SHARED(send,n_cells) PRIVATE(i_ct,i_dir)
#endif   /* _OPENMP */
  do i_ct = 1, n_cells
     do i_dir=1, QN19
        ! initialize with "send to self" which is suitable for
        ! cells created owing to padding - all other values
        ! will be overwritten by gen_adj_push but we need a
        ! NUMA first-touch initialization anyway
        send( POS_IDX(i_ct,i_dir) ) = F_IDX(i_ct, i_dir)
     end do
  end do
  call gen_adj_push(gx,gy,gz,cidx,send,n_cells)

  ! === initialize flow solver =================================================

  write(*,*) "allocating and initializing distribution functions ..."
  allocate(f_data(n_cells*Q19,0:1))
  ! NUMA-init
#if defined(SPEC_OMP) || defined(_OPENMP)
!$OMP PARALLEL DO DEFAULT(NONE)  SCHEDULE(RUNTIME)                             &
!$OMP&SHARED(f_data,n_cells) PRIVATE(i_ct,i_dir)
#endif   /* _OPENMP */
  do i_ct = 1, n_cells
     do i_dir=1, Q19
        f_data( F_IDX(i_ct,i_dir), 0) = 0.d0
     end do
  end do
#if defined(SPEC_OMP) || defined(_OPENMP)
!$OMP PARALLEL DO DEFAULT(NONE)  SCHEDULE(RUNTIME)                             &
!$OMP&SHARED(f_data,n_cells) PRIVATE(i_ct,i_dir)
#endif   /* _OPENMP */
  do i_ct = 1, n_cells
     do i_dir=1, Q19
        f_data( F_IDX(i_ct,i_dir), 1) = 0.d0
     end do
  end do

  ! === run flow solver ========================================================

  t_now = 0; t_nxt = 1
  call init_flowfield(f_data(:,t_now), n_cells)

  write(*,*) "starting simulation now (push) ..."

  ! get start time
  time_wall_loop_start = get_wtime()

  iterat_done = max_iterat
  do iterat=1, max_iterat
     ! call flow solver
     call relax_collstream(f_data(:,t_now),f_data(:,t_nxt),send,n_cells,       &
                           omega,aomega)

#if !defined(SPEC)
     ! check elapsed time; exit if >max_runtime
     if ( get_wtime() - time_wall_loop_start .gt. max_runtime ) then
        iterat_done = iterat
        exit
     end if
#endif

     ! swap time toggle
     t_now = 1-t_now; t_nxt = 1-t_nxt
  end do

  ! get end time
  time_wall_loop_end = get_wtime()

  write(*,*) "... done; did ", iterat_done, " iterations"

  ! ***TODO***: validate data

  ! write timing statistics
  run_time = time_wall_loop_end - time_wall_loop_start

#if defined(SPEC)
  write(*,*) "elapsed-time for main simulation loop: ", 0.d0
  write(*,'(a,f7.2)') " push/SOA - true FluidMLUPS:", 0.d0
  write(*,'(4f10.4)') f_data(100,t_now), f_data(2200,t_now),                  &
                       f_data(3300,t_now), f_data(4400,t_now) 
#else
  write(*,*) "elapsed-time for main simulation loop: ", run_time
  write(*,'(a,f7.2)') " push/SOA - true FluidMLUPS:",                         &
       (dble(n_cells)*iterat_done) / run_time / 1000000.d0
#endif

  ! === run flow solver ========================================================

  write(*,*)
  write(*,*) "program finished!"
  write(*,*)

  stop

contains

  ! === get walltime =====================================================

  function get_wtime()

    real*8 :: get_wtime

#if !defined(SPEC)
    ! we use system_clock to get the (relative) _elapsed_ time
    ! (transformation to seconds required!)

#if defined(__SX__) || defined(__G95__)
    ! NEC SX and g95 require "default integer type" for system_clock
    integer sysclock_time, sysclock_step
#else
    ! at least with Intel compiler, integer*8 must be used to avoid overflows
    integer(kind=8) sysclock_time, sysclock_step
#endif

    call system_clock(sysclock_time,sysclock_step)
    get_wtime = sysclock_time / dble(sysclock_step)
#else
    get_wtime = 0.d0
#endif

  end function get_wtime

  ! === initialize flow field =====================================================

  subroutine init_flowfield(f_now,n_cells)
    use mod_constants
    implicit none
    integer, intent(in)  :: n_cells
    real(fpsize), intent(out)  :: f_now(n_cells*Q19)

    ! ***TODO***: initialization; dummy for now
    f_now(:) = 1.d0

  end subroutine init_flowfield

end program ilbdc_kernel


