;@pr_prof2
;pro s1
tlow=30e-3
thigh=80e-3
;sh=[10,11,12,13,14,15]+86400L
;r=[230,220,210,200,190,180] & c=0 & dooplot=1 &multfac=3.5

sh=[21,22,23,24,25,26,27]+87700L
r=[260,250,240,230,220,210] &c=-1 & dooplot=0 & multfac=1

;__ above are the usual 0.73 kh
;sh=87000+[53,54,55,56,57,58]
;r=[216,250,260,270,277,230] & c=-1 & dooplot=0 & multfac=1 & tlow=40e-3
; above is 15kW 0.53 kh


;sh=87000+[59,60,61,62,63,71,72]
;r=[230,215,240,250,260,280,270] & c=-1 & dooplot=0 & multfac=1 & tlow=35e-3 & thigh=15e-3
; above is 15kw, .4-.48


nsm = 10e-3 / 1e-6
idx=sort(r)
sh=sh(idx) & r=r(idx)
rtrue = (r+c*45)+1112
nsh=n_elements(sh)
for i=0,nsh-1 do begin
   dum=getpar(sh(i),'isat',y=y,tw=[0,0.01])
;   dum=getpar(sh(i),'pres',y=y,tw=[0,0.01])
;   mdsopen,'anal',sh(i),y=mdsvalue2('isatsw')
   if i eq 0 then begin
      nt=n_elements(y.t)
      yv=fltarr(nt,nsh)
   endif
   yv(*,i)=smooth(y.v,nsm)*multfac
endfor

iw=value_locate(y.t, tlow)
if dooplot eq 0 then begin
   iw2=value_locate(y.t, thigh)
   mx=max([yv(iw2,*),yv(iw,*)])
   plot, rtrue,yv(iw,*),psym=-4,yr=[0,mx]
endif

if dooplot eq 1 then oplot, rtrue,yv(iw,*),psym=-4

iw=value_locate(y.t, thigh)
oplot, rtrue,yv(iw,*),psym=-4,col=2

stop
end
 
