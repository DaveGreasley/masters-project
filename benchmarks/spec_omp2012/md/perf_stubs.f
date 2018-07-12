!*******************************************************************************
!
!  This is a set of stub routines for the non-performance monitoring
!  version of the code.
!
!*******************************************************************************


!*******************************************************************************
!  Initialize performance monitor counters and timers.
!  (These will not be used in the non-performance monitoring version, but
!  we initialize them anyway.)

      subroutine perf_init
      implicit none
      include  'perf.h'

      double precision   t0

      call inittime()

      t_md       = 0.0;   ts_md       = 0.0
      t_newton   = 0.0;   ts_newton   = 0.0
      t_accel    = 0.0;   ts_accel    = 0.0
      t_calc_a   = 0.0;   ts_calc_a   = 0.0
      t_vtot     = 0.0;   ts_vtot     = 0.0
      t_calc_v   = 0.0;   ts_calc_v   = 0.0
      t_g        = 0.0;   ts_g        = 0.0
      t_pressure = 0.0;   ts_pressure = 0.0
      t_calc_vir = 0.0;   ts_calc_vir = 0.0

      n_md       = 0
      n_newton   = 0
      n_accel    = 0
      n_calc_a   = 0
      n_vtot     = 0
      n_calc_v   = 0
      n_g        = 0
      n_pressure = 0
      n_calc_vir = 0

      return
      end subroutine perf_init




!*******************************************************************************
!  Stub routine for performance report output.
!

      subroutine perf_report
      use  md_comm
      implicit none
      include  'perf.h'
      include  'mpif.h'
      return
      end subroutine perf_report
