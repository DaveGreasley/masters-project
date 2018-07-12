!*******************************************************************************
!     MD 6.0.7
!  ----------------------------------------------------------------------
!     Copyright 2009, The Trustees of Indiana University
!     Authors:           Charles J. Horowitz,   Don Berry
!     Last modified by:  Don Berry, 22-Jan-2009
!  ----------------------------------------------------------------------
!
!  Read the parameter file for the simulation. Use input parameters to calcu-
!  late further simulation parameters. Write all parameters to standard out,
!  and to a run log file, md.log.xxxxxxxxxxx, where "xxxxxxxxxxx" is an 11-digit
!  integer specifying the end time of the simulation. It is calculated from the
!  start time, time step, nwgroup, nwsteps, nind, ntot, and ngroup.
!
!*******************************************************************************


      subroutine input1
      use  md_types
      use  md_globals
      use  md_comm
      implicit real*8 (a-h,o-z)
      include  'mpif.h'

!  The following namelist is used to read all the input parameters. Most of the
!  input parameters are defined in module md_globals.
      namelist  /run_parameters/                         &
                 sim_type,                               &
                 tstart, dt,                             &
                 nwgroup, nwsteps,                       &
                 ngroup, ntot, nind,                     &
                 nckpt, nout, detail, append,            &
                 nn, np,                                 &
                 ni, zi, ai,                             &
                 spec_file, spec,                        &
                 ion_file,                               &
                 ncom,                                   &
                 tnormalize,                             &
                 xmass, rho, t,                          &
                 pressure_on,                            &
                 g_on,                                   &
                !gspec,                                  &
                 nbin, nsbin, qmin, dq,                  &
                 coulomb, xlambda, frp,                  &
                 bfield,                                 &
                 efield,q0,w0,tref,                      &
                 nuclear, xpacket, alpha, beta, c,       &
                 irnd, iseed, istart, rmax

      integer  inyu(4)
      integer  nprocsspec
      integer  omp_get_num_threads
      integer  omp_get_max_threads
      character*256  line


!  MPI process (or rank) 0 starts at label 10. It reads the run parameter file
!  using the above namelist, and writes run info to stdout and to the run log
!  file. All other MPI processes start at label 1010 and wait for process 0 to
!  broadcast the parameters.

   10 if(myrank.eq.0) then
!===============================================================================
!  Read the run parameter file.
      open(UNIT=10,FILE=runmdin,STATUS='OLD')
      read(10,NML=run_parameters)
      close(10)

!  Calculate simulation end time. Use it as suffix of the md.log file. Since we
!  may have simulation times in the 1e9 range, we need to be careful about integer
!  overflow (for 32-bit integers). Hence the complicated write statement.
      tend = tstart + dt*(nwgroup*nwsteps + ngroup*ntot*nind)
      write(suffix,22) int(tend/1000000.d0), int(mod(tend,1000000.d0))
   22 format('.',i5.5,i6.6)
      open(UNIT=8,FILE='md.log'//suffix, STATUS='UNKNOWN')

!-------------------------------------------------------------------------------
!  Write program version, and what facilities we are using.
      write(6,30,advance='no') mp_type
      write(8,30,advance='no') mp_type
   30 format('  MD_6.0.7, ',a)
#ifdef MDGRAPE
      write(6,32,advance='no')
      write(8,32,advance='no')
   32 format('+MDGRAPE2')
#endif
!#ifdef _OpenMP
      write(6,34,advance='no')
      write(8,34,advance='no')
   34 format('+OpenMP')
!#endif
      write(6,36)
      write(8,36)
   36 format('  ')

      nprocsspec=0
      write(6,40) nprocsspec
      write(8,40) nprocsspec
   40 format('  Number of processes:  ',i6)
#ifdef MDGRAPE
      write(6,42) 1                               !DKB-todo : fix to allow >1
      write(8,42) 1                               !DKB-todo : fix to allow >1
   42 format('  MDGRAPE-2 boards/process: ',i2)
#endif
!#ifdef _OpenMP
     !nthreads = omp_get_num_threads()
      nthreads = 0
      write(6,44) nthreads
      write(8,44) nthreads
   44 format('  OpenMP threads/process: ',i4)
!#endif

      write(6,48)
      write(8,48)
   48 format('  ----------------------------------------------------------')

!-------------------------------------------------------------------------------
!  Start time and time step for simulation (fm/c).
      write(6,50) tstart,dt
      write(8,50) tstart,dt
!  50 format('  start time       time step (fm/c)',/, 2x,f14.2,3x,f8.3)
   50 format('  start time:   ', f14.2,' fm/c',/,       &
             '  time step:          ', f8.2,' fm/c',/)

!  Number of warmup groups; steps per warmup group. Number of measurement groups,
!  measurements per group, and steps between measurements. Number of steps be-
!  tween temperature normalizations during measurement phase.
      write(6,60) nwgroup,nwsteps,ngroup,ntot,nind,tnormalize,ncom
      write(8,60) nwgroup,nwsteps,ngroup,ntot,nind,tnormalize,ncom
   60 format('  nwgroup, nwsteps:    ', i8,1x,i8, /,       &
             '  ngroup, ntot, nind:  ', i8,1x,i8,1x,i8, /, &
             '  tnormalize:          ', i8, /,             &
             '  ncom:                ', i8)

!  Info about configuration and checkpoint files.
      write(6,70) nout, detail, append, nckpt
      write(8,70) nout, detail, append, nckpt
   70 format('  nout, detail, append:', i8,6x,a3,6x,l1, /, &
             '  nckpt:               ', i8)

!-------------------------------------------------------------------------------
!  Type of simulation to run.
      write(6,90) trim(sim_type)
      write(8,90) trim(sim_type)
   90 format(/,'  SIMULATION TYPE:  ',a)

      select case(sim_type)

      !.........................................................................
      !For nucleon simulations, we use the number of neutrons nn, and the number
      !of protons np. We do not use the ion parameters.
      case('nucleon')
         write(6,101) nn,np
         write(8,101) nn,np
  101    format('    neutrons   protons',/, 4x,i8,2x,i8)
         n=nn+np
         allocate(zii(0:n-1))     !not used. allocated for consistency
         allocate(aii(0:n-1))     !not used. allocated for consistency
         allocate(type(0:n-1))
         do i=0,nn-1
            type(i)=0     !neutron
            zii(i)=0.0d0
            aii(i)=1.0d0
         enddo
         do i=nn,n-1
            type(i)=1     !proton
            zii(i)=1.0d0
            aii(i)=1.0d0
         enddo

      !.........................................................................
      !For pure ion simulations, i.e., simulations with a single species of ion,
      !we use the number of ions, the charge number Z, and the mass number A.
      !Nucleon parameters are not used.
      case('pure-ion')
         write(6,102) ni,zi,ai
         write(8,102) ni,zi,ai
  102    format('      #ions     Z        A   ',/, 3x,i8,2x,f7.2,2x,f7.2)
         n=ni
         allocate(zii(0:n-1))     !not used. allocated for consistency.
         allocate(aii(0:n-1))     !not used. allocated for consistency.
         allocate(type(0:n-1))    !not used. allocated for consistency.
         do i=0,n-1
            zii(i)=zi
            aii(i)=ai
         enddo

      !.........................................................................
      !For ion mixture simulations, there are three ways to specify the number of
      !ions, and the charge and mass of each species.
      !(1) A list of ion species may be included directly in the runmd.in file.
      !(2) A list of ion species may be read from a file.
      !(3) Z and A for each ion may be read from a file.
      !DKB-todo : Use file-reader subroutines for the cases,
      !DKB-todo+:   (2) list of ion species included directly in runmd.in file
      !DKB-todo+:   (3) Z and A for each ion read from a file
      !DKB-todo : Handle case where both 'spec_file' and 'ion_file' appear in
      !DKB-todo+:   runmd.in, as well as cases where one or both appear multiple
      !DKB-todo+:   times.
      case('ion-mixture')

         if(spec_file.ne.'') then
            write(6,"('  spec_file:  ',a)") trim(spec_file)
            write(8,"('  spec_file:  ',a)") trim(spec_file)
           !If spec_file=='follows', then np,zi,ai for each species are listed
           !directly in the runmd.in file, and should have been read into the spec
           !array automatically by the namelist facility. Otherwise, we have to
           !open the specified spec_file and read them explicitly.
            if(spec_file.ne.'follows') then    !DKB-todo : handle exceeding of MAXSPEC
               open(12,FILE=spec_file,FORM='FORMATTED',STATUS='OLD')
              !Read any comment lines (which have # in the first column).
               line(1:1)='#'
               do while(line(1:1).eq.'#')
                  read(12,'(a)') line
               enddo
               read(line,*) spec(1)%np,spec(1)%z,spec(1)%a
               read(12,*,end=103) (spec(k)%np,spec(k)%z,spec(k)%a, k=2,MAXSPEC)
  103          close(12)
            endif
            write(6,104)
            write(8,104)
  104       format('  Species    #ions     Z        A   ')
            k=1
            n=0
            do while (spec(k).ne.nullspecies)
               write(6,105) k,spec(k)%np,spec(k)%z,spec(k)%a
               write(8,105) k,spec(k)%np,spec(k)%z,spec(k)%a
  105          format(3x,i4,4x,i7,2x,f7.2,2x,f7.2)
               n=n+spec(k)%np
               k=k+1
            enddo
            nspecies=k-1
            write(6,106) n
            write(8,106) n
  106       format('   Total:  ',i7)
            allocate(zii(0:n-1))
            allocate(aii(0:n-1))
            allocate(type(0:n-1))    !not used. allocated for consistency.
            j=0
            do k=1,nspecies
               do i=1,spec(k)%np
                  zii(j) = spec(k)%z
                  aii(j) = spec(k)%a
                  j=j+1
               enddo
            enddo

         else if(ion_file.ne.'') then
            open(12,FILE=ion_file,FORM='FORMATTED',STATUS='OLD')
            write(6,107) trim(ion_file)
            write(8,107) trim(ion_file)
  107       format('     ion_file = ',a)
           !Read any comment lines (designated by # in the first column).
            line(1:1)='#'
            do while(line(1:1).eq.'#')
               read(12,'(a)') line
            enddo
            read(line,"(i12)") n
            write(6,108) n
            write(8,108) n
  108       format('     n = ',i9)
            allocate(zii(0:n-1))
            allocate(aii(0:n-1))
            allocate(type(0:n-1))    !not used. allocated for consistency.
            read(12,*) (j,zii(i),aii(i),i=0,n-1)
            close(12)

         endif

      end select

!-------------------------------------------------------------------------------
      write(6,"(/)")
      write(8,"(/)")

!  Nucleon mass.
      write(6,110) xmass
      write(8,110) xmass
  110 format('  nucleon mass = ', f8.3, ' MeV')

!  Particle density, box edge length.
      if(rho.gt.0.01) then
         write(6,121) rho
         write(8,121) rho
  121    format('  rho          = ', f10.6, ' fm**-3')
      else if(rho.gt.0.001) then
         write(6,122) rho
         write(8,122) rho
  122    format('  rho          = ', f11.7, ' fm**-3')
      else if(rho.gt.0.0001) then
         write(6,123) rho
         write(8,123) rho
  123    format('  rho          = ', f12.8, ' fm**-3')
      else
         write(6,124) rho
         write(8,124) rho
  124    format('  rho          = ', es12.4, ' fm**-3')
      endif
      xl=(float(n)/rho)**(1./3.)

!  System temperature.
      write(6,125) t
      write(8,125) t
  125 format('  kT           = ', f9.5,   ' MeV')

!-------------------------------------------------------------------------------
!  Whether or not to compute pressure.
      write(6,134) pressure_on
      write(8,134) pressure_on
  134 format('  Compute pressure:  ', l1)

!-------------------------------------------------------------------------------
!  Two-particle correlation function, and static structure function.
!DKB-todo : Calculation of g(r) and S(q) disabled in this version until we figure
!DKB-todo+:    out how to do species-specific calculation.
      if(g_on) then
         g_on = .false.
         write(6,142)
         write(8,142)
  142    format('  *** computation of g(r) and S(q) disabled in this version ***')
!        write(6,140) gspec
!        write(8,140) gspec
! 140    format('  Will compute g(r) and S(q) for species (N,Z)=(',i3,',',i3,')')
!        write(6,141) nbin,nsbin,qmin,dq
!        write(8,141) nbin,nsbin,qmin,dq
! 141    format('      Nbin      Nsbin      Qmin     dQ (fm**-1)',/,            &
!               4x,i6,5x,i6,2x,1pe11.4,2x,1pe11.4)
      else
         write(6,144)
         write(8,144)
  144    format('  Not computing g(r) and S(q)')
      endif

!-------------------------------------------------------------------------------
      write(6,150)
      write(8,150)
  150 format(/,'  INTERACTIONS',/,'  ------------')
!-------------------------------------------------------------------------------

!  Coulomb interactions
!  screened-coulomb = coulomb interaction with exponential screening
!DKB-todo : Screening length calculation is correct only for nucleon simulations.
!DKB-todo+:   It needs to be fixed so it can be used for pure ion and ion mixture
!DKB-todo+:   simulations.

      e2=4.0*3.1415926/137.036
      vc=e2*197.33/(4.0*3.1415926)
      if(coulomb.eq.'screened-coulomb') then
         write(6,151) coulomb
         write(8,151) coulomb
  151    format('  COULOMB:  ',a)
         !If a screening length has been specified, use that. Otherwise
         !calculate the Thomas-Fermi screening length.
         if(xlambda.gt.0) then
            xmuc=1./xlambda
            write(6,152) xlambda, '(defined)'
            write(8,152) xlambda, '(defined)'
         else
            rhop=rho*float(np)/float(n)      !DKB-todo : This is only for nucleon sims.
           !rhop=rho*float(n1+n2)/float(n)   !DKB-todo : Old calc for binary mixtures.
            xkf=(3.*3.1415926**2*rhop)**(1./3.)*197.33
            ef=sqrt(xkf**2+.511**2)
            qtf=sqrt(e2*xkf*ef)/(3.1415926)
            xmuc=qtf/197.33
            write(6,152) 1./xmuc, '(Thomas-Fermi)'
            write(8,152) 1./xmuc, '(Thomas-Fermi)'
         endif
         write(6,154) frp
         write(8,154) frp
  152    format('     screening length = ', f10.5, ' fm  ', a)
  154    format('     ion form factor  = ', f10.5)
 !154    format('     f(Rp/xlambda)    = ', f10.5)    !DKB-note: alternative format
      endif

!-------------------------------------------------------------------------------
!  Nuclear interactions.
!  HPP = Horowitz-Perez-Piekarewicz interaction, Phys.Rev.C69, 045804 (2004)

      if(nuclear.eq.'HPP') then
         xl2=2.0*xpacket	
         write(6,160) nuclear
         write(8,160) nuclear
  160    format('  NUCLEAR:  ',a)
         write(6,162) alpha,beta,c,xpacket
         write(8,162) alpha,beta,c,xpacket
  162    format('     alpha    = ', f8.3, ' MeV',/,  &
                '     beta     = ', f8.3, ' MeV',/,  &
                '     c        = ', f8.3, ' MeV',/,  &
                '     Lambda   = ', f8.3, ' fm^2'  )
      endif

!-------------------------------------------------------------------------------
!  Uniform B field.
      if(bfield.gt.0.0d0) then
         bfield=0.0d0
         write(6,170)
         write(8,170)
  170    format('  *** external B field disabled in this version ***')
!        write(6,170) bfield
!        write(8,170) bfield
! 170    format('  B-FIELD:  ',/,                   &
!               '     B0   = ', 1pe10.3, ' Gauss')
      endif

!-------------------------------------------------------------------------------
!  Oscillating E field.
      if(efield.gt.0.0d0) then
         bfield=0.0d0
         write(6,180) efield
         write(6,180) efield
  180    format('  *** external E field disabled in this version ***')
! 180    format('  E-FIELD:  ',/,                   &
!               '     eE0(Mev/fm) = ', es13.4, ' MeV/fm', /,  &
!               '     q0(fm^-1)   = ', es13.4, ' fm^-1',  /,  &
!               '     w0(fm^-1)   = ', es13.4, ' fm^-1',  /,  &
!               '     tref (fm)   = ', f13.3,  ' fm'   )
      endif

!-------------------------------------------------------------------------------
!  Variable istart tells how to construct the initial configuration.
      write(6,200)
      write(8,200)
200   format(/,'  Type of initial configuration:')
      select case(istart)
      case(1)
        write(6,202) istart, 'random start'
        write(8,202) istart, 'random start'
      case(2)
        write(6,202) istart, 'nuclear start'
        write(8,202) istart, 'nuclear start'
      case(3)
        write(6,202) istart, 'read pasta.in'
        write(8,202) istart, 'read pasta.in'
      case(4)
        write(6,202) istart, 'read x and v from md.in'
        write(8,202) istart, 'read x and v from md.in'
      end select
  202 format(i6,' - ',a)

!-------------------------------------------------------------------------------
!  Variable irnd tells which random number generator to use.
      write(6,210)
      write(8,210)
  210 format('  Random number generator and seed:')
      select case(irnd)
      case(1)
        write(6,212) irnd, 'ran11', iseed
        write(8,212) irnd, 'ran11', iseed
      case(2)
        write(6,212) irnd, 'rannyu', iseed
        write(8,212) irnd, 'rannyu', iseed
      case(3)
        write(6,212) irnd, 'ran3', iseed
        write(8,212) irnd, 'ran3', iseed
      case(4)
        write(6,212) irnd, 'grnd', iseed
        write(8,212) irnd, 'grnd', iseed
      end select
  212 format(i6,' - ',a,4x,i9)

!  Set random number seed. Note iseed should be < 4096.
      do i=1,4              !loop four times
        inyu(i)=iseed/i     !generate array iseed
      end do                !close loop
      call setrn(inyu)      !set the seed
      call sgrnd(iseed)	    !set seed for grnd routine

      iaccep=0   !DKB-todo : What is this for?
      irejec=0   !DKB-todo : What is this for?

!-------------------------------------------------------------------------------
      write(6,220)
      write(8,220)
  220 format('------------------------------------------------------------')

!  MPI process 0 broadcasts all parameters, as well as the charge, mass and type
!  arrays, to the other processes. 
      call bcast_parms
      call MPI_bcast(zii, n, MPI_DOUBLE_PRECISION, 0, MPI_COMM_WORLD, ierror)
      call MPI_bcast(aii, n, MPI_DOUBLE_PRECISION, 0, MPI_COMM_WORLD, ierror)
      call MPI_bcast(type, n, MPI_INTEGER, 0, MPI_COMM_WORLD, ierror)


!===============================================================================
!  All MPI processes other than 0 come here to participate in the broadcasts.
!  Subroutine bcast_parms handles the broadcast of the many scalar parameters.

 1010 else

      call bcast_parms
      allocate(zii(0:n-1))
      allocate(aii(0:n-1))
      allocate(type(0:n-1))
      call MPI_bcast(zii, n, MPI_DOUBLE_PRECISION, 0, MPI_COMM_WORLD, ierror)
      call MPI_bcast(aii, n, MPI_DOUBLE_PRECISION, 0, MPI_COMM_WORLD, ierror)
      call MPI_bcast(type, n, MPI_INTEGER, 0, MPI_COMM_WORLD, ierror)

!===============================================================================
      endif

#ifdef ATP
      call ATP_input1
#endif

      return
      end subroutine input1
