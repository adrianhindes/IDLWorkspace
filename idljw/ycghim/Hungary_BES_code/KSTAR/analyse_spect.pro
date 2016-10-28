pro analyse_spect, shot=shot, errormess=err, time_range=time_range
;shot=[6005, 6007, 6031, 6041, 6055, 6056, 6057, 6058, 6059, 6077, 6078]
;beolvasni egy csatorna jelét, amiből kiválasztani, hogy kb hol akarunk vizsgálódni
;utána azt a helyet kinagyítani, mint az előbb
;le kell gyártani a 32 spektrumot

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
if (not keyword_set(time_range)) then begin
  ;increase the size of the plot
  plot, [0,0], [1,1]
  cursor, x,z, /down, /data
  ;plot the data
  plot, ti, di
  cursor, t1, d1, /down, /data
  ;plot the 0.5s window for better positioning 
  ;and determine the pure bg noise startup time
  t_win=0.250
  ind=where((t ge t1-t_win) and (t le t1+t_win))
  plot, t[ind],d[ind]
  cursor, t1, d1, /down,/data
  cursor, t2, d2, /down, /data
  time_range=[t1,t2]
  print, time_range
endif
;calculate the spectrum of the channels in the time_window

fluc_correlation, shot, /noplot, outfscale=fvec, outpower=spect,$
                  timerange=time_range, refchan='BES-1-1', fres=1e3, /silent;, ftype=1
nwin=n_elements(spect)
spect=dblarr(4,8,nwin)
for i=0,3 do begin
  for j=0,7 do begin
    fluc_correlation,shot, /noplot, outfscale=fvec, outpower=specttemp, timerange=time_range,$
                     refchan='BES-'+strtrim(i+1,2)+'-'+strtrim(j+1,2), fres=1e3, /silent;,ftype=1
    spect[i,j,*]=specttemp
    print, 'BES-'+strtrim(i+1,2)+'-'+strtrim(j+1,2)
    ;help, fvec, spect
  endfor
endfor
;plot the spectrum

set_plot_style, 'foile_kg_eps'
hardon,/color
loadct, 40
frange=[1e3,1e6]
spart=spect[*,*,where(fvec ge frange[0] and fvec le frange[1])]
sprange=[0.9*min(spart), 1.1*max(spart)]

for i=0,3 do begin
  for j=0,7 do begin
    if (nwin gt maxpoints) then begin
      spect2=interpol(spect[i,j,*],maxpoints)
      fvec2=interpol(fvec,maxpoints)
    endif
    pos=[0.05+j*0.11,0.7-i*0.20,0.14+j*0.11,0.9-i*0.20]
    xc=0.01
    yc=0.3
    if (i eq 3) then xc=0.5
;    if (i eq 0) then yc=0.5
    plot, fvec2, spect2, xcharsize=xc, ycharsize=yc, position=pos,$
          xstyle=1, ystyle=1, xrange=frange, yrange=sprange, $
          xtype=1, ytype=1, /noerase
    xyouts, pos[2]-0.02,pos[3]-0.01, strtrim(i+1,2)+'-'+strtrim(j+1,2),/normal,charsize=0.5  
  endfor
endfor

hardfile, 'plots/analyse_spect_'+strtrim(shot,2)+'_'+strtrim(time_range[0],2)+'_'+strtrim(time_range[1],2)+'.ps'

end