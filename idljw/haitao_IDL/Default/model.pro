pro model

x=findgen(1500)*0.01+0.01
y=findgen(2000)*0.01+0.01
m=1/x^2
arr=make_array(1500.0,2000.0)
for   i=0,1499 do begin
  arr(*,i)=exp(-y/m)
  endfor
  
  
stop
end
