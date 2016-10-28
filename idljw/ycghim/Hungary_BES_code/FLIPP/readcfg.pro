function readcfg,parameter,file=file,integer=ret_integer,double=ret_double,$
         float=ret_float,string=ret_string,long=ret_long,errormess=errormess
;**********************************************************************
; Reads a parameter from a config file. The file should consist of line
; of the following form:
; parameter : value
;
; Returns the parameter value
; errormess : errormessage :No error errormess=''
; INPUT
;  parameter: name of parameter as string (exact match is needed)
;  file: name of config file
;  /integer: return value as integer	
;  /double: return value as double	| default is /float
;  /float: return value as float	|
;  /string: return value as string (rest of line after :)|
;  /long : return value as long
; OUTPUT:
;  errormess:Error message or ''
;  S. Kalvin 06.08.2013 modification:
;  /long  return value as float
;  errormess: return error message 
;  close file and free lun after call 
;  S. Kalvin 25.04.2013 modification:
;**********************************************************************

errormess =''

if (not(keyword_set(ret_float) or keyword_set(ret_double) or $
        keyword_set(ret_integer) or keyword_set(ret_long) or $
        keyword_set(ret_string)))$
            then ret_float=1

if (not keyword_set(file)) then begin
  print,'No config file is given!'
	print,'Error in READCFG.PRO 1'
  errormess='No config file is given!'
;stop
endif


l=100	 

openr,l,file,/get_lun,error=error
if error ne 0 then begin
  print,'Error in readcfg.pro'
  print,!ERROR_STATE 
  errormess = 'Could not open file:' + file
;stop  
  return,error
endif

on_ioerror,notfound
parlen=strlen(parameter)
rep:
  a=' '
	readf,l,a
;print,'parameter:', parameter
;print,a
	if (strlen(a) lt parlen) then goto,rep
	p=strmid(a,0,parlen)
	if (p ne parameter) then goto,rep
	slen=strlen(a)
        p=strmid(a,parlen,slen-parlen)
	p=strcompress(p)
;print,p
	if (strmid(p,0,1) eq ' ') then p=strmid(p,1,strlen(p)-1)
        if (strmid(p,0,1) ne ':') then goto,rep
	p=strmid(p,1,strlen(p)-1)
	if (keyword_set(ret_float)) then begin
          close,l
          free_lun,l
          return,float(p)
	endif
        if (keyword_set(ret_double)) then begin
          close,l
          free_lun,l
          return,double(p)
	endif
        if (keyword_set(ret_integer)) then begin
          close,l
          free_lun,l
          return,fix(p)
	endif
        if (keyword_set(ret_string)) then begin
          close,l
          free_lun,l
          return,p
        endif
	if (keyword_set(ret_long)) then begin
          close,l
          free_lun,l
          return,long(p)
        endif


nofile:
  print,'Cannot open config file:'+file
  errormess='Cannot open config file:'+file
	print,'Error in READCFG.PRO 2'
	stop
	
notfound:
  print,'Cannot find parameter "'+parameter+'" in file:'+file
  errormess='Cannot find parameter "'+parameter+'" in file:'+file
	print,'Error in READCFG.PRO 3'
;stop

end
