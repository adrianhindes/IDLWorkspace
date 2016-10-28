pro writecell,cell,str;path='/projects/diagnostics/MAST/FIDA/fidaidl/settings/'
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
str={$
mountangle:float(arr(i++)),$
wp1:create_struct(funcreadflcwp(arr(i++)),'angle',float(arr(i++))),$
wp2:create_struct(funcreadflcwp(arr(i++)),'angle',float(arr(i++))),$
wp3:create_struct(funcreadflcwp(arr(i++)),'angle',float(arr(i++))),$
wp4:create_struct(funcreadflcwp(arr(i++)),'angle',float(arr(i++))),$
wp5:create_struct(funcreadflcwp(arr(i++)),'angle',float(arr(i++)))}





end

