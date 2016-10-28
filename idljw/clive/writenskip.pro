
pro writenskip,sh,x,db=db
;path='/projects/diagnostics/MAST/FIDA/fidaidl/settings/'
path='~/idl/clive/settings/'
readtextc,path+'log_nskip.csv',data,nskip=2
shl = float(data[0,*])
dbb=data[1,*]
idx = where( (shl eq float(sh) and (db eq dbb)),count)
if count ne 0 then begin
  print,'not writing: shot '+string(sh,format='(I0)')+' is already in ancal.csv. you must edit it to choose which one' ;delete the line manually or label a different shot'

;  return
endif

openw,lun,path+'log_nskip.csv',/get_lun,/append
printf,lun,sh,db,x,format='(1(G0,","),A,",",G0)'
close,lun
free_lun,lun
print,'written ',sh
end
