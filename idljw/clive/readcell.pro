pro readcell,cell,str;path='/projects/diagnostics/MAST/FIDA/fidaidl/settings/'
path=getenv('HOME')+'/idl/clive/settings/'
readtextc,path+'cell.csv',data,nskip=0
celll = (data[0,*])
idx = where( (cell eq celll),count)
if count eq 0 then begin
  print,'error'
  stop
  return
endif
idx = idx(0) 
arr=reform(data(0:*,idx))

i=1

v0=float(arr(i++))
v1=float(arr(i++))
str={$
mountangle:v0,$
celltilt:v1,$
wp1:create_struct(funcreadflcwp(arr(i++)),'angle',float(arr(i++))-v1),$
wp2:create_struct(funcreadflcwp(arr(i++)),'angle',float(arr(i++))-v1),$
wp3:create_struct(funcreadflcwp(arr(i++)),'angle',float(arr(i++))-v1),$
wp4:create_struct(funcreadflcwp(arr(i++)),'angle',float(arr(i++))-v1),$
wp5:create_struct(funcreadflcwp(arr(i++)),'angle',float(arr(i++))-v1),$
wp6:create_struct(funcreadflcwp(arr(i++)),'angle',float(arr(i++))-v1),$
wp7:create_struct(funcreadflcwp(arr(i++)),'angle',float(arr(i++))-v1)}





end

