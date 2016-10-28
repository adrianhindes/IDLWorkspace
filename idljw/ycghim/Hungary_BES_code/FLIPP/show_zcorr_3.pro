pro show_zcorr_3,dens=dens,light=light,t0=t0,refz=refz,zrange=zrange,$
    title=title,nolegend=nolegend,errmult=errmult,norm=norm,nosim=nosim,$
		notxt=notxt,norec=norec,y1range=y1range,y2range=y2range,fixscale=fixscale,$
    file_light=lfile,file_dens=dfile,file_sim=simfile,lcfs=lcfs,nopara=nopara,$
    nolock=nolock

default,title,''
default,zrange,[10,26]
default,refz,16
default,t0,0
default,errmult,1
if (keyword_set(notxt)) then nopara=1

if (keyword_set(lcfs)) then begin
  if (lcfs gt 30) then lcfs=get_lcfs(lcfs)
endif      

if (not keyword_set(nosim)) then begin
  load_zztcorr,dens,kd,ksd,zd,td,file=simfile,nolock=nolock,/dens
	ind=where(td eq t0)
	if ((size(ind))(0) eq 0) then begin
	  print,'There is no simulated density correlation data at time '+i2str(t0)
		stop
	endif	
endif	
load_zztcorr,light,kl,ksl,zl,tl,file=lfile,para_txt=lpara,nolock=nolock
ind=where(tl eq t0)
if ((size(ind))(0) eq 0) then begin
  print,'There is no light correlation data at time '+i2str(t0)
	stop
endif	

ksl=ksl*errmult
if (not keyword_set(norec)) then begin
	load_zztcorr,light,kr,ksr,zr,tr,/rec,file=dfile,matrix=matrix,para_txt=dpara,/noscale,nolock=nolock
	ind=where(tr eq t0)
	if ((size(ind))(0) eq 0) then begin
	  print,'There is no reconstructed density  correlation data at time '+i2str(t0)
		stop
	endif	

  SHOT=0
  T=0
  MULTI=0
  ZEFF=0
  M=0
  Z_VECT=0
  N0=0
  Z0=0
  P0=0
  P0R=0
  TE=0
  LIZ=0
  LINE=0
  LIZ_2P=0
  LI2P=0
  LIZ_TE=0
  LITE=0
  TIMEFILE_MX=0
  BACKTIMEFILE_MX=0
  TEMPFILE=0
  CAL=0
  CHANNELS_MX=0
  SMOOTH=0
  PROBE_AMP=0
	restore,'matrix/'+matrix
  if (not keyword_set(Mn)) then Mn=calc_mn(M)
  if ((n_elements(z_vect) ne n_elements(zr)) or $
       (total(where(z_vect ne zr)) ge 0)) then begin
    print,'M matrix is incompatible with reconstructed correlation functions.'
    retall
  endif  
	nz=(size(kr))(1)
	nzl=sqrt((size(Mn))(1))
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
endif

if (keyword_set(norm)) then begin
  norm_k,kl,ksl,zl,tl
  if (not keyword_set(nosim)) then norm_k,kd,ksd,zd,td
  if (not keyword_set(norec)) then begin
	  norm_k,kr,ksr,zr,tr
	  norm_k,krl,ksrl,zrl,trl
  endif
endif	

erase
if (not keyword_set(nolegend)) then time_legend,'show_zcorr_3.pro'

zref=refz

if (not keyword_set(nosim)) then begin
	refch=closeind(zd,zref)+1
  ind=where(zd ne zd(refch-1))
	refch1=ind(closeind(zd(ind),zref))+1
	zvect=zd
	corr=fltarr((size(kd))(1))
	corr1=corr
	correrr=fltarr((size(ksd))(1))
	correrr1=correrr
	corr(*)=kd(refch-1,*,where(td eq t0))
	corr1(*)=kd(refch1-1,*,where(td eq t0))
	correrr(*)=ksd(refch-1,*,where(td eq t0))
	correrr1(*)=ksd(refch1-1,*,where(td eq t0))
	corr=(zref-zd(refch-1))/(zd(refch1-1)-zd(refch-1))*(corr1-corr)+corr
	correrr=(zref-zd(refch-1))/(zd(refch1-1)-zd(refch-1))*(correrr1-correrr)+correrr
	normfact=1.0
  if (not keyword_set(norm) and not keyword_set(fixscale)) then begin
		while (max(corr) gt 99) do begin
		  corr=corr/10.
			correrr=correrr/10.
			normfact=normfact*10.
		endwhile	
		while (max(corr) lt 10) do begin
		  corr=corr*10.
			correrr=correrr*10.
			normfact=normfact/10.
		endwhile	
  endif
	default,y1range,[min(corr-correrr),max(corr+correrr)]
	plot,zvect,corr,xrange=zrange,xstyle=1,xtitle='Z [cm]',$
	  yrange=y1range,ystyle=1,ytitle='Crosscorrelation [a.u.]',/noerase,$
	  title='(a)  Density    Z!D0!N='+string(zref,format='(F4.1)'),$
	  position=[0.07,0.58,0.45,0.93]
	errplot,zvect,corr-correrr,corr+correrr	
  if (keyword_set(lcfs)) then plots,[lcfs,lcfs],[y1range(0),y1range(1)/2],linestyle=2
	
	if (not keyword_set(norec)) then begin	
		zvect=zr
		corr=fltarr((size(kr))(1))
		corr1=corr
		refch=closeind(zr,zref)+ 1
		ind=where(zr ne zr(refch-1))
	  refch1=ind(closeind(zr(ind),zref))+1
		corr(*)=kr(refch-1,*,where(tr eq t0))
		corr1(*)=kr(refch1-1,*,where(tr eq t0))
	  corr=(zref-zr(refch-1))/(zr(refch1-1)-zr(refch-1))*(corr1-corr)+corr
	  corr=corr/normfact
	  plotsymbol,0
		oplot,zvect,corr,line=2,psym=-8,/noclip,symsize=0.8
		if ((size(ksr))(0) ne 0) then begin
  		correrr=fltarr((size(ksr))(1))
		  correrr1=correrr
			correrr(*)=ksr(refch-1,*,where(tr eq t0))
			correrr1(*)=ksr(refch1-1,*,where(tr eq t0))
	    correrr=(zref-zr(refch-1))/(zr(refch1-1)-zr(refch-1))*(correrr1-correrr)+correrr
		  correrr=correrr/normfact
			errplot,zvect,corr-correrr,corr+correrr
		endif
  endif
endif else begin
	zvect=zr
	corr=fltarr((size(kr))(1))
	corr1=corr
	refch=closeind(zr,zref)+ 1
  ind=where(zr ne zr(refch-1))
	refch1=ind(closeind(zr(ind),zref))+1
	corr(*)=kr(refch-1,*,where(tr eq t0))
	corr1(*)=kr(refch1-1,*,where(tr eq t0))
	corr=(zref-zr(refch-1))/(zr(refch1-1)-zr(refch-1))*(corr1-corr)+corr
	if ((size(ksr))(0) ne 0) then begin
  	correrr=fltarr((size(ksr))(1))
	  correrr1=correrr
		correrr(*)=ksr(refch-1,*,where(tr eq t0))
		correrr1(*)=ksr(refch1-1,*,where(tr eq t0))
	  correrr=(zref-zr(refch-1))/(zr(refch1-1)-zr(refch-1))*(correrr1-correrr)+correrr
	endif
	normfact=1.0
  if (not keyword_set(norm) and not keyword_set(fixscale)) then begin
		while (max(abs(corr)) gt 99) do begin
		  corr=corr/10.
			normfact=normfact*10.
		endwhile	
		while (max(abs(corr)) lt 10) do begin
		  corr=corr*10.
			normfact=normfact/10.
		endwhile	
  endif
	correrr=correrr/normfact
	default,y1range,[min(corr-correrr),max(corr+correrr)]
	plotsymbol,0
	plot,zvect,corr,xrange=zrange,xstyle=1,xtitle='Z [cm]',$
	  yrange=y1range,ystyle=1,ytitle='Crosscorrelation [a.u.]',/noerase,$
	  title='(a)  Density    Z!D0!N='+string(zref,format='(F4.1)'),$
	  position=[0.07,0.58,0.45,0.93],psym=-8,symsize=0.8
	if ((size(ksr))(0) ne 0) then begin
		errplot,zvect,corr-correrr,corr+correrr
	endif
  if (keyword_set(lcfs)) then plots,[lcfs,lcfs],[y1range(0),y1range(1)/2],linestyle=2
endelse

zvect=zl
refch=closeind(zl,zref)+1
ind=where(zl ne zl(refch-1))
refch1=ind(closeind(zl(ind),zref))+1
corr=fltarr((size(kl))(1))
corr1=corr
correrr=fltarr((size(ksl))(1))
correrr1=correrr
corr(*)=kl(refch-1,*,where(tl eq t0))
corr1(*)=kl(refch1-1,*,where(tl eq t0))
corr=(zref-zl(refch-1))/(zl(refch1-1)-zl(refch-1))*(corr1-corr)+corr
correrr(*)=ksl(refch-1,*,where(tl eq t0))
correrr1(*)=ksl(refch1-1,*,where(tl eq t0))
correrr=(zref-zl(refch-1))/(zl(refch1-1)-zl(refch-1))*(correrr1-correrr)+correrr
normfact=1.0
if (not keyword_set(norm) and not keyword_set(fixscale)) then begin
	while (max(abs(corr)) gt 99) do begin
	  corr=corr/10.
		correrr=correrr/10.
		normfact=normfact*10.
	endwhile	
	while (max(abs(corr)) lt 10) do begin
	  corr=corr*10.
		correrr=correrr*10.
		normfact=normfact/10.
	endwhile
endif		
default,y2range,[min(corr-correrr),max(corr+correrr)]
plot,zvect,corr,xrange=zrange,xstyle=1,xtitle='Z [cm]',$
  yrange=y2range,ystyle=1,ytitle='Crosscorrelation [a.u.]',/noerase,$
  title='(b)  Light    Z!D0!N='+string(refz,format='(F4.1)'),$
  position=[0.57,0.58,0.95,0.93]
errplot,zvect,corr-correrr,corr+correrr	
if (keyword_set(lcfs)) then plots,[lcfs,lcfs],[y2range(0),y2range(1)/2],linestyle=2
	
if (not keyword_set(norec)) then begin
	zvect=zrl
  refch=closeind(zrl,zref)+1
  ind=where(zrl ne zrl(refch-1))
  refch1=ind(closeind(zrl(ind),zref))+1
	corr=fltarr((size(krl))(1))
	corr1=fltarr((size(krl))(1))
	corr(*)=krl(refch-1,*,where(trl eq t0))
	corr1(*)=krl(refch1-1,*,where(trl eq t0))
  corr=(zref-zrl(refch-1))/(zrl(refch1-1)-zrl(refch-1))*(corr1-corr)+corr
	corr=corr/normfact
	oplot,zvect,corr,linestyle=2
endif		  

if (not keyword_set(nopara)) then begin
    xyouts,0.1,0.45,/norm,dpara
    xyouts,0.55,0.45,/norm,lpara
	txt='!Ct!D0!N='+i2str(t0)
	if (errmult ne 1) then txt=txt+'!CLight error bars are multiplied by '+$
	   string(errmult,format='(F5.2)')
	if (keyword_set(norm)) then txt=txt+'!C/norm'
	xyouts,0.2,0.15,txt ,/normal
endif

end









