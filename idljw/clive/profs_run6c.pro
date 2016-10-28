;@pr_prof2
;pro s1
;sh=[10,11,12,13,14,15]+86400L
;r=[230,220,210,200,190,180] & c=0



;sh=[21,22,23,24,25,26,27]+87700L
;r=[260,250,240,230,220,210] &c=-1

;sh=86440+[2,4,5,6,7,8,9]
;r=[205,225,235,255,265,275,285] & c=-1

sh=86440+[2,4,5,7]
r=[205,225,235,265] & c=-1
nsm = 5e-3 /(1/60e3)
idx=sort(r)
sh=sh(idx) & r=r(idx)
rtrue = (r+c*45)+1112
nsh=n_elements(sh)

for i=0,nsh-1 do begin
;   proc_probe,sh(i),filterbw=0,varthres=10.;,filterbw=1e3,varthres=1e9
endfor



for i=0,nsh-1 do begin
;   dum=getpar(sh(i),'tebp',y=y,tw=[0,0.01])
   mdsopen,'anal',sh(i)&y=mdsvalue2('te_sw_f');isatsw')
;   mdsopen,'anal',sh(i)&y=mdsvalue2('isatsw');isatsw')
   if i eq 0 then begin
      nt=n_elements(y.t)-1
      yv=fltarr(nt,nsh)
      t=y.t(0:nt-1)
   endif
   y.v=y.v>0<100
   yv(*,i)=interpol((smooth(y.v,nsm)),y.t(0:n_elements(y.t)-2),t)
endfor


iw=value_locate(y.t, 32.5e-3)
plot, rtrue,yv(iw,*),psym=-4;,yr=[0,40]

iw=value_locate(y.t, 80e-3)
oplot, rtrue,yv(iw,*),psym=-4,col=2

stop
end

 
