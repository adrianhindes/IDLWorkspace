function getpid
; ****************** getpid.pro *********************************
; Returns the process ID of the IDL program on a Unix machine
; Needs a compiled copy of the following C program
;
;    #include <unistd.h>
;    
;    main()
;    {
;    printf("%d\n",getppid());
;    }
;
;  The compiled program name should be getppid_<host>, where <host>
;   is the string returned by the getenv('HOST') IDL function.
; 
       
error_no=0

restart:
                  
on_ioerror,error
progname='getppid_'+getenv('HOST')
spawn,'./'+progname,unit=unit,/noshell
pid=long(0)
readf,unit,pid
close,unit
free_lun,unit
return,pid


error:
if (error_no ne 0) then begin
  print,'Cannot create program '+progname
  print,'Please read instructions in file getpid.pro'
  stop
endif
error_no = 1  
print,'Cannot run program to determine process ID.'
print,'Trying to create program.'
openw,unit,progname+'.c',/get_lun
printf,unit,'#include <unistd.h>'
printf,unit,'main()'
printf,unit,'{'
printf,unit,'printf("%d\n",getppid());'
printf,unit,'}'
close,unit & free_lun,unit
spawn,'cc -o '+progname+' '+progname+'.c'
goto,restart

end
