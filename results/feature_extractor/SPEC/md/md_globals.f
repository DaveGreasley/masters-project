!*******************************************************************************
!
!     MD 6.0.7
!  ---------------------------------------------------------------------
!     Copyright 2009, The Trustees of Indiana University
!     Authors:           Charles J. Horowitz,  Don Berry
!     Last modified by:  Don Berry, 30-Jul-2009
!  ---------------------------------------------------------------------
!
!*******************************************************************************


      module md_globals

      use md_types

      save


      integer, parameter :: MAXSPEC=1000    !max number of species allowed

!===============================================================================
!
!                 Parameters defining the simulation.
!
!DKB-todo : Are there any more runmd.in parameters that ought to have default values?

      character*256 :: runmdin='runmd.in' ! run definition file
      character*256 :: mdin='md.in'       ! initial configuration file
      integer       :: istart     ! specifies how to construct initial config.
      character*40  :: suffix=''  ! for making file names.
      real(dble)    :: tstart     ! simulation start time (fm/c)
      real(dble)    :: time       ! simulation clock (fm/c)
      real(dble)    :: dt         ! simulation time step (fm/c)
      real(dble)    :: tend       ! simulation end time (fm/c)
      integer       :: iseed      ! seed for random number generator
      integer       :: irnd       ! selects which random number generator to use

      integer       :: nn=0, np=0 ! number of free neutrons and protons
      integer       :: ni=0       ! number of ions
      real(dble)    :: zi=0., ai=0. ! charge and mass numbers for pure-ion simulations
      integer       :: nspecies=0 ! number of ion species, for ion mixture simulations
      character*256 :: spec_file='' ! where to read species list from
      type(species),save :: spec(MAXSPEC) ! list of particle species
      character*256 :: ion_file='' ! file to read per-particle charge and mass data
      integer       :: n          ! total number of particles
      real(dble)    :: rho        ! particle density (particles/fm^3)
      real(dble)    :: xl         ! edge length of simulation box (fm)
      real(dble)    :: t          ! temperature (MeV)
      real(dble)    :: xmass      ! nucleon mass (MeV)
      real(dble)    :: rmax=0.0   ! radius of nucleus, for doing large-nucleus sims.
      type(species), parameter  :: proton  = species(0,1.,1.)
      type(species), parameter  :: neutron = species(0,0.,1.)
      type(species), parameter  :: nullspecies = species(0,0.,0.)
      type(species), parameter  :: allspecies = species(0,-1.,-1.)
      logical       ::pressure_on = .false. ! do/don't activate pressure calculation

      integer       :: iaccep     !DKB-todo : what is this for?
      integer       :: irejec     !DKB-todo : what is this for?

      integer       :: nwgroup    ! number of groups of warmup steps
      integer       :: nwsteps    ! number of warmup steps per group
      integer       :: ngroup     ! number of measurement groups
      integer       :: ntot       ! number of measurements per group
      integer       :: nind       ! number of steps between measurements
      integer       :: ncom = 0   ! no. steps between center-of-mass velocity subtraction

      integer       :: tnormalize = 0  !steps between temperature normalization


!  Frequency for checkpointing and saving configurations. These integers are the
!  number of micro timesteps between outputs. A value of 0 means don't output.
!  (But a real(dble) (x,v) checkpoint file is always output at the end of a run.)
      integer       :: nckpt = 0   ! no. micro steps between checkpoints
      integer       :: nout = 0    ! no. micro steps between config ouputs


!  Detail and precision of the saved config files:
      character*3   :: detail = 'x4'
                         ! x4  = positions only, real*4
                         ! xv4 = positions and velocities, real*4
                         ! x8  = positions only, real*8
                         ! xv8 = positions and velocities, real*8
      logical       :: append = .true.
                         ! .true.  = append all configs to an md.traj file
                         ! .false. = configs go to individial md.out files


!  Parameters for two-particle correlation function, and static structure factor.
      logical            :: g_on = .false.  ! activate correlation function g(r)
      type(species),save :: gspec    ! particle species to calculate g(r) for
      integer            :: nbin     ! number of bins for g(r)
      integer            :: nsbin    ! number of bins for S(q)
      real(dble)         :: qmin,dq  ! minimum q and bin width for S(q)

      common  /rndtype/irnd


!  Type of simulation to be performed.
      character*20 ::  sim_type = ''

!  Parameters defining the Coulomb interaction.
      character*20  ::  coulomb = ''    ! type of coulomb interaction
      real(dble)    ::  xmuc = 0.0d0    ! inverse screening length
      real(dble)    ::  vc
      real(dble)    ::  frp = 1.0d0     ! ion form factor, f(Rp/xlambda)

!  Parameters defining the nuclear interaction.
      character*20 ::  nuclear = ''  ! type of nuclear interaction
      real(dble)   ::  xl2 = 0.0d0
      real(dble)   ::  alpha
      real(dble)   ::  beta
      real(dble)   ::  c

!  Parameters defining external electric and magnetic fields.
!  Note that this version does not do external B and E fields. We leave these
!  variables defined here for future use.
      real(dble)   ::  bfield = 0.0d0  ! uniform B field in z direction (Gauss)
      real(dble)   ::  efield = 0.0d0  ! amplitude of oscillating E field (Mev/fm)
      real(dble)   ::  q0              ! wave number of E field (1/fm)
      real(dble)   ::  w0              ! frequency of E field (1/fm)
      real(dble)   ::  tref            ! time reference for E field (fm/c)

!===============================================================================


!-------------------------------------------------------------------------------
!  MPI variables.
      integer      ::  myrank = 0     ! MPI rank, or process, number
      integer      ::  nprocs = 1     ! number of MPI processes


!-------------------------------------------------------------------------------
! Particle data.
      real(dble), allocatable, target ::   x(:,:)
      real(dble), allocatable         ::   v(:,:),vold(:,:)
      real(dble), allocatable         ::   a(:,:)
      integer,    allocatable, target ::   type(:)
      real(dble), allocatable         ::   zii(:)  !Z for each ion
      real(dble), allocatable         ::   aii(:)  !A for each ion


!-------------------------------------------------------------------------------
!  Arrays needed for computing two-particle correlation function.
      real(dble), allocatable    :: gg(:,:,:)
      real(dble), allocatable    :: cgg(:)

!-------------------------------------------------------------------------------
!  Arrays needed for computing the static structure factor.
      real(dble), allocatable    :: ss(:,:)
      real(dble), allocatable    :: cs(:)


!===============================================================================

      end module md_globals
