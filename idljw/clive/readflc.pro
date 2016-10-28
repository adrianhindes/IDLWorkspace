pro readflc,flcid,str;path='/projects/diagnostics/MAST/FIDA/fidaidl/settings/'
path=getenv('HOME')+'/idl/clive/settings/'
readtextc,path+'flc.csv',data,nskip=0
a0 = (data[0,*])
idx = where( (flcid eq a0),count)
if count eq 0 then begin
  print,'error'
  stop
  return
endif
idx = idx(0) 
arr=reform(data(0:*,idx))

i=1
str={$
type:'flc',$
id:flcid,$
delaydeg:float(arr(i++)),$
switchangle:float(arr(i++)),$
sourceid:fix(arr(i++))}




end

