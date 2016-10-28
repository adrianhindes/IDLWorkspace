pro show_elm,k,ks,z,t,zrange=zrange,yrange=yrange,title=title,fitrange=fitrange,$
   linestyle=linestyle,over=over,para_txt=para_txt,nopara=nopara,lcfs=lcfs,color=color,$
   nolegend=nolegend,noerror=noerror,noquality=noquality,norelpower=norelpower

default,pos,[0.1,0.15,0.7,0.7]
default,pos1,[0.1,0.8,0.3,0.95]
default,pos2,[0.4,0.8,0.6,0.95]
default,para_txt,''
default,linestyle,0
default,title,''
default,color,!p.color
default,linestyle,0
default,fitrange,[100,250]

if (keyword_set(lcfs)) then begin
  if (lcfs gt 30) then lcfs=get_lcfs(lcfs)
endif      
if (not keyword_set(over)) then begin
  erase
  if (not keyword_set(nolegend)) then time_legend,'show_elm.pro'
  if (not keyword_set(nopara)) then begin
    plots,[pos(2)+0.02,pos(2)+0.02],[0.1,0.9],thick=3,/normal
    plotpara='fitrange: ['+i2str(fitrange(0))+','+i2str(fitrange(1))+']'
    xyouts,pos(2)+0.04,0.85,para_txt+'!C!C'+plotpara,/normal
  endif
endif

nz=n_elements(z)
nt=n_elements(t)
t0=(where(t eq 0))(0)
dt=t(1)-t(0)
if (t0 lt 0) then begin
  print,'show_elm.pro: no 0 time found in correlation function'
  return
endif  
elmamp=dblarr(nz)
elmerr=dblarr(nz)
avect=dblarr(nz)
sigmavect=fltarr(nz)
pvect=dblarr(nz)
ind=where((t ge fitrange(0)) and (t le fitrange(1)))
if (n_elements(ind) lt 2) then begin
  print,'show_elm.pro:  Not enough points in fit range!'
  return
endif
x=t(ind)
n=n_elements(ind)  
for i=0,nz-1 do begin
  c=dblarr(n)
  cs=dblarr(n)
  c(*)=k(i,i,ind)
  cs(*)=ks(i,i,ind)
;  sx2=total(x^2/cs^2)
;  sx=total(x/cs^2)
  res=linfit(x,c,chisq=chi,/double,sdev=cs,sigma=sigma)
  elmamp(i)=res(0)
  avect(i)=res(1)
;  sigmavect(i)=sqrt(total((c-(x*avect(i)+elmamp(i)))^2/cs^2)/nz)
  sigmavect(i)=sqrt(chi/n)
  elmerr(i)=sigma(0)
  pvect(i)=k(i,i,t0)
;  elmamp(i)=(total(c/cs^2)*sx2-sx*total(x*c/cs^2))/(total(1/cs^2)*sx2-sx^2)
;  avect(i)=(total(c*x/cs^2)-elmamp(i)*sx)/sx2
;  sigmavect(i)=sqrt(total((c-(x*avect(i)+elmamp(i)))^2/cs^2)/nz)
;  elmerr(i)=sqrt(total(1/cs^2)*sx2^2+sx^2*sx2)/abs((total(1/cs^2)*sx2-sx^2))
;  plot,x,c,psym=1,xrange=[0,max(x)],yrange=[min([c,elmamp(i)]),max([c,elmamp(i)])],title=string(i)
;  errplot,x,c-cs,c+cs
;  plotsymbol,0
;  oplot,[0,0],[elmamp(i),elmamp(i)],psym=8,clip=0
;  if (not ask('Continue?')) then stop
endfor

default,zrange,[min(z)-1,max(z)+1]
default,yrange,[min(elmamp-elmerr),max(elmamp+elmerr)]

if (not keyword_set(over)) then begin
  plot,z,elmamp,xrange=zrange,xstyle=1,xtitle='Z [cm]',yrange=yrange,ystyle=1,$
    ytitle='ELM power',title=title,position=pos,/noerase,/nodata
endif
oplot,z,elmamp,linestyle=linestyle,color=color
if (not keyword_set(noerror)) then begin
  w=!p.color
  if (keyword_set(color)) then !p.color=color
  errplot,z,elmamp-elmerr,elmamp+elmerr
  !p.color=w
endif  
if (yrange(0) lt 0) then plots,[zrange],[0,0],linestyle=1
if (keyword_set(lcfs)) then plots,[lcfs,lcfs],[yrange(0),(yrange(1)-yrange(0))/2+yrange(0)],linestyle=2

if (not keyword_set(noquality)) then begin
  psave=!p
  xsave=!x
  ysave=!y
  plot,z,sigmavect,pos=pos1,xrange=zrange,xstyle=1,xtitle='Z [cm]',ytitle='!7v!X!U2!N',$
  title='Fit quality',/noerase,charsize=0.7
  oplot,zrange,[1,1],linestyle=2
  if (keyword_set(lcfs)) then plots,[lcfs,lcfs],[!y.crange(0),(!y.crange(1)-!y.crange(0))/2+!y.crange(0)],linestyle=2
  !p=psave
  !x=xsave
  !y=ysave
endif
if (not keyword_set(norelpower)) then begin
  psave=!p
  xsave=!x
  ysave=!y
  ind=where(pvect gt 0)
  pvect=pvect(ind)
  elmamp=elmamp(ind)
  plot,z,elmamp/pvect,pos=pos2,xrange=zrange,xstyle=1,xtitle='Z [cm]',$
  title='Relative ELM power',/noerase,charsize=0.7
  if(!y.crange(0) lt 0) then oplot,zrange,[0,0],linestyle=2
  if (keyword_set(lcfs)) then plots,[lcfs,lcfs],[!y.crange(0),(!y.crange(1)-!y.crange(0))/2+!y.crange(0)],linestyle=2
  !p=psave
  !x=xsave
  !y=ysave
endif
end
