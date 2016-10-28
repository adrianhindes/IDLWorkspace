pro show_cortime,k,ks,z,t,zrange=zrange,yrange=yrange,title=title,level=level,$
   linestyle=linestyle,over=over,para_txt=para_txt,nopara=nopara,lcfs=lcfs,color=color,$
   nolegend=nolegend,noerror=noerror,axisthick=axisthick,linethick=linethick,font=font,charsize=charsize,$
   usersym=usersym,symsize=symsize,position=pos

default,level,0.3
default,pos,[0.15,0.15,0.7,0.7]
default,para_txt,''
default,linestyle,0
default,title,''
default,color,!p.color
default,linestyle,0
default,axisthick,1
default,linethick,1
default,charsize,1
default,usersym,0
default,symsize,1

if (keyword_set(lcfs)) then begin
  if (lcfs gt 30) then lcfs=get_lcfs(lcfs)
endif      
if (not keyword_set(over)) then begin
  erase
  if (not keyword_set(nolegend)) then time_legend,'show_cortime.pro'
  if (not keyword_set(nopara)) then begin
    plots,[pos(2)+0.02,pos(2)+0.02],[0.1,0.9],thick=3,/normal
    plotpara='level='+string(level,format='(F4.2)')
    xyouts,pos(2)+0.04,0.85,para_txt+'!C!C'+plotpara,/normal
  endif
endif

n=n_elements(z)
nt=n_elements(t)
t0=(where(t eq 0))(0)
dt=t(1)-t(0)
if (t0 lt 0) then begin
  print,'show_cortime.pro: no 0 time found in correlation function'
  return
endif  
ctime=fltarr(n)
for i=0,n-1 do begin
  c=k(i,i,*)
  cs=ks(i,i,*)
  if (c(t0)-cs(t0) gt abs(c(t0)*level))  then begin
    lev=level*c(t0)
    i1=t0
    while ((i1 lt nt-1) and (c(i1) gt lev)) do i1=i1+1
    i2=t0
    while ((i2 gt 0) and (c(i2) gt lev)) do i2=i2-1
    ctime(i)=float((i1-i2))/2*dt
  endif
endfor


ctime1=fltarr(n)
ctime2=fltarr(n)
if (not keyword_set(noerror)) then begin
  for i=0,n-1 do begin
    c=k(i,i,*)
    cs=ks(i,i,*)
    if (c(t0)-cs(t0) gt abs(c(t0)*level))  then begin
      lev=level*c(t0)
      c=c-cs
      i1=t0
      while ((i1 lt nt-1) and (c(i1) gt lev)) do i1=i1+1
      i2=t0
      while ((i2 gt 0) and (c(i2) gt lev)) do i2=i2-1
      ctime1(i)=float((i1-i2))/2*dt
    endif
  endfor
  
  for i=0,n-1 do begin
    c=k(i,i,*)
    cs=ks(i,i,*)
    if (c(t0)-cs(t0) gt abs(c(t0)*level))  then begin
      lev=level*c(t0)
      c=c+cs
      i1=t0
      while ((i1 lt nt-1) and (c(i1) gt lev)) do i1=i1+1
      i2=t0
      while ((i2 gt 0) and (c(i2) gt lev)) do i2=i2-1
      ctime2(i)=float((i1-i2))/2*dt
    endif
  endfor
endif

ind=where(ctime ne 0)
if (ind(0) lt 0) then begin
  print,'show_cortime.pro: No lifetimes found!'
  return
endif
zz=z(ind)
ctime=ctime(ind)
ctime1=ctime1(ind)
ctime2=ctime2(ind)


default,zrange,[min(z)-1,max(z)+1]
default,yrange,[0,max([ctime2,ctime])*1.05]

plotsymbol,usersym
if (not keyword_set(over)) then begin
  plot,z,ctime,xrange=zrange,xstyle=1,xtitle='Z [cm]',yrange=yrange,ystyle=1,$
    ytitle='Correlation time [microsec]',title=title,position=pos,/noerase,/nodata,xthick=axisthick,ythick=axisthick,charsize=charsize,font=font
endif
oplot,z,ctime,linestyle=linestyle,color=color,psym=-8,symsize=symsize
if (not keyword_set(noerror)) then begin
  w=!p.color
  if (keyword_set(color)) then !p.color=color
  errplot,z,ctime1,ctime2
  !p.color=w
endif  

if (keyword_set(lcfs)) then plots,[lcfs,lcfs],[0,yrange(1)],linestyle=2



end
