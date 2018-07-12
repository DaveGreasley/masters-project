module mod_constants

  !=======================================================================
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

  ! floating point type (single/double precision)
#ifdef SINGLE
  integer, parameter :: fpsize = 4
#else
  integer, parameter :: fpsize = 8
#endif

  ! number of neighbouring directions
  integer, parameter :: QN19 = 18

  ! number of directions (= slots in distribution array including padding)
  integer, parameter :: Q19 = 19

  ! LB-DC default numbering
  integer, parameter :: Q19_NE = 1
  integer, parameter :: Q19_N  = 2
  integer, parameter :: Q19_NW = 3
  integer, parameter :: Q19_W  = 4
  integer, parameter :: Q19_SW = 5
  integer, parameter :: Q19_S  = 6
  integer, parameter :: Q19_SE = 7
  integer, parameter :: Q19_E  = 8
  integer, parameter :: Q19_T  = 9
  integer, parameter :: Q19_TE = 10
  integer, parameter :: Q19_TN = 11
  integer, parameter :: Q19_TW = 12
  integer, parameter :: Q19_TS = 13
  integer, parameter :: Q19_B  = 14
  integer, parameter :: Q19_BE = 15
  integer, parameter :: Q19_BN = 16
  integer, parameter :: Q19_BW = 17
  integer, parameter :: Q19_BS = 18
  integer, parameter :: Q19_0  = 19 ! zero velocity must be last!

  ! unit vectors and inverse directions
  !                                    NE, N,NW, W,SW, S,SE, E,
  !                                    T,TE,TN,TW,TS, B,BE,BN,BW,BS
  integer, parameter :: Q19_ex(18) = (/ 1, 0,-1,-1,-1, 0, 1, 1,                &
                                        0, 1, 0,-1, 0, 0, 1, 0,-1, 0/)
  integer, parameter :: Q19_ey(18) = (/ 1, 1, 1, 0,-1,-1,-1, 0,                &
                                        0, 0, 1, 0,-1, 0, 0, 1, 0,-1/)
  integer, parameter :: Q19_ez(18) = (/ 0, 0, 0, 0, 0, 0, 0, 0,                &
                                        1, 1, 1, 1, 1,-1,-1,-1,-1,-1/)

  integer, parameter :: Q19_inv(18)= (/Q19_SW,Q19_S,Q19_SE,Q19_E,              &
                                       Q19_NE,Q19_N,Q19_NW,Q19_W,              &
                                       Q19_B,Q19_BW,Q19_BS,Q19_BE,Q19_BN,      &
                                       Q19_T,Q19_TW,Q19_TS,Q19_TE,Q19_TN/)


  real(fpsize), parameter :: c_squ = 1.d0 / 3.d0
  real(fpsize), parameter :: inv2csq2 = 1.d0 / (2.d0 * c_squ*c_squ)
  real(fpsize), parameter :: t0 = 1.d0/3.d0
  real(fpsize), parameter :: t1x2 = 1.d0/18.d0 * 2.d0 ! yes, 2x!
  real(fpsize), parameter :: t2x2 = 1.d0/36.d0 * 2.d0 ! yes, 2x!
  real(fpsize), parameter :: t1x2_3 = 3.d0 * t1x2
  real(fpsize), parameter :: t2x2_3 = 3.d0 * t2x2
  real(fpsize), parameter :: fac1 = t1x2*inv2csq2
  real(fpsize), parameter :: fac2 = t2x2*inv2csq2

  real(fpsize), parameter :: one = 1.0d0
  real(fpsize), parameter :: three_half = 1.5d0

end module mod_constants
