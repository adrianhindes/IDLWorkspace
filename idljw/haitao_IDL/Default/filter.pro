function filter, cw

ss=16.0*1e-6 ;sensor size in m
f=50.0*1e-3  ;focal length in m
nf=1.5 ;refrective index of filter material
ia=make_array(512,128,/float) ;inceidence angle
ws=make_array(512,128,/float) ;shifted center wavelength
for i=0,511 do begin
for j=0,127 do begin
ia(i,j)=atan(sqrt(((i-255)*ss)^2+((j-63)*ss*4)^2),f) ;incidence angle
ws(i,j)=cw-cw*(1-sqrt(1-(sin(ia(i,j))/nf)^2))
endfor
endfor
return , ws
end