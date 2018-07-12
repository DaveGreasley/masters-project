!*******************************************************************************
!     MD 6.0.7
!  ---------------------------------------------------------------------
!     Copyright 2009, The Trustees of Indiana University
!     Authors:           Charles J. Horowitz,   Don Berry
!     Last modified by:  Don Berry, 14-Mar-2007
!  ---------------------------------------------------------------------
!
!  Construct initial configuration as specified by value of istart in the run
!  parameter file:
!     1 =  initalize particles coordinates for random start
!     2 =  initialize particles coordinates in small spherical volume
!     3 =  read particle coordinates from file 'pasta.in'
!     4 =  read both coordinates and velocities from mdin
!  If istart=1,2,3, then initalize velocities from boltzmann distribution at
!  temp t.
!
!*******************************************************************************


      subroutine inital
      use  md_types
      use  md_globals
      use  md_comm
      implicit real(dble) (a-h,o-z)
      include 'mpif.h'


!  Allocate arrays for n particles.
      allocate(x(3,0:n-1))        ! positions
      allocate(v(3,0:n-1))        ! velocities
      allocate(vold(3,0:n-1))     ! old velocities
      allocate(a(3,0:n-1))        ! accelerations


!===============================================================================
!  If this is a parallel MPI program, then process 0 sets up the initial config-
!  uration (positions and velocities), and broadcasts it to the other MPI pro-
!  cesses. For the serial program, myrank=0.

      if(myrank.eq.0) then

!  istart=1:  Distribute particles randomly in a cube of edge length xl.
!  ---------
      if(istart.eq.1) then
         write(6,100)
         write(8,100)
  100    format(' Random Start') 
         do i=0,n-1
            x(1,i)=xl*ran1(iseed)
            x(2,i)=xl*ran1(iseed)
            x(3,i)=xl*ran1(iseed)
         enddo
      endif

!  istart=2:  Initialize particle coordinates in spherical volume of radius rmax
!     centered in a cube of edge length xl. Limit rmax to xl/2.
!  ---------
      if(istart.eq.2) then
         rmax=min( rmax, xl*0.5 )
         write(6,200) rmax
         write(8,200) rmax
  200    format(1x,' Initializing system inside a sphere of radius ',f8.4,' fm')
         do i=0,n-1
            xrr=ran1(iseed)**.3333333*rmax
            costheta = 2.*ran1(iseed)-1.
            sintheta = sqrt(1.d0-costheta*costheta)
            xphi = 2.d0*3.1415926d0*ran1(iseed)
            x(1,i) = xrr*sintheta*cos(xphi)+0.5*xl
            x(2,i) = xrr*sintheta*sin(xphi)+0.5*xl
            x(3,i) = xrr*costheta+0.5*xl
         enddo
      endif

!  istart=3:  Read particle coordinates from file 'pasta.in'
!  ---------
      if(istart.eq.3) then
        write(6,300)
        write(8,300) 
  300   format(1x,'  Reading coordinates from file pasta.in')
        open (UNIT=13,FILE='pasta.in', STATUS='OLD')
        do i=0,n-1
           read(13,*) x(1,i),x(2,i),x(3,i),dummy
        enddo
        close(13)
      endif

!  istart=4:  Read both coordinates and velocities from mdin.
!  ---------
      if(istart.eq.4) then
         write(6,400) trim(mdin)
         write(8,400) trim(mdin)
  400    format('  Reading coordinates and velocities from ',a)
          !If mdin is formatted, do this:
        !open(UNIT=13, FILE=mdin, STATUS='OLD')
        !do i=0,n-1
        !   read(13,*) xspec(i),x(1,i),x(2,i),x(3,i),v(1,i),v(2,i),v(3,i)
        !enddo
        !close(13)
          !If mdin is unformatted, do this:
         open(UNIT=13, FILE=mdin, STATUS='OLD', FORM='UNFORMATTED')
         read(13) xtime  !DKB-note: old-format md.in files have no time-stamp
         read(13) (x(1,i),x(2,i),x(3,i),v(1,i),v(2,i),v(3,i), i=0,n-1)
         close(13)

!  istart=1,2,3:  Initalize velocities from boltzmann distribution at temp t.
!  -------------
      else
         do i=0,n-1
            velfac=sqrt(t/(aii(i)*xmass))
            v(1,i)=velfac*gasdev(iseed)
            v(2,i)=velfac*gasdev(iseed)
            v(3,i)=velfac*gasdev(iseed)
         enddo

        ! Calculate average kinetic energy per particle:
         eka=0.
         do i=0,n-1
            eka = eka + 0.5*(aii(i)*xmass)*(v(1,i)**2+v(2,i)**2+v(3,i)**2)
         enddo
         eka=eka/float(n)

         ! Then use eka to normalize velocities to match selected temperature:
         fac=sqrt(eka/(1.5*t))
         do i=0,n-1
            v(:,i)=v(:,i)/fac
         enddo
      endif

      endif
!===============================================================================



!  MPI process 0 now broadcasts the position and velocity arrays to all other
!  processes.
      call MPI_bcast(x, 3*n, MPI_DOUBLE_PRECISION, 0, MPI_COMM_WORLD, ierror)
      call MPI_bcast(v, 3*n, MPI_DOUBLE_PRECISION, 0, MPI_COMM_WORLD, ierror)
      call MPI_barrier(MPI_COMM_WORLD,ierror)


      return
      end subroutine inital
