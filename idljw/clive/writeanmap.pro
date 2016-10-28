
pro writeanmap,sh,x
;path='/projects/diagnostics/MAST/FIDA/fidaidl/settings/'
path=getenv('HOME')+'/idl/clive/settings/'
readtextc,path+',mapping.csv',data,nskip=2
shl = float(data[0,*])
idx = where( (shl eq float(sh)),count)
if count ne 0 then begin
  print,'not writing: shot '+string(sh,format='(I0)')+' is already in ancal.csv. you must edit it to choose which one' ;delete the line manually or label a different shot'
;  return
endif

openw,lun,path+'ancal.csv',/get_lun,/append
printf,lun,[sh,x],format='(15(G0,","),G0)'
close,lun
free_lun,lun
print,'written ',sh
end
