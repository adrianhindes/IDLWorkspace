pro show_power,k,ks,z,t,z0,n0,trange=trange,zrange=zrange,$
    title=title,nolegend=nolegend,yrange=yr,over=over,linestyle=linestyle,para_txt=para_txt,$
    nopara=nopara,lcfs=lcfs,noerror=noerror,color=color,relative=relative,ELM=ELM

default,title,''
default,zrange,[10,26]
default,trange,[0,0]
default,linestyle,0
default,zref,15
default,pos,[0.07,0.15,0.7,0.7]
default,para_txt,''

if (keyword_set(relative)) then noerror=1

if (keyword_set(lcfs)) then begin
  if (lcfs gt 30) then lcfs=get_lcfs(lcfs)
endif      

if (not keyword_set(over)) then begin
  erase
  if (not keyword_set(nolegend)) then time_legend,'show_zcorr.pro'
  if (not keyword_set(nopara)) then begin
    plots,[pos(2)+0.02,pos(2)+0.02],[0.1,0.9],thick=3,/normal
    plotpara='!7s!X range: ['+i2str(trange(0))+','+i2str(trange(1))+']'
    xyouts,pos(2)+0.04,0.85,para_txt+'!C!C'+plotpara,/normal
  endif
endif

ind=where((t ge trange(0)) and (t le trange(1)))
if (ind(0) lt 0) then begin
  print,'SHOW_POWER.PRO: No time found in given time range.'
  return
endif
np=(size(z))(1)
p=fltarr(np)
pe=fltarr(np)
for i=0,np-1 do begin
  p(i)=total(k(i,i,ind))
  pe(i)=sqrt(total(ks(i,i,ind)^2))
endfor
if (keyword_set(ELM)) then begin
  nnn=n_elements(ind)
  p=p/nnn
  pe=pe/nnn
  iii=where(abs(p) lt pe)
  if (iii(0) ge 0) then begin
    p(iii)=0
    pe(iii)=0
  endif  
endif
if (keyword_set(relative)) then begin
  if (not keyword_set(z0) or not keyword_set(n0)) then begin
    print,'No density profile is given, cannot calculate relative fluctuation profile.'
    return
  endif 
  n0i=xy_interpol(z0,n0,z)/1e13
  p=sqrt(p)/n0i
  ytit='Rel. fluctuation amplitude [a.u.]'
endif else begin
  ytit='Autopower [a.u.]'
endelse  
if (keyword_set(ELM)) then ytit='Autocorrelation'   
  
if (not keyword_set(over)) then begin
	default,yr,[0,max(p+pe)]
	plot,z,p,xrange=zrange,xstyle=1,xtitle='Z [cm]',$
	  yrange=yr,ystyle=1,ytitle=ytit,/noerase,$
	  title=title,linestyle=linestyle,pos=pos,/nodata
endif else begin
  yr=!y.crange
endelse  


if (keyword_set(color)) then begin
  oplot,z,p,linestyle=linestyle,color=color
endif else begin
  oplot,z,p,linestyle=linestyle
endelse  
if (keyword_set(lcfs)) then plots,[lcfs,lcfs],[0,yr(1)/2],linestyle=2

if (not keyword_set(noerror)) then begin
  w=!p.color
  if (keyword_set(color)) then begin
    !p.color=color
  endif  
  errplot,z,p-pe,p+pe
  !p.color=w
endif  	
end
