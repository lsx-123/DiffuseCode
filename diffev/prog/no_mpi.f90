!*****7***************************************************************
SUBROUTINE RUN_MPI_INIT 
!
! NO MPI Version for standalone
!
USE run_mpi_mod
!
IMPLICIT none
INCLUDE 'errlist.inc'
!
!
run_mpi_myid     = 0
run_mpi_numprocs = 1
ier_num  = 0
ier_typ  = ER_NONE
!
END SUBROUTINE RUN_MPI_INIT
!
!*****7***************************************************************
SUBROUTINE RUN_MPI_MASTER 
!
USE run_mpi_mod
!
IMPLICIT none
INCLUDE 'errlist.inc'
!
ier_num = -21
ier_typ = ER_APPL
!
!
END SUBROUTINE RUN_MPI_MASTER
!
!*****7***************************************************************
SUBROUTINE RUN_MPI_SLAVE
!
USE run_mpi_mod
!
IMPLICIT none
INCLUDE 'errlist.inc'
!
!
ier_num = -21
ier_typ = ER_APPL
!
END SUBROUTINE RUN_MPI_SLAVE
!
!*****7***************************************************************
SUBROUTINE RUN_MPI_FINALIZE
!
IMPLICIT none
!
END SUBROUTINE RUN_MPI_FINALIZE
