pro lock,lockfile,timelimit

; ******************** lock.pro *****************************
; lock some resource and prevent it from using by two 
; programs at the same time
; <lockfile> is the name of a file which will be used as lock file.
;     see also unlock.pro
; <timelimit> is the limit in sec after any lock will be deleted
; **********************************************************

if ((strupcase(!version.os) eq 'VMS') or $
    (strupcase(!version.os) eq 'WIN32')) then begin
  print,'Warning. LOCK.PRO: Locking resources is possible only on Unix systems!'
  return
endif

default,timelimit,60  

pid=getpid()
machine=getenv('HOST')
fname=lockfile
locked=0
while (not locked) do begin
  canlock=0
  while (not canlock) do begin
    tnow=systime(1)
    openr,unit,fname,/get_lun,error=error
    if (error eq 0) then begin
      print,'Testing lock '+lockfile
      p=long(0)
      m=' '
      t=double(0)
      on_ioerror,err
      !error=0
      readf,unit,m
      readf,unit,p
      readf,unit,t
      close,unit
      free_lun,unit
      if ((tnow-t) gt timelimit) then begin
        canlock=1
        print,'Old lock, removing.'
      endif else begin
        if ((m eq machine) and (pid eq p)) then begin
          ; the same program locked already, which might make problem as nested locks
          ; are not allowed. (The subroutine locking second unlocks when finished and
          ; leaves the resource unlocked for the first caller of lock
          print,'Locking same resource twice! Program error?'
          return
        endif
        print,'Waiting... '+lockfile+' is locked by '+m+'('+i2str(p)+')'+' Lock is '+i2str(tnow-t)+'sec old.'  
      endelse    
err:
      if (!error ne 0) then begin
        canlock=1
      endif      
    endif else begin
      canlock=1  
    endelse
    if (not canlock) then begin
      print,'Waiting for lock '+lockfile 
      wait,1
    endif  
  endwhile
  
  print,'Locking '+lockfile
  openw,unit,fname,/get_lun,error=error
  if (error eq 0) then begin
    printf,unit,machine
    printf,unit,pid
    printf,unit,string(tnow,format='(E)')
    close,unit
    free_lun,unit
    locked=1
  endif 
  t1=systime(1)
  t2=t1
  while ((t2-t1 lt 2) and locked) do begin
    openr,unit,fname,/get_lun,error=error
    if (error eq 0) then begin
      p=long(0)
      m=' '
      t=double(0)
      !error=0
      on_ioerror,err1
      readf,unit,m
      readf,unit,p
      readf,unit,t
      close,unit
      free_lun,unit
    endif else begin
      m=''
    endelse    
    if ((m ne machine) or (p ne pid)) then begin
err1:
      print,'Lock changed! (Collision with another program?)'
      openw,unit,fname,/get_lun,error=error
      if (error eq 0) then begin
      printf,unit,machine
      printf,unit,pid
      printf,unit,string(tnow,format='(E)')
        close,unit
        free_lun,unit
      endif
      locked=0
    endif  
    t2=systime(1)
  endwhile
  if (not locked) then begin
    r=randomu(seed)*10
    wait,r
  endif  
endwhile

on_ioerror,NULL      
    
end  
  
  
  
  
  
  
  
