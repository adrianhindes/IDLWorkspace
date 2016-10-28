pro pha_com, x, y, ratio
nw=659.895 ;neon lamp wavelength
deltb_n=bbo(nw,kapa=kapa)
knb=kapa
deltl_n=linbo3(nw,kapa=kapa)  
knl=kapa

r1=0.5
r2=0.5
cs=[[658.60216, r1],[658.65096,r2]] ;cs lamp wavelength
deltb_n=bbo(cs(0,0),kapa=kapa)
ks1b=kapa
deltl_n=linbo3(cs(0,0),kapa=kapa)  
ks1l=kapa

deltb_n=bbo(cs(0,1),kapa=kapa)
ks2b=kapa
deltl_n=linbo3(cs(0,1),kapa=kapa) ;kapa value for each line and phase
ks2l=kapa

cr1=ratio/(ratio+1.0)
cr2=1.0/(ratio+1.0)  ;carbon line ratio from nist database
cl=[[657.805, cr1],[658.288,cr2]]

deltb_n=bbo(cl(0,0),kapa=kapa)
kc1b=kapa
deltl_n=linbo3(cl(0,0),kapa=kapa)  
kc1l=kapa

deltb_n=bbo(cl(0,1),kapa=kapa)
kc2b=kapa
deltl_n=linbo3(cl(0,1),kapa=kapa) ;kapa value for each line and phase
kc2l=kapa

ss=16.0*1e-6 ;sensor size in m
f=85.0*1e-3  ;focal length in m
ia=atan(sqrt(((x-255)*ss)^2+((y-255)*ss)^2),f)
del=atan((x-255)*ss, (y-255)*ss)
cphw1=veiras_eql(cl(0,0),19.5,ia,del-!pi/4+!pi/2,0)*kc1l+veiras_eql(cl(0,0), 7.5,ia,del+!pi/2+!pi/4,0)*kc1l+veiras_eqb(cl(0,0), 1.0,ia,del+!pi/2-!pi/4,0)*kc1b ;phase of carbon lines
cphd1=veiras_eqb(cl(0,0),5.0,ia,del-!pi/4+!pi/2,!pi/4)*kc1b+veiras_eqb(cl(0,0),5.0,ia,del+!pi/4+!pi/2,!pi/4)*kc1b
cphw2=veiras_eql(cl(0,1),19.5,ia,del-!pi/4+!pi/2,0)*kc1l+veiras_eql(cl(0,1), 7.5,ia,del+!pi/2+!pi/4,0)*kc1l+veiras_eqb(cl(0,1), 1.0,ia,del+!pi/2-!pi/4,0)*kc1b
cphd2=veiras_eqb(cl(0,1),5.0,ia,del-!pi/4+!pi/2,!pi/4)*kc1b+veiras_eqb(cl(0,1),5.0,ia,del+!pi/4+!pi/2,!pi/4)*kc1b
cd=dcomplex(cr1*cos(cphw1+cphd1)+cr2*cos(cphw2+cphw2),cr1*cos(cphw1+cphd1)+cr2*cos(cphw2+cphw2))


nphw=veiras_eql(nw,19.5,ia,del-!pi/4+!pi/2,0)*knl+veiras_eql(nw, 7.5,ia,del+!pi/2+!pi/4,0)*knl+veiras_eqb(nw, 1.0,ia,del+!pi/2-!pi/4,0)*knb ;phase of neon lines
nphd=veiras_eqb(nw,5.0,ia,del-!pi/4+!pi/2,!pi/4)*knb+veiras_eqb(nw,5.0,ia,del+!pi/4+!pi/2,!pi/4)*knb
nph=nphd+nphw
nd=dcomplex(cos(nph),sin(nph))
pd=atan(cd/nd,/phase)   ;compensated phase
;return, pd
stop
end


