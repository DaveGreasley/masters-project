!*******************************************************************************
!     MD 6.0.7
!  ---------------------------------------------------------------------
!     Copyright 2008, The Trustees of Indiana University
!     Author:            Don Berry
!     Last modified by:  Don Berry, 2009-Jun-09
!  ---------------------------------------------------------------------
!
!*******************************************************************************


module  md_comm
   use md_globals

   character*3       ::  mp_type = 'F90'
   real(dble), allocatable, target  ::  yyy(:,:)
   integer, allocatable, target     ::  typexx(:)

   integer      nx    ! number of particles in my process
   integer      nnx   ! number of free neutrons in my process
   integer      nix   ! number of ions in my process

   integer, private  ::  ierr

   interface MPI_send
      module procedure MPI_send_i
      module procedure MPI_send_d
   end interface

   interface MPI_recv
      module procedure MPI_recv_i
      module procedure MPI_recv_d
   end interface

   interface MPI_bcast
      module procedure MPI_bcast_i1xn
      module procedure MPI_bcast_d3xn
      module procedure MPI_bcast_species1xn
      module procedure MPI_bcast_d1xn
   end interface

   interface MPI_reduce
      module procedure MPI_reduce_da
   end interface

   interface MPI_allreduce
      module procedure MPI_allreduce_d
      module procedure MPI_allreduce_da
   end interface


!*******************************************************************************
!*******************************************************************************

CONTAINS


!*******************************************************************************
!  This procedure sets up the arrays needed to do gathers of particle data.
!  We don't need this in the serial code, but we still need to set up the
!  per-process particle numbers and dummy arrays for the gathers.

   subroutine setup_gather
   implicit none
   nx  = n                 !total number of particles for this process
   nnx = nn                !number of neutrons for this process
  !nix = n1+n2             !number of protons/ions for this process  !DKB-todo : fix
   allocate(yyy(3,0:1))    !dummy -- not used in serial code
   allocate(typexx(0:1))   !dummy -- not used in serial code
   return
   end subroutine setup_gather


!*******************************************************************************
!  This procedure deallocates the arrays used for doing gathers of particle
!  data.

   subroutine destroy_gather
   implicit none
   deallocate(yyy)
   deallocate(typexx)
   return
   end subroutine destroy_gather
      

!*******************************************************************************
!  Gather an array of coordinates or velocities from all processes to a given
!  process. Since there is no need for such a gather in the serial code, we
!  just return.

   subroutine gather(x,root)
   implicit none
   real(dble)   x(3,*)   !array to be gathered
   integer      root     !process to which gather is done
   return
   end subroutine gather


!*******************************************************************************
!  Gather an array of coordinates or velocities from all processes to each
!  process. Since there is no need for such a gather in the serial code, we
!  just return.

   subroutine allgather(x)
   implicit none
   real(dble)  x(3,*)
   return
   end subroutine allgather


!*******************************************************************************
!  In this subroutine, process 0 broadcasts all the run parameters to the other
!  processes. Since there is no need for such a broadcast in the serial code, we
!  just return.

   subroutine bcast_parms
   implicit none
   return
   end subroutine bcast_parms



!*******************************************************************************
!  Stub for MPI_reduce routine. Works only for MPI_DOUBLE_PRECISION datatype.

   subroutine MPI_reduce_da(x,xx,count,datatype,op,root,comm,ierror)
   implicit none
   real(dble)  x(:,:)
   real(dble)  xx(:,:)
   integer     count, datatype, op, root, comm, ierror
   xx = x
   ierror=0
   return
   end subroutine MPI_reduce_da



!*******************************************************************************
!  Stub for MPI_allreduce routine. Works only for scalar MPI_DOUBLE_PRECISION.

   subroutine MPI_allreduce_d(x,xx,count,data_type,op,comm,ierror)
   implicit none
   real(dble)  x
   real(dble)  xx
   integer     count, data_type, op, comm, ierror
   xx = x
   ierror=0
   return
   end subroutine MPI_allreduce_d



!*******************************************************************************
!  Stub for MPI_allreduce routine. Works only for array of MPI_DOUBLE_PRECISION.

   subroutine MPI_allreduce_da(x,xx,count,data_type,op,comm,ierror)
   implicit none
   real(dble)  x(:)
   real(dble)  xx(:)
   integer     count, data_type, op, comm, ierror
   xx = x
   ierror=0
   return
   end subroutine MPI_allreduce_da



!*******************************************************************************
!  Stubs for MPI_init, MPI_finalize, MPI_comm_size and MPI_comm_rank routines.

   subroutine MPI_init(ierror)
   implicit none
   integer    ierror
   ierror=0
   return
   end subroutine MPI_init

   subroutine MPI_finalize(ierror)
   implicit none
   integer    ierror
   ierror=0
   return
   end subroutine MPI_finalize

   subroutine MPI_comm_size(comm,nprocs,ierror)
   implicit none
   integer    comm
   integer    nprocs
   integer    ierror
   nprocs=1
   ierror=0
   return
   end subroutine MPI_comm_size

   subroutine MPI_comm_rank(comm,myrank,ierror)
   implicit none
   integer    comm
   integer    myrank
   integer    ierror
   myrank=0
   ierror=0
   return
   end subroutine MPI_comm_rank



!*******************************************************************************
!  Stubs for MPI_send routines.

   subroutine MPI_send_i(buff,count,datatype,dest,tag,comm,ierror)
   implicit none
   integer    buff(*)
   integer    count, datatype, dest, tag, comm, ierror
   ierror = 0
   return
   end subroutine MPI_send_i

   subroutine MPI_send_d(buff,count,datatype,dest,tag,comm,ierror)
   implicit none
   real(dble)   buff(*)
   integer    count, datatype, dest, tag, comm, ierror
   ierror = 0
   return
   end subroutine MPI_send_d



!*******************************************************************************
!  Stubs for MPI_recv routines.

   subroutine MPI_recv_i(buff,count,datatype,source,tag,comm,status,ierror)
   implicit none
   include 'mpif.h'
   integer    buff(*)
   integer    count, datatype, source, tag, comm, status(MPI_STATUS_SIZE), ierror
   ierror = 0
   return
   end subroutine MPI_recv_i

   subroutine MPI_recv_d(buff,count,datatype,source,tag,comm,status,ierror)
   implicit none
   include 'mpif.h'
   real(dble)   buff(*)
   integer    count, datatype, source, tag, comm, status(MPI_STATUS_SIZE), ierror
   ierror = 0
   return
   end subroutine MPI_recv_d



!*******************************************************************************
!  Stubs for MPI_bcast routine.

   subroutine MPI_bcast_i1xn(buf, count, datatype, root, comm, ierror)
   implicit  none
   integer     buf(*)
   integer     count, datatype, root, comm, ierror
   ierror=0
   return
   end subroutine MPI_bcast_i1xn

   subroutine MPI_bcast_d3xn(buf, count, datatype, root, comm, ierror)
   implicit  none
   real(dble)  buf(3,*)
   integer     count, datatype, root, comm, ierror
   ierror=0
   return
   end subroutine MPI_bcast_d3xn

   subroutine MPI_bcast_species1xn(buf, count, datatype, root, comm, ierror)
   use md_types
   implicit none
   type(species)  buf(*)
   integer        count, datatype, root, comm, ierror
   ierror=0
   return
   end subroutine MPI_bcast_species1xn

   subroutine MPI_bcast_d1xn(buf, count, datatype, root, comm, ierror)
   implicit none
   real(dble)  buf(*)
   integer     count, datatype, root, comm, ierror
   ierror=0
   return
   end subroutine MPI_bcast_d1xn




!*******************************************************************************
!  Stub for MPI_barrier.

   subroutine MPI_barrier(comm,ierror)
   implicit none
   integer    comm
   integer    ierror
   ierror = 0
   return
   end subroutine MPI_barrier



end module md_comm
