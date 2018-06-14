c CLASS = D
c  
c  
c  This file is generated automatically by the setparams utility.
c  It sets the number of processors and the class of the NPB
c  in this directory. Do not modify it by hand.
c  
        integer          lelt, lmor, refine_max, fre_default
        integer          niter_default, nmxh_default
        character        class_default
        double precision alpha_default
        parameter(  lelt=515000,
     >             lmor=19500000,
     >              refine_max=10,
     >              fre_default=5,
     >              niter_default=250,
     >              nmxh_default=10,
     >              class_default="D",
     >              alpha_default=0.046d0 )
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
