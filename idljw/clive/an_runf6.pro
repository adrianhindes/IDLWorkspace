@pr_prof2
pro s1
;sh=[10,11,12,13,14,15]+86400L
;r=[230,220,210,200,190,180]

sh=[21,22,23,24,25,26,26]+87700L
r=[260,250,240,230,220,210]
nsm = 1e-3 / 1e-6
idx=sort(r)
sh=sh(idx) & r=r(idx)
rtrue = (r+0*45)+1112
nsh=n_elements(sh)
for i=0,nsh-1 do begin
   dum=getpar(sh(i),'isat',y=y,tw=[0,0.01])
   if i eq 0 then begin
      nt=n_elements(y.t)
      yv=fltarr(nt,nsh)
   endif
   yv(*,i)=smooth(y.v,nsm)
endfor
imgplot,yv,y.t,r,/cb
stop
end
 

pro s2
nsm = 1e-3 / 1e-6
sh=[16,17,18,19,20,21]+86400L
r=[260,250,240,230,235,245]
rtrue=r
idx=sort(r)
sh=sh(idx) & r=r(idx)
rtrue = (r+45)+1112
nsh=n_elements(sh)
for i=0,nsh-1 do begin
   dum=getpar(sh(i),'isatfork',y=y,tw=[0,0.01])
   if i eq 0 then begin
      nt=n_elements(y.t)
      yv=fltarr(nt,nsh)
   endif
   yv(*,i)=smooth(y.v,nsm)
endfor
imgplot,yv,y.t,rtrue
stop
end


pro s2f12
nsm = 1e-3 / 1e-6
sh=[16,17,18,19,20]+87700L;4deg
r=[240,230,220,210,200]
;sh=[48,49,50,53,54]+87700L
;r=[240,230,220,210,200.]; 1deg probe bpp in deg

;sh=[32,33,34,35,36]+87700L
;r=[240,220,200,210,230.]; 4 probe in
;sh=[37,38,39,40,41]+87700L
;r=[220,230,240.]
;sh=[45,46,47]+87700L;3deg
;sh=[60,61,62,63,64]+87700L
;r=[240,230,220,210,200.]; -2deg

;sh=[55,56,57,58,59,68,69,70,71]+87700L ; 0 deg
;r=[200,210,220,230,240,275,265,285,255]
rtrue=r
idx=sort(r)
sh=sh(idx) & r=r(idx)
;rtrue = (r+45)+1112
nsh=n_elements(sh)
for i=0,nsh-1 do begin
   dum=getpar(sh(i),'isatfork',y=y,tw=[0,0.01])
   if i eq 0 then begin
      nt=n_elements(y.t)
      yv=fltarr(nt,nsh)
   endif
   yv(*,i)=smooth(y.v,nsm)
endfor
imgplot,yv,y.t,r
stop
end


