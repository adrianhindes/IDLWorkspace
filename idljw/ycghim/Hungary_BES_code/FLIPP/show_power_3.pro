pro show_power_3,dens=dens,light=light,zrange=zrange,$
    title=title,nolegend=nolegend,errmult=errmult,nosim=nosim,$
		notxt=notxt,trange=trange
; SHOW_POWER_3.PRO Plots fluctuation power for light, density and reconstruction 
; light: shot number for light
; density: shot number for simulated density (only for simulations)
; zrange: z plot range
; errmult: error multiplication factor used in reconstruction
; /nosim: This is not a simulation (don't plot simulated density)
; trange: time range in correlation function in which the power is calculated
;                   (default: [0,0])
default,title,''
default,zrange,[10,26]
default,errmult,1
default,trange,[0,0]

if (not keyword_set(nosim)) then load_zztcorr,dens,kd,ksd,zd,td
load_zztcorr,light,kl,ksl,zl,tl
ksl=ksl*errmult
load_zztcorr,light,kr,ksr,zr,tr,/rec
z_vect=0
Mn=0
n0=0
z0=0
p0=0
restore,'matrix/'+i2str(light)+'_m_corr.mx'
if (not keyword_set(Mn)) then Mn=calc_mn(M)
MnT=transpose(Mn)
nz=(size(kr))(1)
nzl=(size(zl))(1)
nt=(size(tr))(1)  
krl=dblarr(nzl,nzl,nt)
c=dblarr(nz,nz)
for i=0,nt-1 do begin
  c(*,*)=kr(*,*,i)  
  w=cross2to1(c)
	w=Mn#w
  krl(*,*,i)=cross1to2(w)
endfor
trl=tr
loadxrr,zrl
zrl=zrl(0:nzl-1)
;c=dblarr(nzl,nzl)
;c=krl(*,*,where(tr eq t0))
ksrl=float(0)


erase
if (not keyword_set(nolegend)) then time_legend,'show_power_3.pro'


if (not keyword_set(nosim)) then begin
  tind=where((td ge trange(0)) and (td le trange(1)))
	zvect=zd
	pow=fltarr((size(kd))(1))
	powerr=fltarr((size(ksd))(1))
	for i=0,(size(kd))(1)-1 do begin
	  pow(i)=total(kd(i,i,tind))
		powerr(i)=sqrt(total(ksd(i,i,tind)^2))
	endfor	
	yr=[0,max(pow+powerr)]
	plot,zvect,pow,xrange=zrange,xstyle=1,xtitle='Z [cm]',$
	  yrange=yr,ystyle=1,ytitle='Autopower [a.u.]',/noerase,$
	  title='(a)  Density',$
	  position=[0.05,0.58,0.45,0.93]
	errplot,zvect,pow-powerr,pow+powerr
  tind=where((tr ge trange(0)) and (tr le trange(1)))
	zvect=zr
	pow=fltarr((size(kr))(1))
	for i=0,(size(kr))(1)-1 do begin
	  pow(i)=total(kr(i,i,tind))
	endfor	
	plotsymbol,0
	oplot,zvect,pow,linestyle=2,symsize=0.8,psym=-8
	if ((size(ksr))(0) ne 0) then begin
	  powerr=fltarr((size(kr))(1))
	  for i=0,(size(kr))(1)-1 do begin
		  powerr(i)=sqrt(total(ksr(i,i,tind)^2))
		endfor
		errplot,zvect,pow-powerr,pow+powerr
	endif		
endif else begin
	zvect=zr
  tind=where((tr ge trange(0)) and (tr le trange(1)))
	pow=fltarr((size(kr))(1))
	for i=0,(size(kr))(1)-1 do begin
	  pow(i)=total(kr(i,i,tind))
	endfor	
	if ((size(ksr))(0) ne 0) then begin
	  powerr=fltarr((size(kr))(1))
	  for i=0,(size(kr))(1)-1 do begin
		  powerr(i)=sqrt(total(ksr(i,i,tind)^2))
		endfor
	endif	else begin
	  powerr=0
	endelse		
	yr=[0,max(pow+powerr)]
	plot,zvect,pow,xrange=zrange,xstyle=1,xtitle='Z [cm]',$
	  yrange=yr,ystyle=1,ytitle='Autopower [a.u.]',/noerase,$
	  title='(a)  Density',$
	  position=[0.05,0.58,0.4,0.93]
	if ((size(ksr))(0) ne 0) then begin
		errplot,zvect,pow-powerr,pow+powerr
	endif		
endelse

zvect=zl
tind=where((tl ge trange(0)) and (tl le trange(1)))
pow=fltarr((size(kl))(1))
powerr=fltarr((size(ksl))(1))
for i=0,(size(kl))(1)-1 do begin
  pow(i)=total(kl(i,i,tind))
	powerr(i)=sqrt(total(ksl(i,i,tind)^2))
endfor	
yr=[min(pow-powerr),max(pow+powerr)]
plot,zvect,pow,xrange=zrange,xstyle=1,xtitle='Z [cm]',$
  yrange=yr,ystyle=1,ytitle='Autopower [a.u.]',/noerase,$
  title='(b)  Light',$
  position=[0.6,0.58,0.95,0.93]
errplot,zvect,pow-powerr,pow+powerr	
	
zvect=zl
pow=fltarr((size(krl))(1))
tind=where((trl ge trange(0)) and (trl le trange(1)))
for i=0,(size(krl))(1)-1 do begin
  pow(i)=total(krl(i,i,tind))
endfor	
oplot,zvect,pow,linestyle=2,/noclip

if (not keyword_set(notxt)) then begin
  if (not keyword_set(nosim)) then begin
    title=title+'!Cdensity='+i2str(dens)+'  light='+i2str(light)
  endif else begin
    title=title+'!Clight='+i2str(light)
	endelse
	title=title+'!Ctrange=['+i2str(trange(0))+','+i2str(trange(1))+']'	
	if (errmult ne 1) then title=title+'!CLight error bars are multiplied by '+$
	   string(errmult,format='(F5.2)')
	xyouts,0.2,0.3,title ,/normal
endif

end









