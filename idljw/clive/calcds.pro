echarge=1.6e-19
mi=6*1.67262158e-27;carbon
clight=3e8


ti = 1000. ; ev

vth=sqrt(2*echarge*ti/mi)

print,'vth=',vth

vel=50e3 ; 50km/s

print,'mach #=',vel/vth

kappa=1.06

vthc=vth/clight
nchar = 1/vthc/sqrt(!pi*kappa)

ds = nchar * kappa * vel / clight

print, 'doppler shift is',ds,'waves or',ds*2*!pi,'radians'


;v and vth in units of c
;phase shift in waves is n kappa v

; contrast exp(-(pi kappa N)^2 * vth^2)
end
