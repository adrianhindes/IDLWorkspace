
;function waveplatel_gel, wavelength,wl,wr,f,sz,xs,ys
;default,xs,512
;default,ys,512
;alpha=make_array(xs,ys,/double)
;del=make_array(xs,ys,/double)
;phase_shift=make_array(xs,ys,/double) ;delay thickness in mm
;;wavelength=532.0 ; wavelength in nm
;delta_n1=linbo3(wavelength, n_e=n_e,n_o=n_o)
;;delta_n2=bbo(wavelength, n_e=n_e,n_o=n_o)
;term1=make_array(xs,ys,/double)
;term2=make_array(xs,ys,/double)
;term3=make_array(xs,ys,/double)
;simulation=make_array(xs,ys,/double)
;sita=0
;sensor=sz;sensor size in m
;fl=f ;focal length in mm
;for i=0,xs-1 do begin
;  for j=0,ys-1 do begin
;  del(i,j)=atan(i-(xs/2.0)*sensor*512.0/xs,(j-ys/2.0)*512.0/ys*sensor)+wr+!pi/2
;  alpha(i,j)=atan(sqrt(((i-xs/2.0)*sensor*512./xs)^2+((j-ys/2.0)*sensor*512./ys)^2),fl*1e-3)
;  term1(i,j)=sqrt(n_o^2-sin(alpha(i,j))^2)
;  term2(i,j)=(n_o^2-n_e^2)*sin(sita)*cos(sita)*cos(del(i,j))*sin(alpha(i,j))/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)
;  term3(i,j)=(-n_o)/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)*sqrt(n_e^2*(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)-(n_e^2-(n_e^2-n_o^2)*cos(sita)^2*sin(del(i,j))^2)*sin(alpha(i,j))^2)
;  phase_shift(i,j)=2*!pi*wl*1e-3/(wavelength*1e-9)*(term1(i,j)+term2(i,j)+term3(i,j))
;  simulation(i,j)=cos(phase_shift(i,j))
;endfor
;endfor
;return , phase_shift
;end
function waveplatel_gel, wavelength,wl,wr,f,sz,xs,ys
default,xs,512
default,ys,512
alpha=make_array(xs,ys,/double)
del=make_array(xs,ys,/double)
phase_shift=make_array(xs,ys,/double) ;delay thickness in mm
;wavelength=532.0 ; wavelength in nm
delta_n1=linbo3(wavelength, n_e=n_e,n_o=n_o)
;delta_n2=bbo(wavelength, n_e=n_e,n_o=n_o)
term1=make_array(xs,ys,/double)
term2=make_array(xs,ys,/double)
term3=make_array(xs,ys,/double)
simulation=make_array(xs,ys,/double)
sita=0
sensor=sz ;sensor size in m
fl=f ;focal length
for i=0,xs-1 do begin
  for j=0,ys-1 do begin
  del(i,j)=atan((i-xs/2.0)*sensor*512.0/xs, (j-ys/2.0)*512.0/ys*sensor)+wr+!pi/2
  alpha(i,j)=atan(sqrt(((i-xs/2.0)*sensor*512.0/xs)^2+((j-ys/2.0)*sensor*512.0/ys)^2),fl*1e-3)
  term1(i,j)=sqrt(n_o^2-sin(alpha(i,j))^2)
  term2(i,j)=(n_o^2-n_e^2)*sin(sita)*cos(sita)*cos(del(i,j))*sin(alpha(i,j))/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)
  term3(i,j)=(-n_o)/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)*sqrt(n_e^2*(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)-(n_e^2-(n_e^2-n_o^2)*cos(sita)^2*sin(del(i,j))^2)*sin(alpha(i,j))^2)
  phase_shift(i,j)=2*!pi*wl*1e-3/(wavelength*1e-9)*(term1(i,j)+term2(i,j)+term3(i,j))
  simulation(i,j)=cos(phase_shift(i,j))
endfor
endfor
return , phase_shift
end

function waveplateb_gel, wavelength,wl,wr,f,sz,xs,ys
default,xs,512
default,ys,512
alpha=make_array(xs,ys,/double)
del=make_array(xs,ys,/double)
phase_shift=make_array(xs,ys,/double) ;delay thickness in mm
;wavelength=532.0 ; wavelength in nm
;delta_n1=linbo3(wavelength, n_e=n_e,n_o=n_o)
delta_n2=bbo(wavelength, n_e=n_e,n_o=n_o)
term1=make_array(xs,ys,/double)
term2=make_array(xs,ys,/double)
term3=make_array(xs,ys,/double)
simulation=make_array(xs,ys,/double)
sita=0
sensor=sz ;sensor size in m
fl=f ;focal length
for i=0,xs-1 do begin
  for j=0,ys-1 do begin
  del(i,j)=atan((i-xs/2.0)*sensor*512.0/xs, (j-ys/2.0)*512.0/ys*sensor)+wr+!pi/2
  alpha(i,j)=atan(sqrt(((i-xs/2.0)*sensor*512.0/xs)^2+((j-ys/2.0)*sensor*512.0/ys)^2),fl*1e-3)
  term1(i,j)=sqrt(n_o^2-sin(alpha(i,j))^2)
  term2(i,j)=(n_o^2-n_e^2)*sin(sita)*cos(sita)*cos(del(i,j))*sin(alpha(i,j))/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)
  term3(i,j)=(-n_o)/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)*sqrt(n_e^2*(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)-(n_e^2-(n_e^2-n_o^2)*cos(sita)^2*sin(del(i,j))^2)*sin(alpha(i,j))^2)
  phase_shift(i,j)=2*!pi*wl*1e-3/(wavelength*1e-9)*(term1(i,j)+term2(i,j)+term3(i,j))
  simulation(i,j)=cos(phase_shift(i,j))
endfor
endfor
return , phase_shift
end

;displacer bbo
function displacer_gel, wavelength,dl ,dr,f,sz,xs,ys
default,xs,512
default,ys,512
alpha=make_array(xs,ys,/double)
del=make_array(xs,ys,/double)
phase_shift=make_array(xs,ys,/double)
;wavelength=532.0 ; wavelength in nm
;delta_n1=linbo3(wavelength, n_e=n_e,n_o=n_o)
delta_n2=bbo(wavelength, n_e=n_e,n_o=n_o)
term1=make_array(xs,ys,/double)
term2=make_array(xs,ys,/double)
term3=make_array(xs,ys,/double)
simulation=make_array(xs,ys,/double)
sita=!pi/4
sensor=sz ;sensor size in m
fl=f ;focal length
for i=0,xs-1 do begin
  for j=0,ys-1 do begin
  del(i,j)=atan((i-xs/2.0)*sensor*512.0/xs, (j-ys/2.0)*512.0/ys*sensor)+dr+!pi/2
  alpha(i,j)=atan(sqrt(((i-xs/2.0)*sensor*512.0/xs)^2+((j-ys/2.0)*sensor*512.0/ys)^2),fl*1e-3)
  term1(i,j)=sqrt(n_o^2-sin(alpha(i,j))^2)
  term2(i,j)=(n_o^2-n_e^2)*sin(sita)*cos(sita)*cos(del(i,j))*sin(alpha(i,j))/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)
  term3(i,j)=(-n_o)/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)*sqrt(n_e^2*(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)-(n_e^2-(n_e^2-n_o^2)*cos(sita)^2*sin(del(i,j))^2)*sin(alpha(i,j))^2)
  phase_shift(i,j)=2*!pi*dl*1e-3/(wavelength*1e-9)*(term1(i,j)+term2(i,j)+term3(i,j))
  simulation(i,j)=cos(phase_shift(i,j))
endfor
endfor
return,phase_shift
end