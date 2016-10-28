pro show_ztcorr,k,ks,z,t,refz=refz,trange=trange,title=title,contour=contour,$
    fill=fill,surface=surface,shade_surf=shade_surf,ax=ax,az=az,nlev=nlev,$
		levels=levels,zrange=zrange,noerase=noerase,nolegend=nolegend,$
    pluslevels=pluslevels,noscale=noscale,plotrange=plotrange,$
    colorscheme=colorscheme,lcfs=lcfs,para_txt=para_txt,nopara=nopara,linethick=linethick,$
    axisthick=axisthick,charsize=charsize,ytitle=ytitle
    
; Plot z-t cross-correlation relative to refch channel
; plotrange: vertical plot range
; lcfs: if value is less than 30, this is the LCFS Z position, otherwise
;       consider this as shot number and get position of LCFS using get_lcfs()

default,trange,[min(t),max(t)]
default,refz,min(z)+3
default,title,''
default,fill,1
if (not keyword_set(surface) and not keyword_set(shade_surf)) then contour=1
default,ax,60
default,az,30
default,nlev,10
default,zrange,[min(z),max(z)]
default,fill,1
default,colorscheme,'blue-white-red'
default,para_txt,''
default,linethick,1
default,axisthick,1
default,charsize,1
default,ytitle,'Z [cm]'

if (keyword_set(lcfs)) then begin
  if (lcfs gt 30) then lcfs=get_lcfs(lcfs)
endif      

k1=fltarr((size(k))(2),(size(k))(3))
k2=k1
refch=closeind(z,refz)
ind=where(z ne z(refch))
refch1=ind(closeind(z(ind),refz))
k1(*,*)=k(refch,*,*)
k2(*,*)=k(refch1,*,*)
k1=(refz-z(refch))/(z(refch1)-z(refch))*(k2-k1)+k1
ind=where((z ge zrange(0)) and (z le zrange(1)))
if (ind(0) ge 0) then k1cut=k1(ind,*)
ind=where((t ge trange(0)) and (t le trange(1)))
if (ind(0) ge 0) then k1cut=k1(*,ind)
pos=!p.position
if (total(pos) eq 0) then pos=[0.07,0.15,0.7,0.7]

default,plotrange,[min(k1cut),max(k1cut)]
if (keyword_set(pluslevels)) then begin
  default,levels,(findgen(nlev))/(nlev)*abs(plotrange(1))
endif else begin
  default,levels,(findgen(nlev))/(nlev)*(plotrange(1)-plotrange(0))+plotrange(0)
endelse	
 
setcolor,levels=levels,c_colors=c_colors,scheme=colorscheme																				  
if (not keyword_set(noerase)) then erase
if (not keyword_set(nolegend)) then time_legend,'show_ztcorr.pro'
if (not keyword_set(nopara)) then begin
  plots,[pos(2)+0.02,pos(2)+0.02],[0.1,0.9],thick=3,/normal
  plotpara='Z!D0!N='+string(refz,format='(F4.1)')
  xyouts,pos(2)+0.04,0.85,para_txt+'!C!C'+plotpara,/normal
endif

;if (!d.name eq 'PS') then begin
;  c_colors=fix((nlev-1-findgen(nlev))/(nlev)*(!d.n_colors-1))
;endif else begin
;  c_colors=fix((findgen(nlev)+1)/(nlev)*(!d.n_colors-1))
;endelse


if (keyword_set(contour)) then begin
		if (keyword_set(fill) and not keyword_set(noscale)) then begin
		  sc=fltarr(2,50)
			scale=findgen(50)/49*(max(k1)-min(k1))+min(k1)
			sc(0,*)=scale
			sc(1,*)=scale
			contour,sc,[0,1],scale,levels=levels,nlev=nlev,/fill,$
			position=[pos(2)-0.03,pos(1),pos(2),pos(3)],$
			xstyle=1,xrange=[0,0.9],ystyle=1,yrange=[plotrange(0),plotrange(1)],xticks=1,$
			xtickname=[' ',' '],/noerase,c_colors=c_colors,charsize=0.7*charsize,xthick=axisthick,$
      ythick=axisthick,thick=linethick,charthick=axisthick
		endif	
  contour,transpose(k1),t,z,xrange=trange,xtitle='Time delay [microsec]',xstyle=1,$
	  yrange=zrange,ytitle=ytitle,ystyle=1,$
    title=title,/noerase,fill=fill,charsize=charsize,xthick=axisthick,ythick=axisthick,thick=linethick,$
    nlev=nlev,levels=levels,ticklen=-0.025,charthick=axisthick,$
		position=pos-[0,0,0.1,0],c_colors=c_colors
    if (keyword_set(lcfs)) then begin
      oplot,trange,[lcfs,lcfs],linestyle=2,thick=2*linethick
      xyouts,trange(0)+(trange(1)-trange(0))*0.02,lcfs+0.1,'LCFS',/data,charsize=charsize,charthick=axisthick
    endif  
endif

if (keyword_set(surface)) then begin
  surface,transpose(k1),t,z,xrange=trange,xtitle='Time delay [microsec]',xstyle=1,$
	  yrange=zrange,ytitle=ytitle,ystyle=1,$
    title=title+'  Z!D0!N='+$
    string(refz,format='(F4.1)'),/noerase,ax=ax,az=az
endif

if (keyword_set(shade_surf)) then begin
  shade_surf,transpose(k1),t,z,xrange=trange,xtitle='Time delay [microsec]',xstyle=1,$
	  yrange=[min(z),max(z)],ytitle=ytitle,ystyle=1,$
    title=title+'  (Z='+$
    string(refz,format='(F4.1)')+')',/noerase,ax=ax,az=az
endif

end
