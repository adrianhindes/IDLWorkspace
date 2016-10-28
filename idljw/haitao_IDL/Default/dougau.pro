pro dougau
line=486.133
l1=5.0
l2=15.0
temp=double(0.01+findgen(40))
delay=double(findgen(8000))
delay1=abs(l1*1e-3*linbo3(line)/(line*1e-9))
delay2=abs(l2*1e-3*linbo3(line)/(line*1e-9))
rcon1=0.6513
rcon2=0.5643
ratio=findgen(11)*0.1
squ=make_array(11,40,/float)

for j=0,10 do begin
  d=fraction(ratio(j))
for i=0,39 do begin
  c=interpol(d(*,i),delay,delay1)
  c1=interpol(d(*,i),delay,delay2)
  squ(j,i)=(c-rcon1)^2+(c1-rcon2)^2
  endfor
endfor
msqu=min(squ,index)
ind=ARRAY_INDICES(squ, index)
print, ratio(ind(0)),temp(ind(1))
  
stop
end