
pro readmapping,sh,x
;path='/projects/diagnostics/MAST/FIDA/fidaidl/settings/'
path=getenv('HOME')+'/idl/clive/settings/'
readtextc,path+'mapping.csv',data,nskip=1
shl = double(data[0,*])
idx = where( (shl eq double(sh(0))),count)
if count eq 0 then begin
  print,'error'
  stop
  return
endif
idx = idx(0) 
x=double(reform(data(1:14,idx)))

end

