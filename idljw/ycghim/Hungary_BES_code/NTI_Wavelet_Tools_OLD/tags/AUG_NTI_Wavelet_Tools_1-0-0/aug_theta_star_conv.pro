;+
;
; NAME: aug_theta_star_conv
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2010.07.28.
;
; PURPOSE: Convert geometrical poloidal coordinates with respect to the magnetic axis (theta) to poloidal coordinates
;    in straight filed line geometry (theta^star) in the ASDEX-Upgrade tokamak on a given q surface.
;    Uses az external FORTRAN routine to be found at the AUG AFS!
;
; CALLING SEQUENCE:
;   theta_star=aug_theta_star_conv( shot, time, q, theta, [dianam])
;
; INPUTS:
;   shot: shot numbers
;   time: time-point to serch for in s
;   q: q value of the magnetic surface to do the calculation
;   theta: theta geometrical poloidal angles in degree
;   dianam (optional): equilibrium reconstruction to use: can be 'FPP' for Function parametrization or EQI for cliste; default: 'FPP'
;
; OUTPUTS:
;   theta_star: Straight filed line poloidal coordinates (Returns original angles, if conversion fails!)
;   time: time-point found
;
; EXAMPLE:
;   Compare theta_star values with geometrical theta values in AUG shot at time_orig for a given q:
;   time=time_orig
;   theta=findgen(20)/19.*2.*!PI
;   theta_star=aug_theta_star_conv(shot,time,q,theta)
;   print, time_orig-time
;   plot, theta, theta_star, /tight, xtitle='theta', ytitle='theta_star'
;
;-

function aug_theta_star_conv, shot, time, q, theta, dianam=dianam

; Set defaults
if not(keyword_set(dianam)) then dianam='FPP'

; Set libkk paths
libddww='/usr/ads/lib64/libddww.so'
libkk='/usr/ads/lib64/libkk.so'

; Set libkk parameters
iERR=0L
expnam='AUGD'
nSHOT=long(shot)
nEDIT=0L
tSHOT=float(time)
qval=float(q)
Nangl=long(n_elements(theta))
angle=float(theta)
swrad=0L
Rmag=fltarr(1)
zmag=fltarr(1)
Rn=fltarr(Nangl)
zn=fltarr(Nangl)
tSHf=fltarr(1)
thetsn=fltarr(Nangl)
Brn=fltarr(Nangl)
Bzn=fltarr(Nangl)
Btn=fltarr(Nangl)

; Call libkk routine on AUG AFS
s=call_external(libkk, 'kkidl', 'kkEQqFL',$
                iERR,expnam,dianam,nSHOT,nEDIT,tSHOT,$
                qval,Nangl,angle,swrad,$
                Rmag,zmag,Rn,zn,tSHf,$
                thetsn,Brn,Bzn,Btn)

if (iERR ne 0) then begin 
  print,'Magnetic angle conversion failed!'
  print,'Geometrical angles will be used!'
  return, theta
endif

time=tSHf
theta_star=thetsn
return, theta_star

end
