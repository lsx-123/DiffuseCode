!*****7***************************************************************  
!                                                                       
!                                                                       
      SUBROUTINE appl_env 
!-                                                                      
!     Reads environment variables, sets path for helpfile               
!     UNIX version ..                                                   
!+                                                                      
      IMPLICIT none 
!                                                                       
      include'envir.inc' 
      include'prompt.inc' 
!                                                                       
      CHARACTER(255) cdummy
      INTEGER ico, ice, iii
      INTEGER len_str 
      INTEGER pname_l 
!                                                                       
      pname_l = len_str (pname) 
      home_dir = ' ' 
      lines = 42 
      CALL getenv ('LINES', home_dir) 
      IF (home_dir.ne.' ') then 
         READ (home_dir, *, end = 10) lines 
   10    CONTINUE 
      ELSE 
         CALL getenv ('TERMCAP', home_dir) 
         ico = index (home_dir, 'co') + 3 
         ice = index (home_dir (ico:256) , ':') + ico - 2 
         IF (ice.gt.ico) then 
            READ (home_dir (ico:ice), *, end = 20, err = 20) lines 
         ENDIF 
   20    CONTINUE 
      ENDIF 
      lines = lines - 2 
!                                                                       
      home_dir = ' ' 
      CALL getenv ('HOME', home_dir) 
      IF (home_dir.eq.' ') then 
         home_dir = '.' 
      ENDIF 
      home_dir_l = len_str (home_dir) 
!                                                                       
      appl_dir = ' ' 
      CALL getenv (pname_cap, appl_dir) 
      IF (appl_dir.eq.' ') then 
         appl_dir = '.' 
      ENDIF 
!
      CALL getenv ('_', cdummy) 
      iii=index(cdummy,pname,.true.)
      appl_dir=cdummy(1:iii-1)
      appl_dir_l = len_str (appl_dir) 
!                                                                       
      deffile = '.'//pname (1:pname_l) 
      deffile_l = len_str (deffile) 
!                                                                       
      mac_dir = ' ' 
      mac_dir (1:appl_dir_l) = appl_dir 
      mac_dir (appl_dir_l + 1:appl_dir_l + pname_l + 6) = '/mac/'//     &
      pname (1:pname_l) //'/'                                           
      mac_dir_l = len_str (mac_dir) 
!                                                                       
      umac_dir = home_dir(1:home_dir_l)//'/mac/'//pname(1:pname_l) //'/'
      umac_dir_l = len_str (umac_dir) 
!                                                                       
      nullfile = '/dev/null' 
!                                                                       
      hlpfile = ' ' 
      hlpfile (1:appl_dir_l) = appl_dir 
      hlpfile (appl_dir_l + 1:appl_dir_l + 1 + pname_l + 4) = '/'//     &
      pname (1:pname_l) //'.hlp'                                        
      hlpfile_l = len_str (hlpfile) 
!                                                                       
      colorfile = ' ' 
      colorfile (1:appl_dir_l) = appl_dir 
      colorfile (appl_dir_l + 1:appl_dir_l + 10) = '/color.map' 
      colorfile_l = len_str (colorfile) 
!                                                                       
      CALL do_cwd (start_dir, start_dir_l) 
!                                                                       
      WRITE ( *, 1000) umac_dir (1:umac_dir_l) 
      WRITE ( *, 1100) mac_dir (1:mac_dir_l) 
      WRITE ( *, 1200) start_dir (1:start_dir_l) 
!                                                                       
 1000 FORMAT     (1x,'User macros in   : ',a) 
 1100 FORMAT     (1x,'System macros in : ',a) 
 1200 FORMAT     (1x,'Start directory  : ',a) 
      END SUBROUTINE appl_env                       
