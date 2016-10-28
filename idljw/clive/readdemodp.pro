pro readdemodp,demodid,str
path=getenv('HOME')+'/idl/clive/settings/'
readtextc,path+'demod.csv',data,nskip=0
a0 = (data[0,*])
idx = where( (demodid eq a0),count)
if count eq 0 then begin
  print,'error'
  stop
  return
endif
idx = idx(0) 
arr=reform(data(0:*,idx))

i=0

str={$
demodtype:arr(i++),$
win:{type:arr(i++),$
     sgmul:float(arr(i++)),$
     sgexp:float(arr(i++))},$
filt:{type:arr(i++),$
     sgexp:float(arr(i++)),$
     sgmul:float(arr(i++))},$
  typthres:arr(i++),$
  thres:float(arr(i++)),$
  fracbwx:float(arr(i++)),$
  fracbwy:float(arr(i++)),$
  shape:(arr(i++)),$
  dsmultx:float(arr(i++)),$
  dsmulty:float(arr(i++))}

end

