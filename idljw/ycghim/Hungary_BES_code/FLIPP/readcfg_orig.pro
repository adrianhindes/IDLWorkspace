function readcfg,parameter,file=file,integer=ret_integer,double=ret_double,$
         float=ret_float,string=ret_string
;**********************************************************************
;Reads a parameter from a config file. The file should consist of line
; of the following form:
; parameter : value
;
; Returns the parameter value
;
; INPUT
;  parameter: name of parameter as string (exact match is needed)
;  file: name of config file
;  /integer: return value as integer										 |
;  /double: return value as double											 | default is /float
;  /float: return value as float												 |
;  /string: return value as string (rest of line after :)|
;**********************************************************************

if (not(keyword_set(ret_float) or keyword_set(ret_double) or $
        keyword_set(ret_integer) or keyword_set(ret_string)))$
    then ret_float=1

if (not keyword_set(file)) then begin
  print,'No config file is given!'
	print,'Error in READCFG.PRO'
endif
	 
on_ioerror,nofile
openr,l,file,/get_lun
on_ioerror,notfound
parlen=strlen(parameter)
rep:
  a=' '
	readf,l,a
	if (strlen(a) lt parlen) then goto,rep
	p=strmid(a,0,parlen)
	if (p ne parameter) then goto,rep
	slen=strlen(a)
  p=strmid(a,parlen,slen-parlen)
	p=strcompress(p)
	if (strmid(p,0,1) eq ' ') then p=strmid(p,1,strlen(p)-1)
  if (strmid(p,0,1) ne ':') then goto,rep
	p=strmid(p,1,strlen(p)-1)
	if (keyword_set(ret_float)) then return,float(p)
	if (keyword_set(ret_double)) then return,double(p)
	if (keyword_set(ret_integer)) then return,fix(p)
	if (keyword_set(ret_string)) then return,p



nofile:
  print,'Cannot open config file:'+file
	print,'Error in READCFG.PRO'
	stop
	
notfound:
  print,'Cannot find parameter "'+parameter+'" in file:'+file
	print,'Error in READCFG.PRO'
	stop
end
