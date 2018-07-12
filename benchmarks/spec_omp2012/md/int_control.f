!*******************************************************************************
!     MD 6.0.5
!  -----------------------------------------------------------------------------
!     Copyright 2007, The Trustees of Indiana University
!     Original author:   Don Berry
!     Last modified by:  Don Berry, 09-Mar-2007
!  -----------------------------------------------------------------------------
!
!  Subroutines in this file control which potential energy, force, and virial
!  subroutines to call. The choice is made by global variable sim_type, which
!  defines the type of simulation being run. For example, in previous versions
!  of MD, one called subroutine vtot to compute the average potential energy. In
!  this version, one still calls vtot, but it is now a wrapper which calls the
!  real potential energy subroutine. The user defines sim_type in the runmd.in
!  file.
!
!  MD_6.0.5
!  ----------
!  2007-Mar-09 (Don Berry) -- Changed "single-ion" simulation type to "pure-ion"
!    and "multi-ion" to "ion-mixture", to match conventional terminology. Also
!    changed the names of the corresponding subroutines to better match these
!    names.
!
!*******************************************************************************


      subroutine vtot(eva)
      use  md_types
      use  md_globals
      use  md_comm
      implicit real(dble) (a-h,o-z)

      real(dble)   eva

      select case(sim_type)

      case('nucleon')
         call vtot_nn(eva)

      case('pure-ion')
         call vtot_ion_pure(eva)

      case('ion-mixture')
         call vtot_ion_mix(eva)

      case default
         write(6,900)
         write(8,900)
  900    format('*** Program not compiled to do this simulation type ***')
         stop  !DKB-note: need to de-allocate arrays and shut down MPI

      end select

      end subroutine vtot



!*******************************************************************************
      subroutine accel
      use  md_types
      use  md_globals
      use  md_comm
      implicit real(dble) (a-h,o-z)

      select case(sim_type)

      case('nucleon')
         call accel_nn

      case('pure-ion')
         call accel_ion_pure

      case('ion-mixture')
         call accel_ion_mix

      case default
         write(6,900)
         write(8,900)
  900    format('*** Program not compiled to do this simulation type ***')
         stop  !DKB-note: need to de-allocate arrays and shut down MPI

      end select

      end subroutine accel



!*******************************************************************************
      subroutine pressure(press)
      use  md_types
      use  md_globals
      use  md_comm
      implicit real(dble) (a-h,o-z)

      real(dble)   press

      select case(sim_type)

      case('nucleon')
         call pressure_nn(press)

      case('pure-ion')
         call pressure_ion_pure(press)

      case('ion-mixture')
         call pressure_ion_mix(press)

      case default
         write(6,900)
         write(8,900)
  900    format('*** Program not compiled to do this simulation type ***')
         stop  !DKB-note: need to de-allocate arrays and shut down MPI

      end select

      end subroutine pressure
