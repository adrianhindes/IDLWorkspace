pro show_ztcorr_3,dens=dens,light=light,refz=refz,trange=trange,title=title,contour=contour,$
    fill=fill,nlev=nlev,zrange=zrange,pluslevels=pluslevels,nosim=nosim,$
		notxt=notxt,nolegend=nolegend,norec=norec,norm=norm,$
    plotrange_light=plotrange_light_in,plotrange_dens=plotrange_dens_in,$
		omit=omit,colorscheme=colorscheme,$
    file_light=lfile,file_dens=dfile,file_sim=simfile
; Plot 3 z-t cross-correlation functions (orig ne, light, reconstr. ne) 
;    relative to refch channel
; /nosim: not simulation data, do not plot original density correlation
; /notxt: do not write comments on plot
; /nolegend: do not plot name of program and time on plot
; /norec: no reconstruction data is available
; /norm: plot normalized crosscorrelation functions
; plotrange_light: range of vertical plot range (color scale) for light
; plotrange_dens: range of vertical plot range (color scale) for density
; omit: a list of time values where the correlations will be omitted

; scale: scale factor for original and reconstructed 
default,trange,[-100,100]
default,title,''
default,fill,1
default,nlev,10
default,zrange,[10,26]
default,refz,16
default, pluslevels,1
default,colorscheme,'blue-white-red'

setcolor,levels=levels,c_colors=c_colors,scheme=colorscheme,/noset																				  
erase
xyouts,0,0,'!5',/normal
if (not keyword_set(nolegend)) then time_legend,'show_ztcorr_3.pro'
pos=!p.position
pos1=[0.05,0.6,0.45,0.95]
pos2=[0.55,0.6,0.95,0.95]
pos3=[0.05,0.08,0.45,0.43]
if (keyword_set(nosim)) then begin
  pos_light=pos1
	pos_rec=pos2
endif else begin
	pos_light=pos2
	pos_orig=pos1
	pos_rec=pos3										 
endelse	


!p.position=pos_light
load_zztcorr,light,k,ks,z,t,omit=omit,file=lfile
if (keyword_set(norm)) then norm_k,k,ks,z,t
if (not keyword_set(norm)) then begin
	refch=closeind(z,refz)
  ind=where(z ne z(refch))
	refch1=ind(closeind(z(ind),refz))
	k1=k(refch,*,*)
	k2=k(refch1,*,*)
  k1=(refz-z(refch))/(z(refch1)-z(refch))*(k2-k1)+k1
	while (max(k1) gt 999) do begin
	  k1=k1/10
		k=k/10
		ks=ks/10
	endwhile	
	 while (max(k1) lt 10) do begin
	  k1=k1*10
	  k = k*10
		ks=ks*10
	endwhile
endif		
show_ztcorr,k,ks,z,t,refz=refz,tit='(b) Light ',zrange=zrange,$
  trange=trange,nlev=nlev,fill=fill,/contour,/noerase,/nolegend,$
	pluslevels=pluslevels,plotrange=plotrange_light_in,colorscheme=colorscheme
tx=trange(1)-(trange(1)-trange(0))/20
nz=(size(z))(1)
xx=fltarr(nz)+tx
yy=z
oplot,xx,yy,psym=1

scale=1
if (not keyword_set(nosim)) then begin
	!p.position=pos_orig
	load_zztcorr,dens,k,ks,z,t,omit=omit,file=simfile
  if (keyword_set(norm)) then norm_k,k,ks,z,t
	refch=closeind(z,refz)
  ind=where(z ne z(refch))
	refch1=ind(closeind(z(ind),refz))
	k1=k(refch,*,*)
	k2=k(refch1,*,*)
  k1=(refz-z(refch))/(z(refch1)-z(refch))*(k2-k1)+k1
	if (not keyword_set(norm)) then begin
	  while (max(k1) gt 999) do begin
		  k1= k1/10
		  k = k/10
			ks=ks/10
			scale=scale*10
		endwhile	
	  while (max(k1) lt 10) do begin
		  k1 = k1*10
		  k = k*10
			ks=ks*10
			scale=float(scale)/10.
		endwhile	
  endif
	show_ztcorr,k,ks,z,t,refz=refz,tit='(a) Original density ',zrange=zrange,$
	  trange=trange,nlev=nlev,fill=fill,/contour,/noerase,/nolegend,$
		pluslevels=pluslevels,plotrange=plotrange_dens_in,colorscheme=colorscheme
	tx=trange(1)-(trange(1)-trange(0))/20
	nz=(size(z))(1)
	xx=fltarr(nz)+tx
	yy=z
	oplot,xx,yy,psym=1
endif	


if (not keyword_set(norec)) then begin
	!p.position=pos_rec
	load_zztcorr,light,k,ks,z,t,/rec,omit=omit,file=dfile
  if (keyword_set(norm)) then norm_k,k,ks,z,t
	if (not keyword_set(norm)) then begin
	  refch=closeind(z,refz)
    ind=where(z ne z(refch))
	  refch1=ind(closeind(z(ind),refz))
	  k1=k(refch,*,*)
	  k2=k(refch1,*,*)
    k1=(refz-z(refch))/(z(refch1)-z(refch))*(k2-k1)+k1
	  if (keyword_set(nosim)) then begin
		  while (max(k1) gt 999) do begin
			  k1 = k1/10
			  k = k/10
				ks=ks/10
			endwhile	
		  while (max(k1) lt 10) do begin
			  k1 = k1*10
			  k = k*10
				ks=ks*10
			endwhile	
		endif else begin
		  k=k/scale
			ks=ks/scale
		endelse
	endif		
	show_ztcorr,k,ks,z,t,refz=refz,tit='(c) Reconstructed density ',zrange=zrange,$
	  trange=trange,nlev=nlev,fill=fill,/contour,/noerase,/nolegend,$
		pluslevels=pluslevels,plotrange=plotrange_dens_in,colorscheme=colorscheme
	tx=trange(1)-(trange(1)-trange(0))/20
	nz=(size(z))(1)
	xx=fltarr(nz)+tx
	yy=z
	oplot,xx,yy,psym=1
endif

if (not keyword_set(notxt)) then begin
  if (not keyword_set(nosim)) then begin
    title=title+'!Cdens='+i2str(dens)+'  light='+i2str(light)
  endif else begin
    title='shot: '+i2str(light)+'!C'+title
  endelse
  if (keyword_set(norm)) then title=title+'!C/norm'
  xyouts,0.55,0.35,/normal,title 																	  
endif


!p.position=pos
end	

