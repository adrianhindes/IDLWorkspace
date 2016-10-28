pro show_kstar_2dcorr,savefile=savefile,tau=tau,plotrange=plotrange,waittime=waittime,thick=thick,$
   mpeg_filename=mpeg_filename,nlev=nlev,colorscheme=colorscheme,rrange=rrange,zrange=zrange
   
default,tau,0
default,colorscheme,'blue-white-red'
default,nlev,60
default,charsize,1
default,thick,1
linethick=thick
axisthick=thick
default,waittime,1
;device, decomposed=0
;loadct,5
contour = 1
fill = 1
pos = [0.15,0.15,0.85,0.9]

restore,dir_f_name('tmp',savefile)
cal = getcal_kstar_spat(shot,errormess=errormess)
if (errormess ne '') then begin
  print,errormess
  return
endif
;rcoords = transpose(total(cal[*,*,*,0],3)/4/10)
;zcoords = transpose(total(cal[*,*,*,1],3)/4/10)

rcoords= transpose(cal[*,*,0]/10)
zcoords= transpose(cal[*,*,1]/10)

if (defined(mpeg_filename)) then begin
  mpeg_id=mpeg_open([!d.x_vsize,!d.y_vsize],filename=mpeg_filename,quality=100)
endif

for i=0,n_elements(tau)-1 do begin

tauind = closeind(tauscale,tau[i])
corr = transpose(reform(c_matrix[*,*,tauind]))

default,plotrange,[min(corr),max(corr)]
if (keyword_set(pluslevels)) then begin
  default,levels,(findgen(nlev))/(nlev)*abs(plotrange(1))
endif else begin
  default,levels,(findgen(nlev))/(nlev)*(plotrange(1)-plotrange(0))+plotrange(0)
endelse
setcolor,levels=levels,c_colors=c_colors,scheme=colorscheme

default,rrange,[min(rcoords),max(rcoords)]
default,zrange,[min(zcoords),max(zcoords)]

erase
if (keyword_set(contour)) then begin
  if (keyword_set(fill) and not keyword_set(noscale)) then begin
    sc=fltarr(2,50)
    scale=findgen(50)/49*(max(corr)-min(corr))+min(corr)
    sc(0,*)=scale
    sc(1,*)=scale
    contour,sc,[0,1],scale,levels=levels,nlev=nlev,/fill,$
      position=[pos(2)-0.03,pos(1),pos(2),pos(3)],$
      xstyle=1,xrange=[0,0.9],ystyle=1,yrange=[plotrange(0),plotrange(1)],xticks=1,$
      xtickname=[' ',' '],/noerase,c_colors=c_colors,charsize=0.7*charsize,xthick=axisthick,$
      ythick=axisthick,thick=linethick,charthick=axisthick
  endif
  x=indgen(8)+1
  y=indgen(4)+1
  contour,corr,rcoords,zcoords,xrange=rrange,xtitle='BES radial channel',xstyle=1,$
      yrange=zrange,ytitle='BES poloidal channel',ystyle=1,title='tau='+string(tauscale[tauind],format='(F5.1)'),/noerase,fill=fill,$
      charsize=charsize,xthick=axisthick,ythick=axisthick,thick=linethick,$
      nlev=nlev,levels=levels,ticklen=-0.025,charthick=axisthick,$
       position=pos-[0,0,0.1,0],c_colors=c_colors,/isotropic
  if (defined(mpeg_filename)) then begin
    im = tvrd(/order,true=1)
    mpeg_put,mpeg_id,window=!d.window,/order,frame=i
  endif
  if (i ne n_elements(tau)-1) then wait,waittime
endif
endfor
if (defined(mpeg_filename)) then begin
  mpeg_save,mpeg_id,filename=mpeg_filename
  mpeg_close,mpeg_id
endif

end