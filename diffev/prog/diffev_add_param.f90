MODULE add_param_mod
!
CONTAINS
!
SUBROUTINE add_param(zeile, length)
!
USE compare
USE diffev_allocate_appl
USE population
USE create_trial_mod
USE compare
USE initialise
!
USE errlist_mod
USE lib_f90_allocate_mod
USE take_param_mod
USE variable_mod
!
IMPLICIT NONE
!
CHARACTER(LEN=*), INTENT(INOUT) :: zeile
INTEGER         , INTENT(INOUT) :: length
!
LOGICAL, PARAMETER :: IS_DIFFEV = .TRUE.
INTEGER, PARAMETER :: MAXW = 6
CHARACTER(LEN=1024), DIMENSION(1:MAXW) :: cpara
INTEGER            , DIMENSION(1:MAXW) :: lpara
REAL               , DIMENSION(1:MAXW) :: werte
!
CHARACTER(LEN=LEN(pop_name) )   :: pname
INTEGER                         :: lpname
CHARACTER(LEN=9+LEN(pop_name) ) :: line
CHARACTER(LEN=8)                :: string
INTEGER                         :: laenge
INTEGER                         :: ianz
INTEGER                         :: i
INTEGER                         :: par_number
LOGICAL                         :: lexist
LOGICAL                         :: linit
LOGICAL                         :: lreal
INTEGER, PARAMETER :: NOPTIONAL = 2
CHARACTER(LEN=1024), DIMENSION(NOPTIONAL) :: oname   !Optional parameter names
CHARACTER(LEN=1024), DIMENSION(NOPTIONAL) :: opara   !Optional parameter strings returned
INTEGER            , DIMENSION(NOPTIONAL) :: loname  !Lenght opt. para name
INTEGER            , DIMENSION(NOPTIONAL) :: lopara  !Lenght opt. para name returned
REAL               , DIMENSION(NOPTIONAL) :: owerte   ! Calculated values
INTEGER, PARAMETER                        :: ncalc = 0 ! Number of values to calculate 
!
LOGICAL, EXTERNAL                     :: str_comp
!
DATA oname  / 'init', 'type' /
DATA loname /  4    ,  4     /
opara  =   (/ 'keep', 'real' /)   ! Always provide fresh default values
lopara =   (/  4    ,  4     /)
owerte =   (/  0.0  ,  0.0   /)
!
CALL get_params (zeile, ianz, cpara, lpara, MAXW, length)
IF(ier_num /= 0) THEN
   RETURN
ENDIF
!
CALL get_optional(ianz, MAXW, cpara, lpara, NOPTIONAL,  ncalc, &
                  oname, loname, opara, lopara, owerte)
linit = .FALSE.
linit =      str_comp(opara(1), 'init',    2, lpara(1), 4)
lreal = .NOT.str_comp(opara(2), 'integer', 3, lpara(2), 7)
!
!
IF(lpara(1)>LEN(pop_name)) THEN
   ier_num = -31
   ier_typ = ER_APPL
   WRITE(ier_msg(1),'(a,i2)') 'Parameter length must be <= ',LEN(pop_name)
   RETURN
ENDIF
pname  = ' '
pname  = cpara(1)(1:MIN(lpara(1),LEN(pname)))
lpname = MIN(lpara(1),LEN(pname))
cpara(1) = '0'
lpara(1) = 1
!DO i = 1, var_num 
!   IF(pname == var_name(i)) THEN
!      ier_num = -29
!      ier_typ = ER_APPL
!      ier_msg(1) = 'The parameter names must be unique. Check'
!      ier_msg(2) = 'with >>''variable show'' for existing names.'
!      RETURN
!   ENDIF
!ENDDO 
CALL ber_params (ianz, cpara, lpara, werte,MAXW)
IF(ier_num /= 0) THEN
   RETURN
ENDIF
IF(.NOT.(werte(2)<=werte(3) .AND. werte(4)<=werte(5) .AND. &
         werte(2)<=werte(4) .AND. werte(4)<=werte(3) )) THEN
   ier_num = -30
   ier_typ = ER_appl
   RETURN
ENDIF
!
INQUIRE(FILE='GENERATION', EXIST=lexist)
IF(pop_gen > 0 .AND. (.NOT. pop_current .AND. lexist) ) THEN
!   pop_current = .FALSE.
   CALL do_read_values(.FALSE.)         ! We need to read values as this can be the first command after a continue
   IF(ier_num /= 0) THEN
      RETURN
   ENDIF
ENDIF
!
!  Check if parameter name exists.
!
par_number = 0
loop_par: DO i=1,pop_dimx
   IF(pname == pop_name(i)) THEN
      par_number = i               ! Name existed, use this entry
      EXIT loop_par
   ENDIF
ENDDO loop_par
IF(par_number==0) THEN                ! Not found, search for names PARA0000
   loop_def: DO i=1,pop_dimx
      WRITE(string,'(a4,i4.4)') 'PARA',i
      IF(pop_name(i) == string .OR.  &
         pop_name(i) == 'PARA0000') THEN
         par_number = i               ! Name existed, use this entry
         EXIT loop_def
      ENDIF
   ENDDO loop_def
ENDIF
!
! Increase dimension by one
!
!IF(pop_dimx_init .OR. pop_dimx==0) THEN   ! If not yet initialized increment 
IF(par_number==0) THEN               ! Name does not exist, make new entry
   pop_dimx = pop_dimx + 1
   par_number = pop_dimx
   IF(pop_dimx  > MAXDIMX) THEN
      CALL alloc_population( MAXPOP, pop_dimx )
      CALL alloc_ref_para(pop_dimx)
      IF(ier_num < 0) THEN
         RETURN
      ENDIF
   ENDIF
   IF ( pop_gen > 0 ) THEN
      CALL patch_para
      pop_dimx_new = .false.
   ELSE
      pop_dimx_new = .false.
   ENDIF
ENDIF
pop_dimx_init = .TRUE.
! Set parameter name
pop_name(par_number)  = pname
pop_lname(par_number) = lpname
!
! Set parameter upper/lower abolute and start windows
!
pop_xmin(par_number) = werte(2)
pop_xmax(par_number) = werte(3)
pop_smin(par_number) = werte(4)
pop_smax(par_number) = werte(5)
pop_sigma(par_number) = 0.001
pop_lsig(par_number)  = 0.0001
IF(lreal) THEN
   pop_type(par_number) = POP_REAL
ELSE
   pop_type(par_number) = POP_INTEGER
ENDIF
!
IF(pop_gen>0) THEN
   CALL write_genfile                ! Write the "GENERATION" file
ENDIF
!
IF(werte(2)==werte(3)) THEN
   pop_refine (par_number) = .FALSE.
ELSE
   pop_refine (par_number) = .TRUE.
ENDIF
!
!  If not in Generation zero, initialize the parameter and 
!  dismiss half the population
!
!  Initialize parameter if:
!    its a new parameter for a Generation  greater zero
!    the user set the optional 'init' flag
!
IF((pop_gen > 0 .AND. par_number == pop_dimx) .OR. linit) THEN
   CALL init_x (par_number, par_number)  ! initialize the new parameter
!
   CALL do_dismiss (pop_n/2, pop_n)  ! dismiss half the population
ENDIF
!
! Enter parameter name into global variable array
!
IF(lreal) THEN
   line = 'real, '//pname
   laenge = 6+lpname
   CALL define_variable(line, laenge, IS_DIFFEV)
ELSE
   line = 'integer, '//pname
   laenge = 9+lpname
   CALL define_variable(line, laenge, IS_DIFFEV)
ENDIF
!
END SUBROUTINE add_param
END MODULE add_param_mod
