!*******************************************************************************
!     MD 6.0.7
!  ---------------------------------------------------------------------
!     Copyright 2008, The Trustees of Indiana University
!     Author:            Don Berry
!     Last modified by:  Don Berry, 2009-Jun-09
!  ---------------------------------------------------------------------
!
!  MD 6.0.5
!  ----------
!  2007-Mar-09 (Don Berry) -- Changed zi and ai from integer to real, and fixed
!    the MPI messages subroutine bcast accordingly.
!
!  MD 6.0.6
!  ----------
!  2008-Jul-01 (Don Berry) -- Added ncom to iparm list in subroutine bcast_parms.
!    This is the number of steps between subtraction of center-of-mass velocity,
!    which keeps COM velocity from accumulating.
!
!*******************************************************************************


      module  md_comm
      use md_globals

      character*7   ::  mp_type = 'F90+MPI'
      double precision, allocatable, target  ::  yyy(:,:)
      double precision, allocatable, target  ::  xxx(:,:)
      integer, allocatable, target           ::  typexx(:)
      integer, allocatable  ::  nxv(:)
      integer, allocatable  ::  nnxv(:)
      integer, allocatable  ::  nixv(:)
      integer, allocatable  ::  disp(:)

      integer      nx    ! number of particles in my process
      integer      nnx   ! number of free neutrons in my process
      integer      nix   ! number of ions in my process

      integer, private      ::  ierr

      contains


!*******************************************************************************
!  This subroutine sets up arrays for doing gathers of particle data. It first
!  figures out the number of free neutrons, the number of ions, and total par-
!  ticles in each process. Then it allocates an array for gathering coordinates
!  and velocities, and an integer array for gathering particle types. These arrays
!  can be used for other purposes besides gathers. The main use is in mdgrape_funcs.f
!  where distributed coordinates need to be packed into a contiguous array, and
!  likewise for distributed types.

      subroutine setup_gather
      implicit none
      include 'mpif.h'

      integer    m

      call MPI_comm_size(MPI_COMM_WORLD,nprocs,ierr)
      call MPI_comm_rank(MPI_COMM_WORLD,myrank,ierr)
      allocate(nxv(0:nprocs-1))
      allocate(nnxv(0:nprocs-1))
      allocate(nixv(0:nprocs-1))
      allocate(disp(0:nprocs-1))
      disp(0)=0
      do m=0,nprocs-1
         nxv(m) = n/nprocs                        !number of particles in process m
         if(m.lt.mod(n,nprocs)) nxv(m)=nxv(m)+1
         nnxv(m) = nn/nprocs                      !number of free neutrons in process m
         if(m.lt.mod(nn,nprocs)) nnxv(m) = nnxv(m)+1
         nixv(m) = nxv(m)-nnxv(m)                 !number of ions in process m
         if(m.lt.nprocs-1) disp(m+1)=disp(m)+nxv(m)
      enddo
      nx = nxv(myrank)       ! number of particles handled by this process
      nnx = nnxv(myrank)     ! number of free neutrons handled by this process
      nix = nixv(myrank)     ! number of ions handled by this process
      allocate(yyy(3,0:nx-1))
      allocate(xxx(3,0:n-1))
      allocate(typexx(0:nx-1))
      return
      end subroutine setup_gather


!*******************************************************************************
      subroutine destroy_gather
      implicit none
      deallocate(xxx)
      deallocate(yyy)
      deallocate(typexx)
      deallocate(nxv)
      deallocate(nnxv)
      deallocate(nixv)
      deallocate(disp)
      return
      end subroutine destroy_gather
      

!*******************************************************************************
!  Gather identically sized arrays of coordinates or velocities from all
!  processes into a single array on a given process. Each array must be of the
!  same shape, namely (3,n/nprocs). This will work only if n is divisible by
!  nprocs. To gather different sized arrays from each process, use subroutine
!  gatherv.

      subroutine gather(dbuf,root)
      implicit none
      include 'mpif.h'

      double precision  dbuf(3,0:*) ! array to be gathered
      integer           root       ! process to which gather is done

      integer   i,j,m

!  It is assumed that dbuf is cyclically distributed in its second index.
!  Gather these elements into a contiguous array, yyy.
      i=0
      do j=myrank,n-1,nprocs
        yyy(:,i) = dbuf(:,j)
        i=i+1
      enddo

      call MPI_gather(yyy,3*nx,MPI_DOUBLE_PRECISION,xxx,3*nx,   &
                MPI_DOUBLE_PRECISION,root,MPI_COMM_WORLD,ierr)

      if(myrank.eq.root) then
         do m=0,nprocs-1
           i=0
           do j=m,n-1,nprocs
             dbuf(:,j) = xxx(:,m*nx+i)
             i=i+1
           enddo
         enddo
      endif
      call MPI_barrier(MPI_COMM_WORLD,ierr)
 
      return
      end subroutine gather


!*******************************************************************************
!  Gather variably sized arrays of coordinates or velocities from all
!  processes into a single array on a given process.

      subroutine gatherv(x,root)
      implicit none
      include 'mpif.h'

      double precision  x(3,0:n-1) ! array to be gathered
      integer           root       ! process to which gather is done

      integer   nx
      integer   i,j,m

!  There are two ways of packing x into yyy:
!  Method 1:
     !do i=0,nx-1
     !  j=myrank+i*nprocs
     !  yyy(:,i) = x(:,j)
     !enddo
!  Method 2:
      i=0
      do j=myrank,n-1,nprocs
        yyy(:,i) = x(:,j)
        i=i+1
      enddo

      call MPI_gatherv(yyy,3*nx,MPI_DOUBLE_PRECISION,          &
                       xxx,3*nxv,3*disp,MPI_DOUBLE_PRECISION,  &
                       root,MPI_COMM_WORLD,ierr)

      if(myrank.eq.root) then
        !There are two ways of unpacking xxx into x:
        !Method 1:
        !do m=0,nprocs-1
        !  do i=0,nxv(m)-1
        !    x(:,m+i*nprocs) = xxx(:,disp(m)+i)
        !  enddo
        !enddo
        !Method 2:
         do m=0,nprocs-1
           i=0
           do j=m,n-1,nprocs
             x(:,j) = xxx(:,disp(m)+i)
             i=i+1
           enddo
         enddo
      endif
      call MPI_barrier(MPI_COMM_WORLD,ierr)
 
      return
      end subroutine gatherv


!*******************************************************************************
!  Gather identically sized arrays of coordinates or velocities from all
!  processes into single large array on each process. Each gathered array must
!  be the same shape, namely (3,n/nprocs). This will work only if n is divisible
!  by nprocs. To gather different sized arrays, use subroutine allgatherv.

      subroutine allgather(dbuf)
      implicit none
      include 'mpif.h'

      double precision  dbuf(3,0:n-1)

      integer   i,j,m

!  It is assumed that dbuf is cyclically distributed in its second index.
!  Gather these elements into a contiguous array, yyy.
      i=0
      do j=myrank,n-1,nprocs
        yyy(:,i) = dbuf(:,j)
        i=i+1
      enddo

      call MPI_allgather(yyy,3*nx,MPI_DOUBLE_PRECISION,xxx,3*nx,   &
                MPI_DOUBLE_PRECISION,MPI_COMM_WORLD,ierr)

      do m=0,nprocs-1
        i=0
        do j=m,n-1,nprocs
          dbuf(:,j) = xxx(:,m*nx+i)
          i=i+1
        enddo
      enddo
 
 
      return
      end subroutine allgather


!*******************************************************************************
!  Gather variably sized arrays of coordinates or velocities from all
!  processes into a single large array on each process.

      subroutine allgatherv(dbuf)
      implicit none
      include 'mpif.h'

      double precision  dbuf(3,0:n-1) ! array to be gathered
      integer           root       ! process to which gather is done

      integer   nx
      integer   i,j,m

!  There are two ways of packing dbuf into yyy:
!  Method 1:
     !do i=0,nx-1
     !  j=myrank+i*nprocs
     !  yyy(:,i) = dbuf(:,j)
     !enddo
!  Method 2:
      i=0
      do j=myrank,n-1,nprocs
        yyy(:,i) = dbuf(:,j)
        i=i+1
      enddo

      call MPI_allgatherv(yyy,3*nx,MPI_DOUBLE_PRECISION,          &
                       xxx,3*nxv,3*disp,MPI_DOUBLE_PRECISION,     &
                       MPI_COMM_WORLD,ierr)

!  There are two ways of unpacking xxx into dbuf:
!  Method 1:
     !do m=0,nprocs-1
     !  do i=0,nxv(m)-1
     !    dbuf(:,m+i*nprocs) = xxx(:,disp(m)+i)
     !  enddo
     !enddo
!  Method 2:
      do m=0,nprocs-1
        i=0
        do j=m,n-1,nprocs
          dbuf(:,j) = xxx(:,disp(m)+i)
          i=i+1
        enddo
      enddo
 
      return
      end subroutine allgatherv


!*******************************************************************************
!  This subroutine broadcasts all the scalar run parameters from process 0 to
!  the other processes.

      subroutine bcast_parms
      use  md_types
      use  md_globals
      implicit none
      include  'mpif.h'

! Arrays for broadcasting parameters to all MPI procs.
      real(dble)  xparm(80)
      integer     iparm(80)
      logical     lparm(40)

   10 if(myrank.eq.0) then
         xparm(1)   = tstart
         xparm(2)   = dt
         xparm(3)   = rho
         xparm(4)   = xl
         xparm(5)   = t
         xparm(6)   = xmass
         xparm(7)   = tend
         xparm(8)   = alpha
         xparm(9)   = beta
         xparm(10)  = c
         xparm(11)  = qmin
         xparm(12)  = dq
         xparm(13)  = zi
         xparm(14)  = ai
         xparm(15)  = xmuc
         xparm(16)  = vc
         xparm(17)  = xl2
         xparm(18)  = frp
         xparm(19)  = bfield
         xparm(20)  = efield
         xparm(21)  = q0
         xparm(22)  = w0
         xparm(23)  = tref
         xparm(24)  = rmax
         call MPI_Bcast(xparm, 24, MPI_DOUBLE_PRECISION, 0, MPI_COMM_WORLD, ierr)
      else
         call MPI_Bcast(xparm, 24, MPI_DOUBLE_PRECISION, 0, MPI_COMM_WORLD, ierr)
         tstart   = xparm(1)
         dt       = xparm(2)
         rho      = xparm(3)
         xl       = xparm(4)
         t        = xparm(5)
         xmass    = xparm(6)
         tend     = xparm(7)
         alpha    = xparm(8)
         beta     = xparm(9)
         c        = xparm(10)
         qmin     = xparm(11)
         dq       = xparm(12)
         zi       = xparm(13)
         ai       = xparm(14)
         xmuc     = xparm(15)
         vc       = xparm(16)
         xl2      = xparm(17)
         frp      = xparm(18)
         bfield   = xparm(19)
         efield   = xparm(20)
         q0       = xparm(21)
         w0       = xparm(22)
         tref     = xparm(23)
         rmax     = xparm(24)
      endif
      call MPI_barrier(MPI_COMM_WORLD,ierr)

   20  if(myrank.eq.0) then
         iparm(1)   = nwgroup
         iparm(2)   = nwsteps
         iparm(3)   = ngroup
         iparm(4)   = ntot
         iparm(5)   = nind
         iparm(6)   = tnormalize
         iparm(7)   = nn
         iparm(8)   = np
         iparm(9)   = ni
         iparm(10)  = nspecies
         iparm(11)  = n
         iparm(12)  = iaccep
         iparm(13)  = irejec
         iparm(14)  = nbin
         iparm(15)  = nsbin
         iparm(16)  = iseed
         iparm(17)  = irnd
         iparm(18)  = istart
        !iparm(19)  = gtype
        !iparm(20)  = gspec
         iparm(21)  = nckpt
         iparm(22)  = nout
         iparm(23)  = ncom
         call MPI_Bcast(iparm, 23, MPI_INTEGER, 0, MPI_COMM_WORLD, ierr)
       else
         call MPI_Bcast(iparm, 23, MPI_INTEGER, 0, MPI_COMM_WORLD, ierr)
         nwgroup    = iparm(1)
         nwsteps    = iparm(2)
         ngroup     = iparm(3)
         ntot       = iparm(4)
         nind       = iparm(5)
         tnormalize = iparm(6) 
         nn         = iparm(7)
         np         = iparm(8)
         ni         = iparm(9)
         nspecies   = iparm(10)
         n          = iparm(11)
         iaccep     = iparm(12)
         irejec     = iparm(13)
         nbin       = iparm(14)
         nsbin      = iparm(15)
         iseed      = iparm(16)
         irnd       = iparm(17)
         istart     = iparm(18)
        !gtype      = iparm(19)
        !gspec      = iparm(20)
         nckpt      = iparm(21)
         nout       = iparm(22)
         ncom       = iparm(23)
      endif
      call MPI_barrier(MPI_COMM_WORLD,ierr)

   30 if(myrank.eq.0) then
         lparm(1) = g_on
         lparm(2) = pressure_on
         lparm(3) = append
         call MPI_Bcast(lparm, 3, MPI_LOGICAL, 0, MPI_COMM_WORLD, ierr)
      else
         call MPI_Bcast(lparm, 3, MPI_LOGICAL, 0, MPI_COMM_WORLD, ierr)
         g_on        = lparm(1)
         pressure_on = lparm(2)
         append      = lparm(3)
      endif
      call MPI_barrier(MPI_COMM_WORLD,ierr)

   40 continue
         call MPI_Bcast(runmdin, 256, MPI_CHARACTER, 0, MPI_COMM_WORLD, ierr)
         call MPI_Bcast(mdin, 256, MPI_CHARACTER, 0, MPI_COMM_WORLD, ierr)
         call MPI_Bcast(suffix, 40, MPI_CHARACTER, 0, MPI_COMM_WORLD, ierr)
         call MPI_Bcast(spec_file, 256, MPI_CHARACTER, 0, MPI_COMM_WORLD, ierr)
         call MPI_Bcast(ion_file, 256, MPI_CHARACTER, 0, MPI_COMM_WORLD, ierr)
         call MPI_Bcast(sim_type, 20, MPI_CHARACTER, 0, MPI_COMM_WORLD, ierr)
         call MPI_Bcast(coulomb, 20, MPI_CHARACTER, 0, MPI_COMM_WORLD, ierr)
         call MPI_Bcast(nuclear, 20, MPI_CHARACTER, 0, MPI_COMM_WORLD, ierr)
         call MPI_Bcast(detail, 3, MPI_CHARACTER, 0, MPI_COMM_WORLD, ierr)

   50 continue
         call MPI_Bcast(spec, 3*MAXSPEC, MPI_INTEGER, 0,MPI_COMM_WORLD, ierr)


      return
      end subroutine bcast_parms



      end module md_comm
