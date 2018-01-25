MODULE diffev_reset
!
CONTAINS
!
SUBROUTINE diffev_do_reset
!-
!   Reset DIFFEV to system start
!+
!
USE diffev_allocate_appl
USE diffev_blk_appl
USE population
USE diff_evol
!
IMPLICIT NONE
!
CHARACTER (LEN=1024)                   :: zeile
INTEGER            , PARAMETER         :: MAXW=2
INTEGER                                :: ianz
CHARACTER(LEN=1024), DIMENSION(1:MAXW) :: cpara
INTEGER            , DIMENSION(1:MAXW) :: lpara
!
LOGICAL, PARAMETER   :: is_diffev = .TRUE.
INTEGER              :: lcomm
INTEGER              :: i
!
! Remove all parameter names from the variable entry
DO i=1, pop_dimx
   cpara(1) = 'delete'
   lpara(1) = 6
   cpara(2) = pop_name(i)
   lpara(2) = LEN_TRIM(pop_name(i))
   CALL del_variables (MAXW, ianz, cpara, lpara, is_diffev)
ENDDO
!
zeile ='default'
lcomm = 7
!
pop_gen  = 0
pop_n    = 1
pop_c    = 1
pop_dimx = 1
!
pop_current_trial  = .FALSE.
pop_initialized    = .FALSE.
pop_result_file_rd = .FALSE.
pop_trial_file_wrt = .FALSE.
pop_current        = .FALSE.
!
CALL diffev_do_allocate_appl(zeile,lcomm)
CALL diffev_initarrays
!
END SUBROUTINE diffev_do_reset
!
END MODULE diffev_reset
