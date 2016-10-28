pro show_zzcorr_3,dens=dens,light=light,t0=t0,z1range=z1range,z2range=z2range,$
    title=title,contour=contour,notxt=notxt,nolegend=nolegend,$
    fill=fill,nlev=nlev,pluslevels=pluslevels,nosim=nosim,$
		norec=norec,norm=norm,plotrange_dens=plotrange_dens_in,$
		plotrange_light=plotrange_light_in,colorscheme=colorscheme,$
    file_light=lfile,file_dens=dfile,file_sim=simfile
; Plot 3 z-z cross-correlation functions (orig ne, light, reconstr. ne) 
;   at time delay t0
; /nosim: do not plot original density correlations
; /norec: no reconstruction data is available
; /norm: plot normalized crosscorrelation functions
; plotrange: range of vertical plot range (color scale)

default,z1range,float([10,26])
default,z2range,float([10,26])
default,title,''
default,fill,1
default,nlev,10
default,t0,0
default,pluslevels,1
default,colorscheme,'blue-white-red'
setcolor,levels=levels,c_colors=c_colors,scheme=colorscheme,/noset																				  

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

	
erase
xyouts,0,0,'!5',/normal
if (not keyword_set(nolegend)) then time_legend,'show_zzcorr_3.pro'
pos=!p.position

scale=1
if (not keyword_set(nosim)) then begin
	!p.position=pos_orig
	load_zztcorr,dens,k,ks,z,t,file=simfile,/dens
	if (keyword_set(norm)) then norm_k,k,ks,z,t
	if (not keyword_set(norm)) then begin
	  while (max(k(*,*,where(t eq t0))) gt 999) do begin
		  k = k/10
			ks=ks/10
			scale=scale*10
		endwhile	
	  while (max(k(*,*,where(t eq t0))) lt 10) do begin
		  k = k*10
			ks=ks*10
			scale=float(scale)/10.
		endwhile	
  endif
	show_zzcorr,k,ks,z,t,t0,tit='(a) Original density ',z1range=z1range,$
	  z2range=z2range,nlev=nlev,fill=fill,/contour,/noerase,/nolegend,$
		pluslevels=pluslevels,plotrange=plotrange_dens_in,colorscheme=colorscheme,$
    /nopara
	zx=z1range(1)-(z1range(1)-z1range(0))/20
	nz=(size(z))(1)
	xx=fltarr(nz)+zx
	yy=z
	oplot,xx,yy,psym=1
endif
	
!p.position=pos_light
load_zztcorr,light,k,ks,z,t,file=lfile
if (keyword_set(norm)) then norm_k,k,ks,z,t
if (not keyword_set(norm)) then begin
	while (max(k(*,*,where(t eq t0))) gt 999) do begin
	  k = k/10
		ks=ks/10
	endwhile	
	 while (max(k(*,*,where(t eq t0))) lt 10) do begin
	  k = k*10
		ks=ks*10
	endwhile	
endif
show_zzcorr,k,ks,z,t,t0,tit='(b) Light ',z1range=z1range,$
  z2range=z2range,nlev=nlev,fill=fill,/contour,/noerase,/nolegend,$
	pluslevels=pluslevels,plotrange=plotrange_light_in,colorscheme=colorscheme,$
  /nopara
zx=z1range(1)-(z1range(1)-z1range(0))/20
nz=(size(z))(1)
xx=fltarr(nz)+zx
yy=z
oplot,xx,yy,psym=1

if (not keyword_set(norec)) then begin
	!p.position=pos_rec
	load_zztcorr,light,k,ks,z,t,/rec,file=dfile
	if (keyword_set(norm)) then norm_k,k,ks,z,t
	if (not keyword_set(norm)) then begin
		if (keyword_set(nosim)) then begin
		  while (max(k(*,*,where(t eq t0))) gt 999) do begin
			  k = k/10
				ks=ks/10
			endwhile	
		  while (max(k(*,*,where(t eq t0))) lt 10) do begin
			  k = k*10
				ks=ks*10
			endwhile	
		endif else begin
		  k=k/scale
			ks=ks/scale
		endelse
	endif		
	show_zzcorr,k,ks,z,t,t0,tit='(c) Reconstructed density ',z1range=z1range,$
	  z2range=z2range,nlev=nlev,fill=fill,/contour,/noerase,/nolegend,$
		pluslevels=pluslevels,plotrange=plotrange_dens_in,colorscheme=colorscheme,$
    /nopara
	zx=z1range(1)-(z1range(1)-z1range(0))/20
	nz=(size(z))(1)
	xx=fltarr(nz)+zx
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


