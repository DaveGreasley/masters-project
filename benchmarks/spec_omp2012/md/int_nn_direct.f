!*******************************************************************************
!     MD 6.0.7
!  -----------------------------------------------------------------------------
!     Copyright 2009, The Trustees of Indiana University
!     Original author:   Charles J. Horowitz
!     Co-author:         Don Berry
!     Last modified by:  Don Berry, 28-Apr-2009
!  -----------------------------------------------------------------------------
!
!  This file contains subroutines for calculating potential energy, accelera-
!  tions and pressure of a classical N-body system of nucleons interacting via
!  a two-body central potential described in C.J.Horowitz, et al., Phys.Rev.C 69,
!  045804 (2004). The potential consists of an effective part modeling the strong
!  nuclear force, and a screened coulomb part.
!
!  The nuclear interaction is turned on by setting global character variable
!  nuclear='HPP' in module md_globals. Otherwise it is turned off.
!
!  The screened Coulomb interaction is turned on by setting global character
!  variable coulomb='screened-coulomb' in module md_globals. Otherwise it is
!  turned off.
!
!  All subroutines use the direct particle-particle method on a general purpose
!  computer, but can be compiled for serial, OpenMP, MPI, or MPI+OpenMP codes.
!  Serial and OpenMP variants use stub MPI routines in md_comm_ser.f, and defini-
!  tions of MPI constants in mpif_stubs.h.
!
!  -----------------------------------------------------------------------------
!
!


!*******************************************************************************
!  Calculate average potential energy per nucleon for a system of nucleons.
!  The result is returned in eva.
!
      subroutine vtot_nn(eva)
      use  md_globals
      use  md_comm
      implicit real(dble) (a-h,o-z)
      include 'perf.h'
      include 'mpif.h'

      logical      coulomb_on   !turn coulomb interaction on/off
      logical      nuclear_on   !turn nuclear interaction on/off

      call starttimer()   !DKB-perf (vtot)
      call starttimer()   !DKB-perf (calc_v)

      coulomb_on = coulomb.eq.'screened-coulomb'
      nuclear_on = nuclear.eq.'HPP'

      eva=0.
      !$omp parallel do private(i,j,k,xx,r2,r,expfac,evx,vcoul), reduction(+:eva), &
      !$omp schedule(runtime)
      do 100 i=myrank,n-2,nprocs
        do 90 j=i+1,n-1
          evx=0.
          r2=0.
          do k=1,3
            xx=abs(x(k,i)-x(k,j))
            xx=min(xx,xl-xx)
            r2=r2+xx*xx
          enddo
          if(nuclear_on) then
            expfac=exp(-r2/xl2)
            if(type(i).eq.type(j)) then
              evx=(alpha*expfac+(beta+c))*expfac   !n-n or p-p
            else
              evx=(alpha*expfac+(beta-c))*expfac   !n-p
            endif
          endif
          if(coulomb_on) then
            if((type(i).eq.1).and.(type(j).eq.1)) then   !p-p
              r=sqrt(r2)
              evx = evx + vc*exp(-xmuc*r)/r
            endif
          endif
          eva=eva+evx   
   90   continue
  100 continue
      !$omp end parallel do
      call MPI_allreduce(eva,evx,1,MPI_DOUBLE_PRECISION,MPI_SUM,MPI_COMM_WORLD,ierror)
      eva=evx/float(n)	 

      call stoptimer(1,t_calc_v,ts_calc_v,n_calc_v)  !DKB-perf (calc_v)
      call stoptimer(1,t_vtot,ts_vtot,n_vtot)        !DKB-perf (vtot)
      return
      end subroutine vtot_nn



!*******************************************************************************
!  Calculate acceleration of each nucleon due to forces from all others.
!
      subroutine accel_nn
      use  md_globals
      implicit real(dble) (a-h,o-z)
      include 'perf.h'

      real(dble)   fn         !total nuclear force on a nucleon
      real(dble)   fc         !total screened Coulomb force on a proton
      real(dble)   xx(3)      !position vector from i-th to j-th particles
      real(dble)   r2,r       !distance squared and distance between two particles
      real(dble)   expfac     !exponential factor
      logical      coulomb_on !turns on/off coulomb interaction
      logical      nuclear_on !turns on/off nuclear interaction

      call starttimer()   !DKB-perf (accel)
      call starttimer()   !DKB-perf (calc_a)

      coulomb_on = coulomb.eq.'screened-coulomb'
      nuclear_on = nuclear.eq.'HPP'

      halfl=0.5*xl
      xlargel=0.5*xl2   
      !$omp parallel do private(i,j,k,xx,r2,r,expfac,fn,fc), schedule(runtime)
      do 100 i=myrank,n-1,nprocs
         a(:,i)=0.
         do 90 j=0,n-1
         if(i.ne.j) then
            fn=0.
            fc=0.
            r2=0.
            do k=1,3
               xx(k)=x(k,i)-x(k,j)
               if(xx(k).gt.+halfl) xx(k)=xx(k)-xl
               if(xx(k).lt.-halfl) xx(k)=xx(k)+xl
               r2=r2+xx(k)*xx(k)
            enddo
            if(nuclear_on) then
               expfac=exp(-r2/xl2)
               if( type(i).eq.type(j) ) then
                  fn = (2.*alpha*expfac+(beta+c))*expfac/xlargel      !n-n, p-p
               else
                  fn = (2.*alpha*expfac+(beta-c))*expfac/xlargel      !n-p
               endif
            endif
            if(coulomb_on) then
               if((type(i).eq.1).and.(type(j).eq.1)) then   !p-p
                 r=sqrt(r2)
                 fc = vc*exp(-xmuc*r)*(1./r+xmuc)/r2
               endif
            endif
            a(:,i) = a(:,i) + (fn+fc)*xx(:)
         endif
   90    continue
         a(:,i) = a(:,i)/xmass
  100 continue
      !$omp end parallel do

      call stoptimer(1,t_calc_a,ts_calc_a,n_calc_a)  !DKB-perf (calc_a)
      call stoptimer(1,t_accel,ts_accel,n_accel)     !DKB-perf (accel)
      return
      end subroutine accel_nn



!*******************************************************************************
!  Calculate pressure.
!
      subroutine pressure_nn(press)
      use  md_globals
      use  md_comm
      implicit real(dble) (a-h,o-z)
      include 'perf.h'
      include 'mpif.h'

      real(dble)   press        !pressure
      real(dble)   virx         !intermediate calculation of virial
      real(dble)   vir          !final value of virial
      real(dble)   xlargel      !Lambda
      real(dble)   r2,r         !distance squared and distance between two nucleons
      logical      coulomb_on   !turn on/off coulomb interaction
      logical      nuclear_on   !turn on/off nuclear interaction

      call starttimer()   !DKB-perf (pressure)
      call starttimer()   !DKB-perf (calc_vir)

      coulomb_on = coulomb.eq.'screened-coulomb'
      nuclear_on = nuclear.eq.'HPP'

      xlargel=0.5*xl2
      vir=0.
      !$omp parallel do private(i,j,k,xx,r2,r,expfac,virx), reduction(+:vir),   &
      !$omp schedule(runtime)
      do 100 i=myrank,n-2,nprocs
        do 90 j=i+1,n-1
          virx = 0.0
          r2=0.0
      	  do k=1,3
      	    xx=abs(x(k,i)-x(k,j))
            xx=min(xx,xl-xx)
            r2=r2+xx*xx
          enddo
          if(nuclear_on) then
            expfac=exp(-r2/xl2)
            if(type(i).eq.type(j)) then
              virx = (r2/xlargel)*(2.*alpha*expfac+(beta+c))*expfac   ! n-n or p-p 
            else
              virx = (r2/xlargel)*(2.*alpha*expfac+(beta-c))*expfac   ! n-p
            endif
          endif
          if(coulomb_on) then
            if((type(i).eq.1).and.(type(j).eq.1)) then   !p-p
              r = sqrt(r2)
              virx = virx + vc*(1./r+xmuc)*exp(-xmuc*r)
            endif
          endif
          vir=vir+virx
 90     continue
100   continue
      !$omp end parallel do
      call MPI_allreduce(vir,virx,1,MPI_DOUBLE_PRECISION,MPI_SUM,MPI_COMM_WORLD,ierror)
      vir=virx
      press = rho*(t+vir/(3.0*n))

      call stoptimer(1,t_calc_vir,ts_calc_vir,n_calc_vir)  !DKB-perf (calc_vir)
      call stoptimer(1,t_pressure,ts_pressure,n_pressure)  !DKB-perf (pressure)
      return
      end subroutine pressure_nn
