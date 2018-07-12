!!
!! Index arrays used to gather nodal data from element arrays rather 
!! than scatter element data to nodal arrays.
!!
      MODULE come_from_arrays_                                                    
                                                                        
      INTEGER, ALLOCATABLE, DIMENSION(:),   SAVE :: ELEMENTS_PER_NODE
      INTEGER, ALLOCATABLE, DIMENSION(:,:), SAVE :: ELEMENT_INDEX
      INTEGER, ALLOCATABLE, DIMENSION(:,:), SAVE :: NODE_PT_INDEX
                                                                        
      END MODULE come_from_arrays_

