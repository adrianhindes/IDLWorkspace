pro wave_delay, wave

wavelength=514.514 ;wavelenth in nm
delta_ln=Linbo3(wavelength,kapa=kapa)
kapa_ln=kapa
delta_bbo=bbo(wavelength, kapa=kapa)
kapa_bbo=kapa
l_ln=wave/kapa_ln*wavelength*1e-6/abs(delta_ln);length in mm
l_bbo=wave/kapa_bbo*wavelength*1e-6/abs(delta_bbo);length in mm

m=round(l_ln/0.1)
m1=round(l_bbo/0.1)
d=make_array(m,m1,/float)
l1=findgen(m)*0.1+0.1
l2=findgen(m1)*0.1+0.1
for i=0,m-1 do begin
for j=0,m1-1 do begin
d(i,j)=l1(i)*abs(delta_ln)*kapa_ln/(wavelength*1e-6)+l2(j)*abs(delta_bbo)*kapa_bbo/(wavelength*1e-6)
endfor
endfor
d1=min(abs(d-wave),index)
d2=where(abs(d-wave) eq d1)


stop
end