!*******************************************************************************
!     MD 6.0.7
!  ---------------------------------------------------------------------
!     Copyright 2009, The Trustees of Indiana University
!     Author:            Don Berry
!     Last modified by:  Don Berry, 28-Apr-2009
!  ---------------------------------------------------------------------
!
!  This file contains subroutines for calculating potential energy, accelera-
!  tions, and the pressure for a system consisting of a mixture of ion species
!  interacting via a screened coulomb potential. The total number of ions in 
!  the system is n, the charge number Z of the i-th ion (i=0,...,n-1) is zii(i),
!  and the mass number is aii(i). The screening length is 1/xmuc. All the sub-
!  routines use the direct particle-particle method on a general purpose computer.
!
!  This file can be compiled as a serial, OpenMP, MPI, or MPI+OpenMP code. Serial
!  and OpenMP variants use stub MPI routines in md_comm_ser.f, and definitions
!  of MPI constants in mpif_stubs.h.
!

!*******************************************************************************
!  Calculate average potential energy per ion. Return result in eva.
!
      subroutine vtot_ion_mix(eva)
      use  md_types
      use  md_globals
      use  md_comm
      implicit real(dble) (a-h,o-z)
      include 'perf.h'
      include 'mpif.h'

      real(dble)   eva   !avg potential energy per ion
      real(dble)   evx   !intermediate calcluation of eva
      real(dble)   xx    !
      real(dble)   r2,r  !distance squared and distance between two ions

      call starttimer()   !DKB-perf (vtot)
      call starttimer()   !DKB-perf (calc_v)

      eva=0.0d0
      !$omp parallel do private(i,j,k,xx,r2,r,evx), reduction(+:eva), schedule(runtime)
      do 100 i=myrank,n-2,nprocs
         evx=0.0d0
         do 90 j=i+1,n-1
            r2=0.
            do k=1,3
               xx=abs(x(k,i)-x(k,j))
               xx=min(xx,xl-xx)
               r2=r2+xx*xx
            enddo
            r=sqrt(r2)
            evx = evx + zii(j)*exp(-xmuc*r)/r
   90    continue
         eva = eva + frp*zii(i)*vc*evx
  100 continue
      !$omp end parallel do
      call MPI_allreduce(eva,evx,1,MPI_DOUBLE_PRECISION,MPI_SUM,MPI_COMM_WORLD,ierror)
      eva=evx/float(n)	 

      call stoptimer(1,t_calc_v,ts_calc_v,n_calc_v)  !DKB-perf (calc_v)
      call stoptimer(1,t_vtot,ts_vtot,n_vtot)        !DKB-perf (vtot)
      return
      end subroutine vtot_ion_mix



!*******************************************************************************
!  Calculate acceleration of each ion due to total force from all others.
!
      subroutine accel_ion_mix
      use  md_types
      use  md_globals
      implicit real(dble) (a-h,o-z)
      include 'perf.h'

      real(dble)   fc       !total screened Coulomb force on an ion
      real(dble)   xx(3)    !relative position vector from i-th to j-th ions
      real(dble)   r2,r     !distance-squared and distance between two ions

      call starttimer()   !DKB-perf (accel)
      call starttimer()   !DKB-perf (calc_a)

      halfl=0.5*xl
      !$omp parallel do private(i,j,k,xx,r2,r,fc), schedule(runtime)
      do 100 i=myrank,n-1,nprocs
         a(:,i)=0.0d0
         do 90 j=0,n-1
            if(i.ne.j) then
               r2=0.0d0
               do k=1,3
                  xx(k)=x(k,i)-x(k,j)
                  if(xx(k).gt.+halfl) xx(k)=xx(k)-xl
                  if(xx(k).lt.-halfl) xx(k)=xx(k)+xl
                  r2=r2+xx(k)*xx(k)
               enddo
               r=sqrt(r2)
               fc = zii(j)*exp(-xmuc*r)*(1./r+xmuc)/r2
               a(:,i) = a(:,i)+fc*xx(:)
            endif
   90    continue
         a(:,i) = (frp*zii(i)*vc*a(:,i))/(aii(i)*xmass)
  100 continue
      !$omp end parallel do

      call stoptimer(1,t_calc_a,ts_calc_a,n_calc_a)  !DKB-perf (calc_a)
      call stoptimer(1,t_accel,ts_accel,n_accel)     !DKB-perf (accel)
      return
      end subroutine accel_ion_mix



!*******************************************************************************
!  Calculate pressure.
!
      subroutine pressure_ion_mix(p)
      use  md_types
      use  md_globals
      use  md_comm
      implicit real(dble) (a-h,o-z)
      include 'perf.h'
      include 'mpif.h'

      real(dble)  p       !pressure
      real(dble)  virx    !intermediate value of virial
      real(dble)  vir     !final value of virial
      real(dble)  r,r2    !distance squared and distance between two ions

      call starttimer()   !DKB-perf (pressure)
      call starttimer()   !DKB-perf (calc_vir)

      virx=0.
      !$omp parallel do private(i,j,k,xx,r2,r,vir), reduction(+:virx), schedule(runtime)
      do 100 i=myrank,n-2,nprocs
         vir=0.0d0
         do 90 j=i+1,n-1
            r2=0.0
      	    do k=1,3
      	       xx=abs(x(k,i)-x(k,j))
               xx=min(xx,xl-xx)
               r2=r2+xx*xx
            enddo
            r = sqrt(r2)
            vir = vir + zii(j)*(1./r+xmuc)*exp(-xmuc*r)
 90      continue
         virx = virx + frp*zii(i)*vc*vir
100   continue
      !$omp end parallel do
      call MPI_allreduce(virx,vir,1,MPI_DOUBLE_PRECISION,MPI_SUM,MPI_COMM_WORLD,ierror)

      p = rho*(t+vir/(3.0*n))

      call stoptimer(1,t_calc_vir,ts_calc_vir,n_calc_vir)  !DKB-perf (calc_vir)
      call stoptimer(1,t_pressure,ts_pressure,n_pressure)  !DKB-perf (pressure)
      return
      end subroutine pressure_ion_mix
