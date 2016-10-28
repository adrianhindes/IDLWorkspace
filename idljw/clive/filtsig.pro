pro filtsig, sig, bw=bw,f0=f0,t=t,nmax=nmax,nodc=nodc,ytype=type
default,type,'gaussian'

  s=fft(sig)
  f=fft_t_to_f(t)
  fm=1/(t(1)-t(0))

  f2=f
  idx=where(f ge fm/2)

  f2(idx)-=fm
  default,nmax,floor(fm/f0/2)
  nn=n_elements(sig)
  win=fltarr(nn)
  for i=-nmax,nmax do begin
     if i eq 0 and keyword_set(nodc)  then continue
     if type eq 'gaussian' then win+=exp(-(f2 - i*f0)^2/bw^2)
     if type eq 'hat' then win+=hatnew(i*f0,bw,f2)
;     print,i*f0
  endfor
;  plot,f,abs(s),/ylog
;  oplot,f,win,col=2
  s2=s*win
  sig=fft(s2,/inverse)
;stop  
end

