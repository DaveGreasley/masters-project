module mod_preproc

  !=======================================================================
  !
  !     Preprocessor to generate an 1-D vector of the fluid cells and
  !     record their adjacency
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
  !     originally motivated and based on sequential version (2004-2006) by
  !
  !             Joerg BERNSDORF (bernsdorf@ccrl-nece.de)
  !             C&C Research Laboratories, NEC Europe Ltd.,
  !             Rathausallee 10, D-53757 St.Augustin, GERMANY
  !
  !     and based on cache optimizations (2005-2007) by
  !
  !             Thomas ZEISER (thomas.zeiser@rrze.uni-erlangen.de)
  !             Regionales Rechenzentrum Erlangen
  !             Martensstrasse 1, 91058 Erlangen, GERMANY
  !
  !             Stefan DONATH (stefan.donath@rrze.uni-erlangen.de)
  !             Regionales Rechenzentrum Erlangen
  !             Martensstrasse 1, 91058 Erlangen, GERMANY
  !
  !     and based on benchmark codes from RRZE (2002) by Thomas Zeiser/LSTM
  !
  !=======================================================================
  !
  ! Special benchmark kernel derived from ILBDC data structures
  ! compiled by Thomas Zeiser, RRZE
  !
  ! Release: $Id: 0.1 $
  !
  !=======================================================================

  public read_param
  public define_local_numbering
  public gen_adj_push
  public gen_adj_pull

CONTAINS

  ! === read parameters from file ========================================

  subroutine read_param(gx,gy,gz,geonme,blockingfactor,max_runtime,max_iterat,omega,aomega)
    use mod_constants
    implicit none
    integer, intent(out) :: gx,gy,gz,blockingfactor,max_runtime,max_iterat
    character(len=30), intent(out) :: geonme
    real(fpsize), intent(out) :: omega,aomega

    ! runtime configuration via namelist
    namelist /input/ gx,gy,gz,geonme,blockingfactor,max_runtime,max_iterat
    ! these two params are fixed for the moment:  ,omega,aomega

    ! some defaults
    gx = 100
    gy = 100
    gz = 100
    geonme = "#sample#channel#"
    blockingfactor = 1
    omega  = 1.5d0
    aomega = 1.4d0
    ! maximum runtime in seconds or maximum number of iterations
    max_runtime = 120
    max_iterat  = 100

    open(10,file="input.par", status="old", err=900)
    read(10, nml=input, err=900, end=900)
    close(10)
    write(*,*)
    write(*,*) "  domain size gx*gy*gz = ", gx,"*",gy,"*",gz
    write(*,*) "  geometry             = ", geonme
    write(*,*) "  blockingfactor       = ", blockingfactor
    write(*,*) "  max_runtime          = ", max_runtime
    write(*,*) "  max_iterat           = ", max_iterat
    write(*,*)

    return

900 write(*,*) "ERROR reading input.par! Check input.par_chk for format."
    close(10)
    open(10,file="input.par_chk")
    write(10, nml=input)
    close(10)
    stop

  end subroutine read_param

  ! === define local node numbering ======================================

  subroutine define_local_numbering(gx,gy,gz,blockingfactor,cidx)
    implicit none
    integer, intent(in)    :: gx,gy,gz,blockingfactor
    integer, intent(inout) :: cidx(gx,gy,gz)

    integer :: i,j,k,ii,jj,kk
    integer :: global_idx

    ! assign a unique global cidx to all fluid nodes and zero to solid nodes
    global_idx = 0

    do kk = 1, gz, blockingfactor
       do jj = 1, gy, blockingfactor
          do ii = 1, gx, blockingfactor

             do k = kk, min(kk+blockingfactor-1, gz)
                do j = jj, min(jj+blockingfactor-1, gy)
                   do i = ii, min(ii+blockingfactor-1, gx)
                      if ( cidx(i,j,k) .ne. 0 ) then
                         global_idx = global_idx + 1
                         cidx(i,j,k) = global_idx
                      end if
                   end do
                end do
             end do

          end do
       end do
    end do

  end subroutine define_local_numbering

  ! === generate the adjacency cidx vector (for push: coll-stream) ======

  ! RISC variant of gen_adj_pu{sh,ll}

  subroutine gen_adj_push(gx,gy,gz,cidx,send,n_cells)
    use mod_constants
    implicit none
    integer, intent(in)  :: gx,gy,gz,n_cells
    integer, intent(in)  :: cidx(gx,gy,gz)
    integer, intent(out) :: send(QN19*n_cells)

    integer i,j,k,i_p,i_m,j_p,j_m,k_p,k_m

    do k = 1, gz
       do j = 1, gy
          do i = 1, gx
             ! only process fluid cells
             if ( cidx(i,j,k) .ne. 0) then
                ! we use periodicity for now
                i_p = i+1; if ( i_p .gt. gx )  i_p =  1
                i_m = i-1; if ( i_m .lt. 1  )  i_m = gx
                j_p = j+1; if ( j_p .gt. gy )  j_p =  1
                j_m = j-1; if ( j_m .lt. 1  )  j_m = gy
                k_p = k+1; if ( k_p .gt. gz )  k_p =  1
                k_m = k-1; if ( k_m .lt. 1  )  k_m = gz
                call populate_send(i_p,j_p,k  , Q19_NE , Q19_SW)
                call populate_send(i  ,j_p,k  , Q19_N  , Q19_S )
                call populate_send(i_m,j_p,k  , Q19_NW , Q19_SE)
                call populate_send(i_m,j  ,k  , Q19_W  , Q19_E )
                call populate_send(i_m,j_m,k  , Q19_SW , Q19_NE)
                call populate_send(i  ,j_m,k  , Q19_S  , Q19_N )
                call populate_send(i_p,j_m,k  , Q19_SE , Q19_NW)
                call populate_send(i_p,j  ,k  , Q19_E  , Q19_W )
                call populate_send(i  ,j  ,k_p, Q19_T  , Q19_B )
                call populate_send(i_p,j  ,k_p, Q19_TE , Q19_BW)
                call populate_send(i  ,j_p,k_p, Q19_TN , Q19_BS)
                call populate_send(i_m,j  ,k_p, Q19_TW , Q19_BE)
                call populate_send(i  ,j_m,k_p, Q19_TS , Q19_BN)
                call populate_send(i  ,j  ,k_m, Q19_B  , Q19_T )
                call populate_send(i_p,j  ,k_m, Q19_BE , Q19_TW)
                call populate_send(i  ,j_p,k_m, Q19_BN , Q19_TS)
                call populate_send(i_m,j  ,k_m, Q19_BW , Q19_TE)
                call populate_send(i  ,j_m,k_m, Q19_BS , Q19_TN)
             end if
          end do
       end do
    end do

    return

  contains

    subroutine populate_send(i_nxt,j_nxt,k_nxt,mydir,antidir)
      implicit none
      integer, intent(in)    :: i_nxt,j_nxt,k_nxt,mydir,antidir

      integer :: pos

      ! formula functions for cidx access
      integer POS_IDX,F_IDX,Fnode,Fdir
      POS_IDX(Fnode,Fdir) = (Fnode-1)*QN19 + Fdir
      F_IDX(Fnode,Fdir)   = (Fdir-1)*n_cells + Fnode

      pos = POS_IDX(cidx(i,j,k), mydir)
      ! Fortran does _not_ guarantee that logical operations are executed from
      ! left-to-right and that processing is stopped as soon as the final result
      ! is known! Thus, we have to write some slightly ugly code to prevent
      ! index bound violations
      if ( i_nxt.gt.gx .or. i_nxt.lt.1 .or.                                    &
           j_nxt.gt.gy .or. j_nxt.lt.1 .or.                                    &
           k_nxt.gt.gz .or. k_nxt.lt.1 ) then
         ! neighbour does not exist => write back to self in opposite direction
         send(pos) = F_IDX(cidx(i    ,j    ,k    ), antidir)
     else if ( cidx(i_nxt,j_nxt,k_nxt).eq.0 ) then
         ! neighbour is non-fluid => write back to self in opposite direction
         send(pos) = F_IDX(cidx(i    ,j    ,k    ), antidir)
      else
         ! neighbour is fluid     => store distribution offset
         send(pos) = F_IDX(cidx(i_nxt,j_nxt,k_nxt), mydir)
      end if

    end subroutine populate_send

  end subroutine gen_adj_push


end module mod_preproc
