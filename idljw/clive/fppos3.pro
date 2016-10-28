;% Fork probe position
;% determine position (r,z,rho)
;% when the long probe on angle (theta) and distance (D)
;% 
;% WORKS ON MATLAB 2013/2014: ON LAPTOP, NOT SERVER


;%function [r2,z2,rho22,phi22]=fppos_extra6(Dm,theta)
pro fppos3, d, theta, r, z,direction=direction,old=old
default,direction,1
if keyword_set(old) then new=0 else new=1

rp = 3812/2. + 135. ;pivot
lf=650-135.;flange to pivot

ls = 1237+280 ; length of probe from tip to marker
if (new eq 1) then ls = ls - 10; 270 is new probe length




zp=75.
;phi=7.2*!dtor

ps=25. ; probe separation of fork
pp=ps/2.

if direction eq 1 then begin
   lp = ls-lf-d
   r = rp - lp * cos(theta*!dtor)   ;  +pp * sin(theta*!dtor)
   z = zp + lp * sin(theta*!dtor) +pp;  * cos(theta*!dtor)
endif
if direction eq -1 then begin
   dx=rp-r
   dy=z-zp-pp
   lp = sqrt(dx^2+dy^2)
   d = ls - lp - lf
   theta = atan(dy,dx)*!radeg
endif



end

