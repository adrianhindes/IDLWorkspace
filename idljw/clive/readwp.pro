pro readwp,wpid,str;path='/projects/diagnostics/MAST/FIDA/fidaidl/settings/'
path=getenv('HOME')+'/idl/clive/settings/'
readtextc,path+'wp.csv',data,nskip=0
a0 = (data[0,*])
idx = where( (wpid eq a0),count)
if count eq 0 then begin
  print,'error'
  stop
  return
endif
idx = idx(0) 
arr=reform(data(0:*,idx))

i=1
str={$
type:'wp',$
id:wpid,$
material:(arr(i++)),$
thicknessmm:float(arr(i++)),$
facetilt:float(arr(i++))}




end

