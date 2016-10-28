
pro readancal,sh,x
;path='/projects/diagnostics/MAST/FIDA/fidaidl/settings/'
path='~/idl/clive/settings/'
readtextc,path+'ancal.csv',data,nskip=2
shl = float(data[0,*])
idx = where( (shl eq float(sh)),count)
if count eq 0 then begin
  print,'error'
  stop
  return
endif
idx = idx(0) 
x=float(reform(data(1:6,idx)))

end

