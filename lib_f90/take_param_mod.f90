MODULE take_param_mod
!
!  Combines all routines that handle the command parameters within the suite
!  At the moment only the code for optional parameters, 
!  get_params  ! gets the parameters from the input line, currently in dkdo.f90
!  ber_params  ! calculates the parameters from the input line, currently in dkdo.f90
!
CONTAINS
!
SUBROUTINE get_optional(ianz, MAXW, cpara, lpara, NOPTIONAL, ncalc, &
                        oname, loname, opara, lopara, owerte)
!
!  Takes any optional parameter out of the list of input parameters.
!  These optional parameters are copied into the array opara and the 
!  original list is cleaned of these optional parameters.
!  An optional parameter takes the form:
!  name:value
!  Here name is a string supplied by the user, and value a string that
!  gives the value. To handle numerical and character values, the 
!  numerical values must always be the first ncalc parameters. The
!  remaining parameters will not be calculated, and the routine returns
!  the strings only.
!
use charact_mod
USE errlist_mod
!
IMPLICIT NONE
!
INTEGER                               , INTENT(INOUT) :: ianz      ! Actual parameter number
INTEGER                               , INTENT(IN)    :: MAXW      ! Max para numbeer
CHARACTER(LEN=*), DIMENSION(1:MAXW)   , INTENT(INOUT) :: cpara     ! input strings
INTEGER,          DIMENSION(1:MAXW)   , INTENT(INOUT) :: lpara     ! input string lengths
INTEGER                               , INTENT(IN)    :: NOPTIONAL ! No opt. params
INTEGER                               , INTENT(IN)    :: ncalc     ! No of params to calculate
CHARACTER(LEN=*), DIMENSION(NOPTIONAL), INTENT(IN)    :: oname     ! Lookup table
INTEGER,          DIMENSION(NOPTIONAL), INTENT(IN)    :: loname    ! lookup table length
CHARACTER(LEN=*), DIMENSION(NOPTIONAL), INTENT(INOUT) :: opara     ! with default values
INTEGER,          DIMENSION(NOPTIONAL), INTENT(INOUT) :: lopara    ! length of results
!LOGICAL,          DIMENSION(NOPTIONAL), INTENT(OUT)   :: lpresent  ! Is param present ?
REAL   ,          DIMENSION(NOPTIONAL), INTENT(INOUT) :: owerte    ! calc. results with default values
!
INTEGER :: i,j, iopt, istart
INTEGER :: letter
INTEGER :: icolon
INTEGER :: len_look, len_user, l0
LOGICAL :: ascii                   ! Test if we have letters only
!
LOGICAL :: str_comp
!
!lpresent(:) = .FALSE.
IF(ianz==0) RETURN           ! No parameters at all
!
istart = ianz
search: DO i=istart,1, -1     ! Count backwards
   icolon = INDEX(cpara(i)(1:lpara(i)),':')
   IF(icolon > 0) THEN    ! We might have an optional parameter
      ascii = .TRUE.
      DO j=1, icolon-1    ! Check is all characters are small letters
         letter = IACHAR(cpara(i)(j:j))
         ascii = ascii .AND. (a<=letter .AND. letter<=z)
      ENDDO
      IF(.NOT.ascii) CYCLE search  ! String contains non-(a..z) skip this parameter
      look: DO iopt=1, NOPTIONAL ! Look up optional parameter name
         len_look = loname(iopt)
         len_user = icolon-1
         l0 = MIN(len_look,len_user)
         IF(str_comp(cpara(i)(1:len_user), oname(iopt), l0, len_user, len_look)) THEN  ! Found parameter
            opara(iopt)  = cpara(i)(icolon+1:lpara(i))  ! Copy user provided string
            lopara(iopt) = lpara(i)-icolon              ! record user provided string length
!            lpresent(iopt) = .TRUE.
            cpara(i) = ' '      ! clear parameter, this avoids issue for parameter ianz
            lpara(i) = 0
            DO j = i+1, ianz    ! shift subsequent parameters down
               cpara(j-1) = cpara(j)
               lpara(j-1) = lpara(j)
            ENDDO
            ianz = ianz - 1
            CYCLE search
         ENDIF
      ENDDO look
      ier_num = -12
      ier_typ = ER_COMM
      ier_msg(1) = 'Offending parameter name:'
      ier_msg(2) = cpara(i)(1:MIN(43,lpara(i)))
      RETURN
   ENDIF
ENDDO search
!
!  Calculate numerical values for the first ncalc parameters
!
CALL ber_params (ncalc, opara, lopara, owerte, NOPTIONAL)
!
!
END SUBROUTINE get_optional
END MODULE take_param_mod
