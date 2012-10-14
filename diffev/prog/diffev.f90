PROGRAM diffev 
!                                                                       
USE run_mpi_mod
!                                                                       
IMPLICIT none 
!
!*****7*****************************************************************
!                                                                       
!     Main program for DIFFEV                                           
!                                                                       
!     This is the main program for DIFFEV. It sets up most              
!     variables and calls the loop interpreting the commands.           
!                                                                       
!     Authors : R.B. Neder  (reinhard.neder@mail.uni-erlangen.de)      
!                                                                       
!*****7*****************************************************************
      include'errlist.inc' 
      include'doact.inc' 
      include'learn.inc' 
      include'macro.inc' 
      include'prompt.inc' 
!                                                                       
CHARACTER (LEN=1024)           :: line, zeile 
CHARACTER (LEN=4)              :: befehl 
LOGICAL                        :: lend 
INTEGER                        :: laenge, lp, lbef 
!
INTEGER, PARAMETER             :: master = 0 ! MPI ID of MASTER process
!                                                                       
run_mpi_myid      = 0
lend      = .false. 
blank     = ' ' 
pname     = 'diffev' 
pname_cap = 'DIFFEV' 
prompt            = pname 
prompt_status     = PROMPT_ON 
prompt_status_old = PROMPT_ON 
!
!------ Setting up variables and print start screen                     
!                                                                       
      CALL setup 
!
CALL RUN_MPI_INIT                                    ! Initialize MPI, if present
with_mpi_error: IF ( ier_num == 0 ) THEN             ! No MPI error
   master_slave: IF ( run_mpi_myid == master ) THEN  ! MPI master or stand alone
!                                                                       
      CALL no_error 
!                                                                       
!------ This is the main loop: reading commands ..                      
!                                                                       
      main: DO while (.not.lend) 
         CALL get_cmd (line, laenge, befehl, lbef, zeile, lp, prompt) 
      no_cmd: IF (ier_num.eq.0.and.laenge.gt.0) then 
!                                                                       
!     - If not a comment continue                                       
!                                                                       
            IF (.not. (line (1:1) .eq.'#'.or.line (1:1) .eq.'!') ) then 
!                                                                       
!  - execute command                                                 
!                                                                       
               IF (line (1:3) .eq.'do '.OR.line (1:2) .eq.'if') then 
                  CALL do_loop (line, lend, laenge) 
               ELSE 
                  CALL mache_kdo (line, lend, laenge) 
               ENDIF 
            ENDIF 
         ENDIF no_cmd
!                                                                       
!     - Handle error message                                            
!                                                                       
         IF (ier_num.ne.0) then 
            CALL errlist 
            IF (ier_sta.ne.ER_S_LIVE) then 
               IF (lmakro.and.ier_sta.ne.ER_S_LIVE) then 
                  CALL macro_close 
                  prompt_status = PROMPT_ON 
               ENDIF 
               lblock = .false. 
               CALL no_error 
            ENDIF 
         ENDIF 
      ENDDO main
!                                                                       
       9999 CONTINUE 
!
      CALL do_exit 
!
   ELSE master_slave
      CALL RUN_MPI_SLAVE  ! MPI slave, standalone never
   ENDIF master_slave
ENDIF with_mpi_error
!
CALL RUN_MPI_FINALIZE
!                                                                       
END PROGRAM diffev                            
!*****7*****************************************************************
SUBROUTINE setup 
!                                                                       
!     This routine makes inital setup of DIFFEV                         
!                                                                       
USE allocate_appl
USE blk_appl
USE constraint
USE population
!
IMPLICIT none 
!                                                                       
      include'wink.inc' 
      include'prompt.inc' 
      include'date.inc' 
!                                                                       
fpi = 16.00 * atan (1.00) 
zpi = 8.00 * atan (1.00) 
pi  = 4.00 * atan (1.00) 
rad = zpi / 360.00 
CALL ini_ran (0) 
!                                                                       
!------ Write starting screen                                           
!                                                                       
version   = aktuell 
WRITE ( *, 1000) version, cdate
!
!     Call initial default allocation
!
MAXPOP     = 0
MAXDIMX    = 0
MAX_CONSTR = 0
CALL alloc_appl
!                                                                       
!     Call initialization routine.                                      
!                                                                       
CALL initarrays 
CALL init_sysarrays 
!                                                                       
!     get envirmonment information                                      
!                                                                       
CALL appl_env 
!                                                                       
!     try to read default file                                          
!                                                                       
CALL autodef 
!                                                                       
1000 FORMAT (/,                                                              &
     10x,59('*'),/,                                                          &
     10x,'*',15x,'D I F F E V   Version ',a6,14x,'*',/,                      &
     10x,'*',57(' '),'*',/                                                   &
     10x,'*         Created : ',a35,3x,'*',/,                                &
     10x,'*',57('-'),'*',/,                                                  &
     10x,'* (c) R.B. Neder  ','(reinhard.neder@krist.uni-erlangen.de)  *',/, &
     10x,59('*'),/)                                        
END SUBROUTINE setup                          
