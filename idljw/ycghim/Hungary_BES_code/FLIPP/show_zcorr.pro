pro show_zcorr,k,ks,z,t,t0=t0,refz=zref,zrange=zrange,$
    title=title,nolegend=nolegend,yrange=yr,over=over,linestyle=linestyle,para_txt=para_txt,$
    nopara=nopara,lcfs=lcfs,axisthick=axisthick,linethick=linethick,charsize=charsize,ztitle=ztitle

default,title,''
default,zrange,[10,26]
default,t0,0
default,linestyle,0
default,zref,15
default,pos,[0.07,0.15,0.7,0.7]
default,para_txt,''
default,linethick,1
default,axisthick,1
default,charsize,1

if (keyword_set(lcfs)) then begin
  if (lcfs gt 30) then lcfs=get_lcfs(lcfs)
endif      

if (not keyword_set(over)) then begin
  erase
  if (not keyword_set(nolegend)) then time_legend,'show_zcorr.pro'
  if (not keyword_set(nopara)) then begin
    plots,[pos(2)+0.02,pos(2)+0.02],[0.1,0.9],thick=3,/normal
    plotpara='Z!D0!N='+string(zref,format='(F4.1)')+'!C!7s!X='+i2str(t0)
    xyouts,pos(2)+0.04,0.85,para_txt+'!C!C'+plotpara,/normal
  endif
endif

refch=closeind(z,zref)+1
ind=where(z ne z(refch-1))
refch1=ind(closeind(z(ind),zref))+1
zvect=z
corr=fltarr((size(k))(1))
corr1=corr
correrr=fltarr((size(ks))(1))
correrr1=correrr
corr(*)=k(refch-1,*,where(t eq t0))
corr1(*)=k(refch1-1,*,where(t eq t0))
correrr(*)=ks(refch-1,*,where(t eq t0))
correrr1(*)=ks(refch1-1,*,where(t eq t0))
corr=(zref-z(refch-1))/(z(refch1-1)-z(refch-1))*(corr1-corr)+corr
correrr=(zref-z(refch-1))/(z(refch1-1)-z(refch-1))*(correrr1-correrr)+correrr

if (not keyword_set(over)) then begin
	default,yr,[min(corr-correrr),max(corr+correrr)]
	plot,zvect,corr,xrange=zrange,xstyle=1,xtitle=ztitle,$
	  yrange=yr,ystyle=1,ytitle='Crosscorr.',/noerase,$
	  title=title,linestyle=linestyle,pos=pos,$
    xthick=axisthick,ythick=axisthick,thick=linethick,charsize=charsize,charthick=axisthick
  w=!p.thick
  !p.thick=linethick
	errplot,zvect,corr-correrr,corr+correrr
  !p.thick=w
endif else begin
	oplot,zvect,corr,linestyle=linestyle,thick=linethick
  w=!p.thick
  !p.thick=linethick
	errplot,zvect,corr-correrr,corr+correrr
  !p.thick=w
endelse	
if (keyword_set(lcfs)) then plots,[lcfs,lcfs],$
       [!y.crange(0),(!y.crange(1)-!y.crange(0))/2+!y.crange(0)],linestyle=2

end
