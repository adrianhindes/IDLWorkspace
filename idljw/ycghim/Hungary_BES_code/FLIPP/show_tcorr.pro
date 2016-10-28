pro show_tcorr,k,ksin,z,t,trange=trange,title=title,help=help,$
  nolegend=nolegend,over=over,noerr=noerr,linestyle=linestyle,$
  fulltitle=fulltitle,refz=zref,plotz=zplot,para_txt=para_txt,nopara=nopara,$
  yrange=yrange,axisthick=axisthick,linethick=linethick,charsize=charsize
; Plot cross-correlation of two channels  vs. time

if (not keyword_set(k)) then help=1
		 
if (keyword_set(help)) then begin
  print,'Usage: showtcorr,k,ks,z,t,ch1,ch2 [,trange=trange] [,title=title] $'
  print,'              [,/over] [,/nolegend] [,/noerr] [,linestyle=linestyle]'
	print,'  Plots cross-correlation function with errors as a function of t'																																  
  print,'  Use load_zztcorr to load k,ks,z,t'
	return
endif	

default,trange,[min(t),max(t)]
default,title,''
default,linestyle,0
default,pos,[0.07,0.15,0.7,0.7]
default,zref,15
default,zplot,zref
default,para_txt,''
default,linethick,1
default,axisthick,1
default,charsize,1

if (keyword_set(noerr)) then ks=k*0 else ks=ksin

;if (!d.name ne 'X') then begin
;  font=!p.font
;	!p.font=0
;endif	

	refch=closeind(z,zref)
  ind=where(z ne z(refch))
	refch1=ind(closeind(z(ind),zref))
	plotch=closeind(z,zplot)
  ind=where(z ne z(plotch))
	plotch1=ind(closeind(z(ind),zref))
	tvect=t
	corr=fltarr((size(k))(3))
	corr1=corr
	corr2=corr
	corr3=corr
	corr(*)=k(refch,plotch,*)
	corr1(*)=k(refch1,plotch,*)
	corr2(*)=k(refch,plotch1,*)
	corr3(*)=k(refch1,plotch1,*)
	corra=(zref-z(refch))/(z(refch1)-z(refch))*(corr1-corr)+corr
	corrb=(zref-z(refch))/(z(refch1)-z(refch))*(corr3-corr2)+corr2
	corr=(zplot-z(plotch))/(z(plotch1)-z(plotch))*(corrb-corra)+corra
	
	correrr=fltarr((size(ks))(3))
	correrr1=correrr
	correrr2=correrr
	correrr3=correrr
	correrr(*)=ks(refch,plotch,*)
	correrr1(*)=ks(refch1,plotch,*)
	correrr2(*)=ks(refch,plotch1,*)
	correrr3(*)=ks(refch1,plotch1,*)
	correrra=(zref-z(refch))/(z(refch1)-z(refch))*(correrr1-correrr)+correrr
	correrrb=(zref-z(refch))/(z(refch1)-z(refch))*(correrr3-correrr2)+correrr2
	correrr=(zplot-z(plotch))/(z(plotch1)-z(plotch))*(correrrb-correrra)+correrra


if (not keyword_set(over)) then begin
  erase
  if (not keyword_set(nolegend)) then time_legend,'show_tcorr.pro'
  if (not keyword_set(nopara)) then begin
    plots,[pos(2)+0.02,pos(2)+0.02],[0.1,0.9],thick=3,/normal
    plotpara='Z!D1!N:'+string(zref,format='(F4.1)')+'!CZ!D2!N:'+$
         string(zplot,format='(F4.1)')
    xyouts,pos(2)+0.04,0.85,para_txt+'!C!C'+plotpara,/normal
  endif
endif

default,fulltitle,title

default,yrange,[min(corr-correrr),max(corr+correrr)]
if (not keyword_set(over)) then begin
  plot,tvect,corr,xrange=trange,xstyle=1,xtitle='Time delay [microsec]',$
    yrange=yrange,ystyle=1,ytitle='Correlation',$
    title=fulltitle,/noerase,linestyle=linestyle,pos=pos,$
    xthick=axisthick,ythick=axisthick,thick=linethick,charsize=charsize,charthick=axisthick
	if (not keyword_set(noerr) and keyword_set(ks)) then begin
    w=!p.thick
    !p.thick=linethick
    errplot,tvect,corr-correrr,corr+correrr
    !p.thick=w
  endif
endif else begin
  oplot,tvect,corr,linestyle=linestyle,thick=linethick
	if (not keyword_set(noerr) and keyword_set(ks)) then begin
    w=!p.thick
    !p.thick=linethick
    errplot,tvect,corr-correrr,corr+correrr 
    !p.thick=w
  endif
endelse
	
;if (!d.name ne 'X') then begin
;  !p.font=font
;endif	
end  
