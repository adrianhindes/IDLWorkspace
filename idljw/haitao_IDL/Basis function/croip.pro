function croip, mv,nv,sita
;modeling of inttegrated profiles with different phases
x=findgen(85)
z=findgen(5)
sensor=200.0*1e-6
f=40.0*1e-3 
signal=make_array(85,5,/float)
croipf=make_array(85,5,16,/float)
for k=0,15 do begin
  sita=k*!pi/8.0
  save,mv,nv,sita,filename='mode number.save'
 
for i=0,84 do begin
  for j=0,4 do begin
    v=-[(x(i)-42.0)*sensor,f,(z(j)-2.0)*sensor]
    ;nv=v/total(v^2)
    ;if i eq 41 and j eq 42 then stop
    sight=cylint(v)
   signal(i,j)=real_part(sight.integral)
    endfor
    endfor
 croipf(*,*,k)=signal
 endfor
return,croipf
 stop
 end