pro show_zzcorr,k,ks,z,t,t0,z1range=z1range,z2range=z2range,title=title,$
    contour=contour,fill=fill,surface=surface,shade_surf=shade_surf,ax=ax,$
    az=az,nlev=nlev,levels=levels,noerase=noerase,nolegend=nolegend,$
		pluslevels=pluslevels,noscale=noscale,plotrange=plotrange,$
    colorscheme=colorscheme,t0=t0_keyword,lcfs=lcfs,para_txt=para_txt,$
    nopara=nopara,position=pos,xtitle=xtitle,ytitle=ytitle
		
; Plot z-z cross-correlation at t0 time delay

default,z1range,[min(z),max(z)]
default,z2range,[min(z),max(z)]
default,title,''
default,fill,1
if (not keyword_set(surface) and not keyword_set(shade_surf)) then contour=1
default,ax,60
default,az,30
default,nlev,10
default,colorscheme,'blue-white-red'
default,t0_keyword,t((where(t ge 0))(0))
default,t0,t0_keyword
default,para_txt,''
default,xtitle,'Z [cm]'
default,ytitle,'Z [cm]'

if (keyword_set(lcfs)) then begin
  if (lcfs gt 30) then lcfs=get_lcfs(lcfs)
endif      
																	  
if ((size(where(t eq t0)))(0) eq 0) then begin
  print,'No such time in cross-correlation function:'+i2str(t0)+'!'
	stop
endif
k1=fltarr((size(k))(1),(size(k))(2))
k1(*,*)=k(*,*,where(t eq t0))
																												  
default,plotrange,[min(k1),max(k1)]
if (keyword_set(pluslevels)) then begin
  default,levels,(findgen(nlev))/(nlev+1)*abs(plotrange(1))
endif else begin
  default,levels,(findgen(nlev))/(nlev+1)*(plotrange(1)-plotrange(0))+plotrange(0)
endelse	

if (not defined(pos)) then begin
  pos=!p.position
  if (total(pos) eq 0) then pos=[0.07,0.15,0.7,0.7]
endif

;if (!d.name eq 'PS') then begin
;  c_colors=fix((nlev-1-findgen(nlev))/(nlev)*(!d.n_colors-1))
;endif else begin
;  c_colors=fix((findgen(nlev)+1)/(nlev)*(!d.n_colors-1))
;endelse

setcolor,levels=levels,c_colors=c_colors,scheme=colorscheme																				  
if (not keyword_set(noerase)) then erase
if (not keyword_set(nolegend)) then time_legend,'show_zzcorr.pro'
if (not keyword_set(nopara)) then begin
  plots,[pos(2)+0.02,pos(2)+0.02],[0.1,0.9],thick=3,/normal
  plotpara='!7s!X='+i2str(t0)
  xyouts,pos(2)+0.04,0.85,para_txt+'!C!C'+plotpara,/normal
endif

if (keyword_set(contour)) then begin
		if (keyword_set(fill) and not keyword_set(noscale)) then begin
		  sc=fltarr(2,50)
			scale=findgen(50)/49*(max(k1)-min(k1))+min(k1)
			sc(0,*)=scale
			sc(1,*)=scale
			contour,sc,[0,1],scale,levels=levels,nlev=nlev,/fill,$
			position=[pos(2)-0.03,pos(1),pos(2),pos(3)],$
			xstyle=1,xrange=[0,0.9],ystyle=1,yrange=[min(k1),max(k1)],xticks=1,$
			xtickname=[' ',' '],/noerase,c_colors=c_colors,charsize=0.7
		endif	
  contour,k1,z,z,xrange=z1range,xtitle=xtitle,xstyle=1,$
	  yrange=z2range,ytitle=ytitle,ystyle=1,$
    title=title,/noerase,fill=fill,$
    nlev=nlev,levels=levels,ticklen=-0.025,$
		position=pos-[0,0,0.08,0],c_colors=c_colors
	if (keyword_set(lcfs)) then begin
    oplot,z1range,[lcfs,lcfs],linestyle=2,thick=2	
    xyouts,z1range(0)+(z1range(1)-z1range(0))*0.02,lcfs+0.1,'LCFS',/data
	  oplot,[lcfs,lcfs],z2range,linestyle=2,thick=2
  endif  
endif

if (keyword_set(surface)) then begin
  surface,k1,z,z,xrange=z1range,xtitle=xtitle,xstyle=1,$
	  yrange=z2range,ytitle=ytitle,ystyle=1,$
    title=title+' !7s!X='+i2str(t0),/noerase,ax=ax,az=az
endif

if (keyword_set(shade_surf)) then begin
  shade_surf,k1,z,z,xrange=z1range,xtitle=xtitle,xstyle=1,$
	  yrange=z2range,ytitle=ytitle,ystyle=1,$
    title=title+' !7s!X='+i2str(t0),/noerase,ax=ax,az=az
endif

end







