pro analyse_bg_noise, shot=shot, start_time=start_time

default,shot,6078
get_rawsignal,shot,'BES-1-1',t,d, /nocalib

;BES channels 4x8
tres=t[1]-t[0]
ndata=n_elements(d)

;set interpolate
maxpoints=500
if (ndata gt maxpoints) then begin
  ti=interpol(t,maxpoints)
  di=interpol(d,maxpoints)
endif
if (not keyword_set(start_time)) then begin
  ;increase the size of the plot
  plot, [0,0], [1,1]
  cursor, x,z, /down, /data
  ;plot the data
  plot, ti, di
  cursor, t1, d1, /down, /data
  
  ;plot the 0.5s window for better positioning 
  ;and determine the pure bg noise startup time
  ind=where((t ge t1-0.5) and (t le t1+0.5))
  plot, t[ind],d[ind]
  cursor, t1, d1, /down,/data
  start_time=t1
endif else begin
  t1=start_time
endelse

;get the raw data from .dat files

get_rawsignal,shot,'BES-1-1',t2,d2, trange=[t1, max(t)], errormess=err
nwin=n_elements(t2)
tbg=dblarr(4,8,nwin)
dbg=fltarr(4,8,nwin)
maxvec=dblarr(4,8)
minvec=dblarr(4,8)
print, [t1, max(t)]
print, nwin
for i=0,3 do begin
  for j=0,7 do begin
    ;get_rawsignal,shot,'BES-'+strtrim(i+1,2)+'-'+strtrim(j+1,2),tbg[i,j,*],dbg[i,j,*], trange=[t1, max(t)], errormess=err
    get_rawsignal,shot,'BES-'+strtrim(i+1,2)+'-'+strtrim(j+1,2),t2,d2, trange=[t1, max(t)], errormess=err, /nocalib
    tbg[i,j,*]=t2
    dbg[i,j,*]=d2
    maxvec[i,j]=max(dbg[i,j,*])
    minvec[i,j]=min(dbg[i,j,*])
    print, 'BES-'+strtrim(i+1,2)+'-'+strtrim(j+1,2)
  endfor
endfor

;plot the signals

set_plot_style, 'foile_kg_eps'
hardon,/color
loadct, 40
;d_range=[min(dbg)*0.9,max(dbg)*1.1]
for i=0,3 do begin
  for j=0,7 do begin
    if (nwin gt maxpoints) then begin
      ti=interpol(tbg[i,j,*],maxpoints)
      di=interpol(dbg[i,j,*],maxpoints)
    endif else begin
      ti=tbg[i,j,*]
      di=dbg[i,j,*]
    endelse
    pos=[0.05+i*0.20,0.82-j*0.11,0.23+i*0.20,0.93-j*0.11]
    ;pos=[0.05+j*0.11,0.7-i*0.20,0.14+j*0.11,0.9-i*0.20]
    xc=0.01
    if (j eq 7) then xc=0.5
    yc=0.3
    if (minvec[i,j] lt 3*mean(minvec) or maxvec[i,j] gt 3*mean(maxvec)) then c=240 else c=0
    plot, ti, di, xcharsize=xc, ycharsize=yc, position=pos,$
          xstyle=1, ystyle=1,/noerase, color=c
          
    xyouts, pos[2]-0.02,pos[3]-0.01, strtrim(i+1,2)+'-'+strtrim(j+1,2),/normal,charsize=0.5
  endfor
endfor
xyouts, 0.05, 0.96, 'Shot: #'+strtrim(shot,2), charsize=0.5, /normal
xyouts, 0.05, 0.96, 'Data from'+strtrim(t1,2), charsize=0.5, /normal
erase

;calculate fft and interpolate to maxpoints for easier plotting

fluc_correlation, shot, /noplot, outfscale=fvec, outpower=spect,$
                  timerange=[t1,max(tbg)], refchan='BES-1-1', fres=1e3, /silent
spect=dblarr(4,8,n_elements(spect))
for i=0,3 do begin
  for j=0,7 do begin
    fluc_correlation,shot, /noplot, outfscale=fvec, outpower=specttemp, timerange=[t1,max(tbg[i,j,*])],$
                     refchan='BES-'+strtrim(i+1,2)+'-'+strtrim(j+1,2), fres=1e3, /silent
    spect[i,j,*]=specttemp
    print, 'BES-'+strtrim(i+1,2)+'-'+strtrim(j+1,2)
    ;help, fvec, spect
  endfor
endfor

;plot the spectrum of channels

sprange=[0.9*min(spect), 1.1*max(spect)]
for i=0,3 do begin
  for j=0,7 do begin
    if (nwin gt maxpoints) then begin
      spect2=interpol(spect[i,j,*],maxpoints)
      fvec2=interpol(fvec,maxpoints)
    endif
    pos=[0.05+i*0.20,0.75-j*0.10,0.23+i*0.20,0.85-j*0.1]
    xc=0.01
    yc=0.3
    if (j eq 7) then xc=0.5
;    if (i eq 0) then yc=0.5
    if (minvec[i,j] lt 3*mean(minvec) or maxvec[i,j] gt 3*mean(maxvec)) then c=240 else c=0
    plot, fvec2, spect2, xcharsize=xc, ycharsize=yc, position=pos,$
          xstyle=1, ystyle=1,/noerase
    xyouts, pos[2]-0.02,pos[3]-0.01, strtrim(i+1,2)+'-'+strtrim(j+1,2),/normal,charsize=0.5  
  endfor
endfor

;calculate noise power

noise_power=dblarr(4,8)
for i=0,3 do begin
  for j=0,7 do begin
    noise_power[i,j]=sqrt(total(spect[i,j,where(fvec gt 1e4 and fvec lt 5e5)])*(fvec[1]-fvec[0])*2)
  endfor
endfor
nrange=[0.9*min(noise_power), 1.1*max(noise_power)]
for i=0,3 do begin
  pos=[0.05+i*0.20,0.87,0.23+i*0.20,0.97]
  yc=0.3
  plot, noise_power[i,*], position=pos, ycharsize=yc, xcharsize=0.3, /noerase, yrange=nrange, /ylog
endfor
xyouts, 0.05, 0.96, 'Shot: #'+strtrim(shot,2), charsize=0.5, /normal

hardfile,'plots/bg_noise_'+strtrim(shot,2)+'.ps'

end