function zoneint,mv,nv,sita
;modeling of integraed profiles
save,mv,nv,sita,filename='mode number.save'
x=findgen(85)
z=findgen(5)
sensor=200.0*1e-6
f=40.0*1e-3 
comsignal=make_array(85,5,/dcomplex)
for i=0,84 do begin
  for j=0,4 do begin
    v=-[(x(i)-42.0)*sensor,f,(z(j)-2.0)*sensor]
    ;nv=v/total(v^2)
    ;if i eq 41 and j eq 42 then stop
    sight=cylint(v)
    comsignal(i,j)=sight.integral
    endfor
    endfor
return, comsignal
stop 
end