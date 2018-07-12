module mod_relax
  !=======================================================================
  !
  ! Lattice Boltzmann collision-advection routines
  !
  ! Author(s): Thomas ZEISER (thomas.zeiser@rrze.uni-erlangen.de)
  ! Regionales Rechenzentrum Erlangen / HPC-Gruppe
  ! Martensstr. 1, 91058 Erlangen, GERMANY
  !
  !=======================================================================
  !
  ! Special benchmark kernel derived from ILBDC data structures
  ! compiled by Thomas Zeiser, RRZE
  !
  ! Release: $Id: 0.1 $
  !
  !=======================================================================

  public relax_collstream
  public relax_streamcoll

CONTAINS

  ! === push: collide-stream ===================================================

  subroutine relax_collstream(f_now,f_nxt,send,n_cells,omega,aomega)
    use mod_constants
    implicit none
    integer, intent(in)  :: n_cells,send(n_cells*QN19)
    real(fpsize), intent(in)  :: f_now(n_cells*Q19),omega,aomega
    real(fpsize), intent(out) :: f_nxt(n_cells*Q19)

    integer i_ct
    real(fpsize) :: f_tmp_NE,f_tmp_N,f_tmp_NW,f_tmp_W,                         &
                    f_tmp_SW,f_tmp_S,f_tmp_SE,f_tmp_E,                         &
                    f_tmp_T,f_tmp_TE,f_tmp_TN,f_tmp_TW,f_tmp_TS,               &
                    f_tmp_B,f_tmp_BE,f_tmp_BN,f_tmp_BW,f_tmp_BS,f_tmp_0
    real(fpsize) :: omega_h,asym_omega_h
    real(fpsize) :: sym,asym,feq_common
    real(fpsize) :: loc_dens,u_x,u_y,u_z,ui

    ! formula functions for index access
    integer POS_IDX,F_IDX,Fnode,Fdir
    POS_IDX(Fnode,Fdir) = (Fnode-1)*QN19 + Fdir
    ! RISC optimized
    F_IDX(Fnode,Fdir)   = (Fdir-1)*n_cells + Fnode

    omega_h = 0.5d0 * omega
    asym_omega_h = 0.5d0 * aomega

#if defined(SPEC_OMP) || defined(_OPENMP)
!$OMP PARALLEL DO DEFAULT(NONE) SCHEDULE(RUNTIME)                              &
!$OMP&SHARED(omega,omega_h,asym_omega_h,f_now,f_nxt,send,n_cells)              &
!$OMP&PRIVATE(f_tmp_NE,f_tmp_N,f_tmp_NW,f_tmp_W,f_tmp_0)                       &
!$OMP&PRIVATE(f_tmp_SW,f_tmp_S,f_tmp_SE,f_tmp_E)                               &
!$OMP&PRIVATE(f_tmp_T,f_tmp_TE,f_tmp_TN,f_tmp_TW,f_tmp_TS)                     &
!$OMP&PRIVATE(f_tmp_B,f_tmp_BE,f_tmp_BN,f_tmp_BW,f_tmp_BS)                     &
!$OMP&PRIVATE(loc_dens,ui,feq_common,u_x,u_y,u_z,sym,asym,i_ct)
#endif   /* _OPENMP */

#if !defined(SPEC)
#ifdef __SX__
!CDIR NODEP
#endif
#ifdef USE_VOVERTAKE
!CDIR VOVERTAKE(f_nxt)
#endif
#ifdef __INTEL_COMPILER
!DIR$ IVDEP
#endif
#endif

    do i_ct = 1, n_cells
       f_tmp_NE = f_now( F_IDX(i_ct,Q19_NE) )
       f_tmp_N  = f_now( F_IDX(i_ct,Q19_N ) )
       f_tmp_NW = f_now( F_IDX(i_ct,Q19_NW) )
       f_tmp_W  = f_now( F_IDX(i_ct,Q19_W ) )
       f_tmp_SW = f_now( F_IDX(i_ct,Q19_SW) )
       f_tmp_S  = f_now( F_IDX(i_ct,Q19_S ) )
       f_tmp_SE = f_now( F_IDX(i_ct,Q19_SE) )
       f_tmp_E  = f_now( F_IDX(i_ct,Q19_E ) )
       f_tmp_T  = f_now( F_IDX(i_ct,Q19_T ) )
       f_tmp_TE = f_now( F_IDX(i_ct,Q19_TE) )
       f_tmp_TN = f_now( F_IDX(i_ct,Q19_TN) )
       f_tmp_TW = f_now( F_IDX(i_ct,Q19_TW) )
       f_tmp_TS = f_now( F_IDX(i_ct,Q19_TS) )
       f_tmp_B  = f_now( F_IDX(i_ct,Q19_B ) )
       f_tmp_BE = f_now( F_IDX(i_ct,Q19_BE) )
       f_tmp_BN = f_now( F_IDX(i_ct,Q19_BN) )
       f_tmp_BW = f_now( F_IDX(i_ct,Q19_BW) )
       f_tmp_BS = f_now( F_IDX(i_ct,Q19_BS) )
       f_tmp_0  = f_now( F_IDX(i_ct,Q19_0 ) )

       loc_dens = f_tmp_0 &
                + f_tmp_NE + f_tmp_N + f_tmp_NW + f_tmp_W &
                + f_tmp_SW + f_tmp_S + f_tmp_SE + f_tmp_E &
                + f_tmp_T + f_tmp_TE + f_tmp_TN + f_tmp_TW &
                + f_tmp_TS + f_tmp_B + f_tmp_BE + f_tmp_BN &
                + f_tmp_BW + f_tmp_BS
       u_x = f_tmp_NE + f_tmp_SE + f_tmp_E + f_tmp_TE + f_tmp_BE &
           - f_tmp_NW - f_tmp_W - f_tmp_SW - f_tmp_TW - f_tmp_BW
       u_y = f_tmp_NE + f_tmp_N + f_tmp_NW + f_tmp_BN + f_tmp_TN &
           - f_tmp_SW - f_tmp_S - f_tmp_SE - f_tmp_TS - f_tmp_BS
       u_z = f_tmp_T + f_tmp_TE + f_tmp_TN + f_tmp_TW + f_tmp_TS &
           - f_tmp_B - f_tmp_BE - f_tmp_BN - f_tmp_BW - f_tmp_BS
       feq_common = loc_dens - three_half * (u_x*u_x + u_y*u_y + u_z*u_z)

       f_nxt( F_IDX(i_ct,Q19_0) ) = f_tmp_0*(one-omega) + omega*t0*feq_common

       ui = u_x + u_y
       sym = omega_h*(f_tmp_NE + f_tmp_SW - fac2*ui*ui - t2x2*feq_common)
       asym = asym_omega_h*( f_tmp_NE - f_tmp_SW - t2x2_3*ui )
       f_nxt(send(POS_IDX(i_ct,Q19_NE))) = f_tmp_NE - sym - asym
       f_nxt(send(POS_IDX(i_ct,Q19_SW))) = f_tmp_SW - sym + asym
       ui = u_x - u_y
       sym = omega_h*(f_tmp_SE + f_tmp_NW - fac2*ui*ui - t2x2*feq_common)
       asym = asym_omega_h*( f_tmp_SE - f_tmp_NW - t2x2_3*ui )
       f_nxt(send(POS_IDX(i_ct,Q19_SE))) = f_tmp_SE - sym - asym
       f_nxt(send(POS_IDX(i_ct,Q19_NW))) = f_tmp_NW - sym + asym
       ui = u_x + u_z
       sym = omega_h*(f_tmp_TE + f_tmp_BW - fac2*ui*ui - t2x2*feq_common)
       asym = asym_omega_h*( f_tmp_TE - f_tmp_BW - t2x2_3*ui )
       f_nxt(send(POS_IDX(i_ct,Q19_TE))) = f_tmp_TE - sym - asym
       f_nxt(send(POS_IDX(i_ct,Q19_BW))) = f_tmp_BW - sym + asym
       ui = u_x - u_z
       sym = omega_h*(f_tmp_BE + f_tmp_TW - fac2*ui*ui - t2x2*feq_common)
       asym = asym_omega_h*( f_tmp_BE - f_tmp_TW - t2x2_3*ui )
       f_nxt(send(POS_IDX(i_ct,Q19_BE))) = f_tmp_BE - sym - asym
       f_nxt(send(POS_IDX(i_ct,Q19_TW))) = f_tmp_TW - sym + asym
       ui = u_y + u_z
       sym = omega_h*(f_tmp_TN + f_tmp_BS - fac2*ui*ui - t2x2*feq_common)
       asym = asym_omega_h*( f_tmp_TN - f_tmp_BS - t2x2_3*ui )
       f_nxt(send(POS_IDX(i_ct,Q19_TN))) = f_tmp_TN - sym - asym
       f_nxt(send(POS_IDX(i_ct,Q19_BS))) = f_tmp_BS - sym + asym
       ui = u_y - u_z
       sym = omega_h*(f_tmp_BN + f_tmp_TS - fac2*ui*ui - t2x2*feq_common)
       asym = asym_omega_h*( f_tmp_BN - f_tmp_TS - t2x2_3*ui )
       f_nxt(send(POS_IDX(i_ct,Q19_BN))) = f_tmp_BN - sym - asym
       f_nxt(send(POS_IDX(i_ct,Q19_TS))) = f_tmp_TS - sym + asym

       ui = u_y
       sym = omega_h*(f_tmp_N + f_tmp_S - fac1*ui*ui - t1x2*feq_common)
       asym = asym_omega_h*( f_tmp_N - f_tmp_S - t1x2_3*ui )
       f_nxt(send(POS_IDX(i_ct,Q19_N))) = f_tmp_N - sym - asym
       f_nxt(send(POS_IDX(i_ct,Q19_S))) = f_tmp_S - sym + asym
       ui = u_x
       sym = omega_h*(f_tmp_E + f_tmp_W - fac1*ui*ui - t1x2*feq_common)
       asym = asym_omega_h*( f_tmp_E - f_tmp_W - t1x2_3*ui )
       f_nxt(send(POS_IDX(i_ct,Q19_E))) = f_tmp_E - sym - asym
       f_nxt(send(POS_IDX(i_ct,Q19_W))) = f_tmp_W - sym + asym
       ui = u_z
       sym = omega_h*(f_tmp_T + f_tmp_B - fac1*ui*ui - t1x2*feq_common)
       asym = asym_omega_h*( f_tmp_T - f_tmp_B - t1x2_3*ui )
       f_nxt(send(POS_IDX(i_ct,Q19_T))) = f_tmp_T - sym - asym
       f_nxt(send(POS_IDX(i_ct,Q19_B))) = f_tmp_B - sym + asym

    end do

  end subroutine relax_collstream

end module mod_relax
