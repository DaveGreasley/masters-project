!*******************************************************************************
!
!     MD 6.0.7
!  ---------------------------------------------------------------------
!     Copyright 2009, The Trustees of Indiana University
!     Authors:           Charles J. Horowitz,   Don Berry
!     Last modified by:  Don Berry, 24-Sep-2009
!  ---------------------------------------------------------------------
!
!*******************************************************************************

      program md
      use  md_types
      use  md_globals
      use  md_comm
      implicit real(dble) (a-h,o-z)
      include 'perf.h'   !DKB-perf
      include 'mpif.h'

! Average per particle energies: ek=kinetic, ev=potential, e=total
      real(dble)   ek, ev, e            !based on current configuration
      real(dble),allocatable :: eva(:)  !mean per measurement group
      real(dble),allocatable :: ev2a(:) !2nd moment, per measurement group
      real(dble),allocatable :: dev(:)  !std.dev., per measurement group
      real(dble)   evave,ev2ave,devave  !mean, 2nd moment, and std.dev. of eva(:)

! Pressure:  pp=pressure
      real(dble)   pp
      real(dble),allocatable :: pa(:)  !mean per measurement group
      real(dble),allocatable :: p2a(:) !2nd moment, per measurement group
      real(dble),allocatable :: dp(:)  !std.dev., per measurement group
      real(dble)   pave,p2ave,dp2ave   !mean, 2nd moment, and std.dev. of pa(:)

!  Initialize timers to monitor program performance.
      call perf_init      !DKB-perf
      call starttimer()   !DKB-perf (md)

!  Initialize MPI message passing system. (Stubbed out in the non-MPI code.)
      call MPI_init(ierror)
      call MPI_comm_size(MPI_COMM_WORLD,nprocs,ierror)
      call MPI_comm_rank(MPI_COMM_WORLD,myrank,ierror)

!  Input the parameters describing the run.
      runmdin = 'runmd.in'
      mdin = 'md.in'
      call input1
      allocate(eva(ngroup),ev2a(ngroup),dev(ngroup))
      allocate(pa(ngroup),p2a(ngroup),dp(ngroup))
      time=tstart

!  Initalize positions and velocities.
      call inital

!  Set up parameters and data structures needed for gathers of particle data in
!  the parallel program. This is basically a "no-op" for the serial code.
      call setup_gather

!  Initalize array for correlation function g(r).
      if(g_on) call g(0)

!  Calculate energy of initial configuration
      call vtot(ev)
      call ttot(ek)
      e=ev+ek
      if(myrank.eq.0) then
        write(6,10050) '  Initial config:  Vtot, Ttot, E = ',ev,ek,e
        write(8,10050) '  Initial config:  Vtot, Ttot, E = ',ev,ek,e
10050   format(a,2x,es16.9,2x,es16.9,2x,es16.9)
      endif

!  Calculate initial accelerations.
      call accel
     !call dump_data    !DKB-debug

!  ---------------------------------------------------------------------
!  Do warm up steps.
      istep=0
      do i=1,nwgroup
        do j=1,nwsteps
          call newton
          istep=istep+1
          if(mdmod(istep,nckpt).eq.0) call checkpoint
        enddo
        call subtract_vcom
        call tnorm
        if(myrank.eq.0) then
          write(6,10080) time
          write(8,10080) time
10080     format(6x,1x,f14.2,'   warm up')
        endif
      enddo
      if(mdmod(istep,nckpt).gt.0) call checkpoint

!  ---------------------------------------------------------------------
!  Do measurement steps. This is the main MD loop.
      evave=0.
      ev2ave=0.
      pave=0.
      p2ave=0.
      pp=0.
      istep=0
      do 100 ig=1,ngroup
        if(ig.eq.1 .and. myrank.eq.0) then
          write(6,10090)
          write(8,10090)
10090     format('  Measurement phase',/,  &
                 '  group      time            Vtot              Ttot      ', &
                 '         E              pressure')
        endif
        eva(ig)=0.
        ev2a(ig)=0.
        pa(ig)=0.
        p2a(ig)=0.
        do 40 j=1,ntot
          do i=1,nind
            if(mdmod(istep,ncom).eq.0) call subtract_vcom
            if(mdmod(istep,tnormalize).eq.0) call tnorm
            call newton
            istep=istep+1
            if(mdmod(istep,nout).eq.0) call save_config(detail,append)
            if(mdmod(istep,nckpt).eq.0) call checkpoint
          enddo
          call vtot(ev)
          call ttot(ek)
          e=ek+ev
          eva(ig)  = eva(ig)+ev
          ev2a(ig) = ev2a(ig)+ev**2
          if(pressure_on) then
            call pressure(pp)
            pa(ig)  = pa(ig)+pp
            p2a(ig) = p2a(ig)+pp**2
          endif
          if(myrank.eq.0) then
            if(pressure_on) then
              write(6,10101) time,ev,ek,e,pp
              write(8,10101) time,ev,ek,e,pp
            else
              write(6,10101) time,ev,ek,e
              write(8,10101) time,ev,ek,e
            endif
10100       format(6x,1x,f14.2,2x,1pe16.9,18x,2x,1pe16.9)
10101       format(6x,1x,f14.2,2x,es16.9,2x,es16.9,2x,es16.9,2x,es16.9)
          endif
          if(g_on) call g(ig)
   40   continue
        call statt(eva(ig),ev2a(ig),ntot,dev(ig),evave,ev2ave)
        call statt(pa(ig),p2a(ig),ntot,dp(ig),pave,p2ave)
        if(myrank.eq.0) then
          if(pressure_on) then
            write(6,10110) ig,time, eva(ig),dev(ig), pa(ig),dp(ig)
            write(8,10110) ig,time, eva(ig),dev(ig), pa(ig),dp(ig)
          else
            write(6,10110) ig,time, eva(ig),dev(ig)
            write(8,10110) ig,time, eva(ig),dev(ig)
          endif
10110     format(i6,1x,f14.2,  2x,1pe16.9,2x,1pe16.9, 2x,16x,2x,1pe16.9,2x,1pe16.9)
        endif
  100 continue
!  ----------------------------------------------------------------------

      x1=0.
      x2=0. 
      call statt(evave,ev2ave,ngroup,devave,x1,x2)
      call statt(pave,p2ave,ngroup,dpave,x1,x2)

      if(myrank.eq.0) then
        write(6,10200) '  total pot =      ', evave, ' +/-', devave
        write(8,10200) '  total pot =      ', evave, ' +/-', devave
        write(6,10200) '  total pressure = ', pave, ' +/-', dpave
        write(8,10200) '  total pressure = ', pave, ' +/-', dpave
10200   format(2(a,1pe16.9))
      endif
      if(mdmod(istep,nckpt).gt.0) call checkpoint
      if(g_on) then
        call g(-1)
        call s
        call g(-2)
      endif
      call vtot(ev)
      call ttot(ek)
      e=ev+ek
      if(myrank.eq.0) then
        write(6,10210) '  Final config:    Vtot, Ttot, E = ',ev,ek,e
        write(8,10210) '  Final config:    Vtot, Ttot, E = ',ev,ek,e
10210   format(a,3(2x,1pe16.9))
      endif

!  Deallocate particle arrays.
      deallocate(a, v, vold, x)
      if(allocated(type)) deallocate(type)    !particle type array
      if(allocated(aii)) deallocate(aii)      !mass numbers A
      if(allocated(zii)) deallocate(zii)      !charge numbers Z

!  Deallocate statistics arrays.
      deallocate(eva,ev2a,dev)
      deallocate(pa,p2a,dp)

      call stoptimer(1,t_md,ts_md,n_md)  !DKB-perf (md)
      call perf_report    !DKB-perf
      if(myrank.eq.0) close(8)

      call destroy_gather
      call MPI_finalize(ierror)

      stop
      end program md


!*******************************************************************************
!  Checkpoint the run. This is not a true checkpoint, as it does not save the
!  run parameters, nor the statistics arrays. It saves the positions and veloci-
!  ties in full precision binary.
!DKB-todo : Fix checkpoint subroutine so it really does a complete checkpointing of the job.
!
      subroutine checkpoint
      use  md_types
      use  md_globals
      use  md_comm
      implicit real(dble) (a-h,o,z)
      include 'mpif.h'

      character*256   mdoutfile

!  Gather all coordinates and velocities to MPI process 0.
      call gather(x,0)
      call gather(v,0)

!  Only MPI process 0 writes to the checkpoint file.
      if(myrank.eq.0) then
         write(mdoutfile,110) int(time/1000000.d0), int(mod(time,1000000.d0))
  110    format('md.ckpt.',i5.5,i6.6)
         open(UNIT=14,FILE=mdoutfile,STATUS='UNKNOWN',FORM='UNFORMATTED')
         write(14) time
         write(14) (x(1,i),x(2,i),x(3,i),v(1,i),v(2,i),v(3,i), i=0,n-1)
         close(14)
      endif

      call MPI_barrier(MPI_COMM_WORLD,ierror)

      return
      end subroutine checkpoint


!*******************************************************************************
!  Save configuration to a file. Depending on input arguments, this routine
!  saves a configuration (i.e., positions only) or a phase space point (positions
!  and velocities). Argument xdetail determines what to write out, and in what
!  precision. Argument xappend determines whether to write each configuration to
!  a separate file, or append configurations to a single trajectory file.
!
!  Arguments:
!
!    character*3  xdetail  -- specifies what to save in configuration file
!        'x4'  = real positions
!        'xv4' = real positions, real velocities.
!        'x8'  = real(dble) positions
!        'xv8' = real(dble) positions, real(dble) velocities.
!
!    logical      xappend  -- 
!        .true . = append all configs to a single md.traj file
!        .false. = write each config to its own md.out file
!
!  Global data used:
!    real(dble)   x(3,n) -- positions
!    real(dble)   v(3,n) -- velocities
!    real(dble)   tend   -- used to create suffix for md.traj file
!    real(dble)   time   -- used to create suffix for md.out file

      subroutine save_config(xdetail,xappend)
      use  md_types
      use  md_globals
      use  md_comm
      implicit real(dble) (a-h,o-z)
      include 'mpif.h'

      character*3  xdetail
      logical      xappend

      character*256   mdoutfile

!  Gather all coordinates to process 0. Gather velocities if xdetail contains 'v'.
      call gather(x,0)
      if(scan(xdetail,'v').ne.0) call gather(v,0)

!  Only MPI process 0 writes to the file.
      if(myrank.eq.0) then

        if(xappend) then
          write(mdoutfile,100) int(tend/1000000.d0), int(mod(tend,1000000.d0))
  100     format('md.traj.',i5.5,i6.6)
          open(UNIT=14,FILE=mdoutfile,STATUS='UNKNOWN',FORM='UNFORMATTED',POSITION='APPEND')
        else
          write(mdoutfile,110) int(time/1000000.d0), int(mod(time,1000000.d0))
  110     format('md.out.',i5.5,i6.6)
          open(UNIT=14,FILE=mdoutfile,STATUS='UNKNOWN',FORM='UNFORMATTED')
        endif

        select case (trim(xdetail))
          case('x4')
            write(14) real(time)
            write(14) (real(x(1,i)),real(x(2,i)),real(x(3,i)), i=0,n-1)
          case('xv4')
            write(14) real(time)
            write(14) (real(x(1,i)),real(x(2,i)),real(x(3,i)),            &
                       real(v(1,i)),real(v(2,i)),real(v(3,i)), i=0,n-1)
          case('x8')
            write(14) time
            write(14) (x(1,i),x(2,i),x(3,i), i=0,n-1)
          case('xv8')
            write(14) time
            write(14) (x(1,i),x(2,i),x(3,i),v(1,i),v(2,i),v(3,i), i=0,n-1)
        end select

        close(14)

      endif

      call MPI_barrier(MPI_COMM_WORLD,ierror)
      return
      end subroutine save_config
   


!*******************************************************************************
!  Dump x, v, and a arrays to a file. This subroutine is meant for debugging.
!  Normally one does not need to save the accelerations. Dumped data files are
!  suffixed with the current simulation time, and an additional sequence number, 
!  so that up to 100 dump files may be saved during each time step.
!
      subroutine dump_data
      use  md_types
      use  md_globals
      use  md_comm 
      implicit real(dble) (a-h,o,z)
      include 'mpif.h'

      character*256   md_dump_file
      real(dble), save :: xtime=0.0d0
      integer, save    :: nseq=0

      if(xtime.ne.time) then
         xtime=time
         nseq=0  
      endif   

      call gather(x,0)
      call gather(v,0)
      call gather(a,0)

!  Only MPI process 0 writes to the md_dump file.
      if(myrank.eq.0) then
         write(md_dump_file,110) int(time/1000000.d0), int(mod(time,1000000.d0)), nseq
  110    format('md.dump.',i5.5,i6.6,'.',i2.2)
         open(UNIT=14,FILE=md_dump_file,STATUS='UNKNOWN',FORM='UNFORMATTED')
         write(14) time
         write(14) (x(1,i),x(2,i),x(3,i),v(1,i),v(2,i),v(3,i),a(1,i),a(2,i),a(3,i), i=0,n-1)
         close(14)
      endif   

      nseq=nseq+1
      call MPI_barrier(MPI_COMM_WORLD,ierror)

      return  
      end subroutine dump_data
   



!*******************************************************************************
      subroutine statt(xa,xa2,n,dx,xave,x2ave)
      use  md_types
      implicit real(dble)(a-h,o-z)
      xa=xa/float(n)
      xa2=xa2/float(n)
      dx=sqrt(abs(xa2-xa*xa)/(float(n-1)+1.e-10))
      xave=xave+xa
      x2ave=x2ave+xa*xa
      return
      end subroutine statt


!*******************************************************************************
!  Integrate Newton's law using the velocity Verlet scheme.
!
      subroutine newton
      use  md_types
      use  md_globals
      use  md_comm
      implicit real(dble)(a-h,o-z)
      include  'perf.h'

      real(dble)   vp(3)

      call starttimer()   !DKB-perf (newton)

!  ---------------------------------------------------------
!  Integrate accelerations and velocities a full time step dt to get updated
!  coordinates.
      afac=0.5*(dt**2) 
      halfdt=0.5*dt
      do i=myrank,n-1,nprocs
        do k=1,3
          x(k,i)=x(k,i)+v(k,i)*dt+afac*a(k,i)
          if(x(k,i).lt.0)  x(k,i)=x(k,i)+xl  !periodic boundary conditions
          if(x(k,i).gt.xl) x(k,i)=x(k,i)-xl 
        enddo
      enddo

!  Gather all coordinates to every process.
      call allgather(x)

!  ---------------------------------------------------------
!  Save old velocities and integrate old accelerations a full time step to
!  get an estimate of new velocities at time t+dt.
      do i=myrank,n-1,nprocs
        vold(:,i)=v(:,i)
        v(:,i)=v(:,i)+dt*a(:,i)
      enddo

!  ---------------------------------------------------------
!  Calculate new acceleration at t+dt
      call accel

!  ---------------------------------------------------------
!  Using old velocities, integrate new accelerations a full time step to
!  get another estimate of new velocities at t+dt. Set the new velocities
!  to the average of the two velocity estimates.
      do i=myrank,n-1,nprocs
        vp(:)=vold(:,i)+dt*a(:,i)
        v(:,i)=0.5*(v(:,i)+vp(:))
      enddo

     !call dump_data    !DKB-debug

!  ---------------------------------------------------------
!  Update the total integration time
      time=time+dt

      call stoptimer(1,t_newton,ts_newton,n_newton)  !DKB-perf (newton)
      return
      end subroutine newton





      
!*******************************************************************************
!
!**************     MOVE THESE PROCEDURES TO A MODULE             **************
!
!*******************************************************************************
!  Subtract center-of-mass motion.
!
      subroutine subtract_vcom
      use  md_globals
      use  md_comm
      implicit real(dble) (a-h,o-z)
      include  'mpif.h'
      real(dble)  mvcm(0:3)   ! total mass and center-of-mass momentum
      real(dble)  xmvcm(0:3)  ! temporary array for accumulating
      real(dble)  vcom(3)     ! center-of-mass velocity

      xmvcm = 0.0
      do i=myrank,n-1,nprocs
        xmvcm(0) = xmvcm(0)+(aii(i)*xmass)
        xmvcm(1:3) = xmvcm(1:3)+(aii(i)*xmass)*v(1:3,i)
      enddo
      call MPI_allreduce(xmvcm,mvcm,4,MPI_DOUBLE_PRECISION,MPI_SUM,MPI_COMM_WORLD,ierror)
      vcom(1:3) = mvcm(1:3)/mvcm(0)
      do i=myrank,n-1,nprocs
         v(:,i) = v(:,i) - vcom(:)
      enddo

      end subroutine subtract_vcom


      
!*******************************************************************************
!  Calculate average kinetic energy per particle.
!
      subroutine ttot(eka)
      use  md_globals
      use  md_comm
      implicit real(dble) (a-h,o-z)
      include  'mpif.h'

      ek=0.
      do i=myrank,n-1,nprocs
         ek = ek + 0.5*(aii(i)*xmass)*(v(1,i)**2+v(2,i)**2+v(3,i)**2)
      enddo
      call MPI_allreduce(ek,eka,1,MPI_DOUBLE_PRECISION,MPI_SUM,MPI_COMM_WORLD,ierror)
      eka=eka/float(n)

      return
      end subroutine ttot


      
!*******************************************************************************
!  Calculate distance between particles i and j. Return result in rr.
!
      subroutine pdist(i,j,rr)
      use  md_globals
      implicit real(dble) (a-h,o-z)

      rr=0.
      do k=1,3
         yy=abs(x(k,i)-x(k,j))
         yy=min(yy,xl-yy)   
         rr=rr+yy*yy
      enddo
      rr=sqrt(rr)+1.e-15
      return
      end subroutine pdist



!*******************************************************************************
!  By the equipartition theorem, the average kinetic energy per particle is
!  related to the temperature by  eka=(3/2)kT. This subroutine scales particle
!  velocities so that eka matches the specified temperature kT.
!
      subroutine tnorm
      use  md_globals
      implicit real(dble)(a-h,o-z)
        
      call ttot(eka)
      fac=sqrt(eka/(1.5*t))
      do i=myrank,n-1,nprocs
        v(:,i)=v(:,i)/fac
      enddo
      return
      end subroutine tnorm



!*******************************************************************************
!  The fortran mod function, except that it returns -1 if q=0.

      integer function mdmod(p,q)
      integer  p,q
      if(q.eq.0) then
        mdmod = -1
      else
        mdmod = mod(p,q)
      endif
      return
      end function mdmod
