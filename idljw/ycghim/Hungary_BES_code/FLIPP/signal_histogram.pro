pro signal_histogram,shot,timefile,channel ,bin=bin,min=min,max=max,afs=afs,sumlen=sumlen,$
histogram=h,hist_x=hx,inttime=inttime,nolegend=nolegend,yrange=yrange,noplot=noplot,$
stat=stat,data_source=data_source,cdrom=cdrom,subchannel=subchannel
; ******************* li_hist.pro *****************************************
; Calculates histogram of a signal
; and calculates statistical moments of the distribution
; Uses uncalibrated signals
; INPUT
;   sumlen: length of summation in samples before histogram preparation
;   inttime: a signal integrated with this time (microsec) is subtracted
; OUTPUT:
;   stat: [average,scatter,skewness,kurtosis]
;   histogram: the signal distribution
;   hist_x: the x scale of the distribution

default,sumlen,1
default,inttime,0
default,subchannel,0


tf=loadncol('time/'+timefile,2,/silent)
mint=min(tf)
maxt=max(tf)

;stop
get_rawsignal,shot,channel,time,data,trange=[mint,maxt],errormess=e,data_source=data_source,cdrom=cdrom,afs=afs,$
subchannel=subchannel,vertical_norm=vertical_norm,vertical_zero=vertical_zero,/nocalibrate
if (e ne '') then return
sampletime=time[1]-time[0]




data=round(data/vertical_norm)+vertical_zero

nt=(size(tf))(1)
for i=0,nt-1 do begin
  ind1=where((time gt tf(i,0)) and (time lt tf(i,1)))
  if (ind1(0) ge 0) then begin
    if (keyword_set(ind)) then ind=[ind,ind1] else ind=ind1
  endif
endfor

if (not keyword_set(data)) then begin
  print,'No data found in time intervals!'
  return
endif

if (not keyword_set(inttime)) then begin
  default,max,max(data(ind))
  default,min,min(data(ind))
endif else begin
  default,max,max(data(ind)-min(data(ind)))
  default,min,-max
endelse

default,bin,16*vertical_norm
bin=bin/vertical_norm
first=1
for i=0,nt-1 do begin
  ind=where((time gt tf(i,0)) and (time lt tf(i,1)))
  if (ind(0) ge 0) then begin
    d=data(ind)
    if (inttime ne 0) then begin
      d=d-integ(d,inttime/(sampletime/1e-6))
      start=inttime*3/(sampletime/1e-6)
      d=d(start:n_elements(d)-1)
    endif
    nn=long((size(d))(1)/sumlen)
    d1=fltarr(nn)
    for ii=0l,nn-1 do d1(ii)=total(d(ii*sumlen:(ii+1)*sumlen-1))/sumlen
    if (first) then begin
      h=histogram(d1,bin=bin,max=max,min=min)
      first=0
    endif else begin
      h=histogram(d1,bin=bin,max=max,min=min,input=h)
    endelse
  endif
endfor

p=(size(h))(1)
if (inttime ne 0) then begin
  hx=(findgen(p)*bin+min)*vertical_norm
endif else begin
  hx=(findgen(p)*bin+min-vertical_zero)*vertical_norm
endelse
tit=i2str(shot)+' timefile:'+timefile+' channel:'+i2str(channel)+$
' sumlen='+i2str(sumlen)
if (inttime ne 0) then tit=tit+' inttime='+i2str(inttime)+'!7l!Xs'

s0=total(h*hx)/total(h)
scat=total((hx-s0)^2*h)/total(h)
s=sqrt(scat)
ss=total((hx-s0)^3*h)/total(h)/scat^1.5
K=total((hx-s0)^4*h)/total(h)/scat^2
stat=[s0,s,ss,K]
if (not keyword_set(noplot)) then begin
  erase
  if (not keyword_set(nolegend)) then time_legend,'li_hist.pro'
  default,yrange,[0,max(h)*1.05]
  plot,hx,h,psym=10,position=[0.15,0.15,0.7,0.7],/noerase,$
  xtitle='Signal [V]',ytitle='Number of samples',yrange=yrange,ystyle=1
  xyouts,0,0.85,tit,/normal

  txt='Average:'+string(s0)
  txt=txt+'!C'+'Scatter:'+string(s)
  if (not keyword_set(inttime)) then txt=txt+'!C'+'Rel. scatter:'+string(s/s0*100)+'%'
  txt=txt+'!C'+'Skewness:'+string(ss)
  txt=txt+'!C'+'Kurtosis:'+string(K)
  xyouts,0.75,0.65,txt,/normal
endif
end

