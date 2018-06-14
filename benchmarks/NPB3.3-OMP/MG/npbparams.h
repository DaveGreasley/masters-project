c CLASS = E
c  
c  
c  This file is generated automatically by the setparams utility.
c  It sets the number of processors and the class of the NPB
c  in this directory. Do not modify it by hand.
c  
        integer nx_default, ny_default, nz_default
        parameter (nx_default=2048, ny_default=2048, nz_default=2048)
        integer nit_default, lm, lt_default
        parameter (nit_default=50, lm = 11, lt_default=11)
        integer debug_default
        parameter (debug_default=0)
        integer ndim1, ndim2, ndim3
        parameter (ndim1 = 11, ndim2 = 11, ndim3 = 11)
        integer*8 one, nr, nv, ir
        parameter (one=1)
        logical  convertdouble
        parameter (convertdouble = .false.)
        character compiletime*11
        parameter (compiletime='14 Jun 2018')
        character npbversion*5
        parameter (npbversion='3.3.1')
        character cs1*8
        parameter (cs1='gfortran')
        character cs2*6
        parameter (cs2='$(F77)')
        character cs3*6
        parameter (cs3='(none)')
        character cs4*6
        parameter (cs4='(none)')
        character cs5*28
        parameter (cs5='-O1 -fopenmp -mcmodel=medium')
        character cs6*28
        parameter (cs6='-O1 -fopenmp -mcmodel=medium')
        character cs7*6
        parameter (cs7='randi8')
