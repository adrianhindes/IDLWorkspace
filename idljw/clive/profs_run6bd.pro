@read_heliacrout
;@pr_prof2
;pro s1

pro profs_run6bd,pos=pos,noer=noer,xr=xr,dataset=dataset,dodither=dodither,qty=qty,doleg=doleg,doratio=doratio,doder=doder
tlow=30e-3
thigh=10e-3;80e-3
default,doratio,0
if doratio eq 1 then thigh=80e-3;60e-3;80e-3
tdither=[16e-3,24e-3]
default,dataset,0
default,xr,[125,135]
default,qty,'isat'

if dataset eq 0 then begin
sh=[09,10,11,12,13,14,15]+86400L
r=[240,230,220,210,200,190,180] & c=0 & dooplot=0 &multfac=1;3.5
endif

if dataset eq 1 then begin
sh=[21,22,23,24,25,26,27]+87700L
r=[260,250,240,230,220,210] &c=-1 & dooplot=0 & multfac=1
endif
;
;;__ above are the usual 0.73 kh
;sh=87000+[53,54,55,56,57,58]
;r=[216,250,260,270,277,230] & c=-1 & dooplot=0 & multfac=1 & tlow=40e-3
; above is 15kW 0.53 kh


;sh=87000+[59,60,61,62,63,71,72]s
;r=[230,215,240,250,260,280,270] & c=-1 & dooplot=0 & multfac=1 & tlow=35e-3 & thigh=15e-3
; above is 15kw, .4-.48


nsm = 5e-3 / 1e-6
idx=sort(r)
sh=sh(idx) & r=r(idx)
rtrue = (r+c*45)+1112
nsh=n_elements(sh)
for i=0,nsh-1 do begin
   dum=getpar(sh(i),qty,y=y,tw=[0,0.01])
;   dum=getpar(sh(i),'pres',y=y,tw=[0,0.01])
;   mdsopen,'anal',sh(i),y=mdsvalue2('isatsw')
   if i eq 0 then begin
      nt=n_elements(y.t)
      yv=fltarr(nt,nsh)
      yv0=yv
   endif
   yv(*,i)=smooth(y.v,nsm)*multfac
   yv0(*,i)=y.v*multfac
endfor

if keyword_set(doder) then begin
   for i=0,nt-1 do begin
      yv(i,*)=deriv(rtrue/1000.,yv(i,*))/0.5
   endfor
endif

y1=fltarr(nsh)
y2=y1

idx=where(y.t ge tdither(0) and y.t le tdither(1))

for i=0,nsh-1 do begin
   y1(i)=max(yv0(idx,i))
   y2(i)=min(yv0(idx,i))
endfor
;oplot,rtrue,y1,col=4
;oplot,rtrue,y2,col=4

xx=[rtrue,reverse(rtrue)]
yy=[y1,reverse(y2)]
;polyfill,xx,yy,col=4

iw=value_locate(y.t, tlow)
iwh=value_locate(y.t, thigh)

mn=0
if qty eq 'isat' then begin
ytitle=textoidl('I_{sat} (A)')&title=textoidl('I_{sat} profiles')
endif

if qty eq 'tebp' then begin
ytitle=textoidl('T_e (eV)')&title=textoidl('T_e profiles')
mn=-10
endif


if doratio eq 1 then begin
   ratio=yv(iw,*)/yv(iwh,*)
   plot,rtrue/10,ratio,psym=-4,yr=[0,1],pos=pos,noer=noer,xr=xr,xtitle='R (cm)',title=textoidl('Ratio of I_{sat} between low and high states')
return
endif

if dooplot eq 0 then begin
   mx=max([yv(iwh,*),yv(iw,*)])
   if keyword_set(doder) then mn=min([yv(iwh,*),yv(iw,*)])
   plot, rtrue/10,yv(iw,*),psym=-4,yr=[mn,mx*1.2],/nodata,pos=pos,noer=noer,xr=xr,xtitle='R (cm)',ytitle=ytitle,title=title,xsty=1

if keyword_set(dodither) then    polyfill,xx/10,yy,col=4

oplot, rtrue/10,yv(iwh,*),psym=-4,col=2,thick=3

oplot,rtrue/10,yv(iw,*),psym=-4,thick=3

endif



if dooplot eq 1 then oplot, rtrue,yv(iw,*),psym=-4


if keyword_set(doleg) then $
legend,['avg, 27.5-32.5ms','avg, 7.5-12.5ms','dithering, 16-24ms'],col=[1,2,4],linesty=[0,0,0],psym=[-4,-4,0],textcol=[1,2,4],box=0,/right
;stop
end
 
pro fig
xr=[129,136]
mkfig,'~/tex/ishw/profs1.eps',xsize=8,ysize=16,font_size=7
profs_run6bd,qty='isat',pos=posarr(1,4,0,cnx=0.1,fx=0.5),/dodither,/doleg,xr=xr
profs_run6bd,qty='isat',pos=posarr(/next),xr=xr,/noer,/doratio
profs_run6bd,qty='tebp',pos=posarr(/next),xr=xr,/noer
oplot,!x.crange,[0,0],linesty=1
read_heliacrout,what='iota',xr=xr,pos=posarr(/next),/noer
oplot,!x.crange,[1,1]*4./3.,linesty=1
read_heliacrout,what='well',xr=xr,pos=posarr(/curr),/noer,/docur
endfig,/gs,/pn
end
