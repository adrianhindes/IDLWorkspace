pro show_crosspower,p,ps,z,f,frange=frange,title=title,$
  nolegend=nolegend,$
  refz=zref,plotz=zplot,para_txt=para_txt,nopara=nopara
; Calculate and plot crosspower spectrum from correlations

default,title,''
default,pos,[0.07,0.15,0.7,0.7]                    
default,zref,15
default,zplot,zref
default,para_txt,''

refch=closeind(z,zref)
ind=where(z ne z(refch))
refch1=ind(closeind(z(ind),zref))
pp1=p(refch,*)
pp2=p(refch1,*)
ppa=(zref-z(refch))/(z(refch1)-z(refch))*(pp2-pp1)+pp1

plotch=closeind(z,zplot)
ind=where(z ne z(plotch))
plotch1=ind(closeind(z(ind),zplot))
pp1=p(plotch,*)
pp2=p(plotch1,*)
ppb=(zplot-z(plotch))/(z(plotch1)-z(plotch))*(pp2-pp1)+pp1
pow=ppa*conj(ppb)

erase
if (not keyword_set(nolegend)) then time_legend,'show_crosspower.pro'
if (not keyword_set(nopara)) then begin
  plots,[pos(2)+0.02,pos(2)+0.02],[0.1,0.9],thick=3,/normal
  plotpara='Z!D1!N:'+string(zref,format='(F4.1)')+'!CZ!D2!N:'+$
       string(zplot,format='(F4.1)')
  xyouts,pos(2)+0.04,0.85,para_txt+'!C!C'+plotpara,/normal
endif

yrange=[0,max(pow)*1.05]
default,frange,[min(f),max(f)]  
plot,f,pow,xrange=frange,xstyle=1,xtitle='f [kHz]',$
  yrange=yrange,ystyle=1,ytitle='Power',$
  title=title,/noerase,pos=pos,xticklen=-0.02,yticklen=-0.02
end  
