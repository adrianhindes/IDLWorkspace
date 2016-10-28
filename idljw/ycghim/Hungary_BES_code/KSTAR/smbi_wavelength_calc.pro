pro smbi_wavelength_calc, shot, refchan=refchan, twin=twin, fullwin=fullwin

default, shot, 6352
default, refchan, 1
default, vchan, 6
default, twin, 0.05 ;timewindow for the stepping
default, fullwin, 0.45
default, ps, 1
refchan='BES-'+strtrim(refchan,2)+'-'+strtrim(vchan,2)
cd, 'D:\KFKI\Measurements\KSTAR\Measurement'
!p.font=0


pos=plot_position(2,1, ygap=0.2)
case shot of
  6352: t_smbi=2.7
  6353: t_smbi=2.5
  ;6376: t_smbi=[2.2,2.7,3.2]
  6376: t_smbi=2.7
endcase

n=round(fullwin*2/twin)
tvec_smbi =  dindgen(n)/n*fullwin*2 + t_smbi-fullwin
phase=dblarr(4,2)
dist=dblarr(4)
frange1=[10e3,20e3]
frange2=[40e3,80e3]

spat_cord=getcal_kstar_spat(shot, /xyz)

for i=1, 3 do begin
  dist[i]=distance(reform(spat_cord[0,vchan-1,*]), reform(spat_cord[i,vchan-1,*]))
endfor

print, dist
wavelength=dblarr(n,2)
wl_err=dblarr(n,2)
p_err=dblarr(n,2)

  for i=0,n-1 do begin
    timerange=[tvec_smbi[i],tvec_smbi[i]+twin]
    for j=1,3 do begin
      plotchan='BES-'+strtrim(j+1,2)+'-'+strtrim(vchan,2)
      
      fluc_correlation, shot, timerange=timerange, refchan=refchan, plotchan=plotchan,$
                        outphase=outphase, outfscale=outfscale, /noplot, interval_n=1
                        
      phase[j,0]=mean(outphase[where(outfscale gt frange1[0] and outfscale lt frange1[1])])
      phase[j,1]=mean(outphase[where(outfscale gt frange2[0] and outfscale lt frange2[1])])
      
    endfor
    
    m=dist[3]/phase[3,0]
    p1=mpfitfun('steepness_fit', dist, reform(phase[*,0]), [0.01,0.01,0.01,0.01], [m], perror=p1error)
    wavelength[i,0]=1/p1[0]*(2*!pi)
    
    
    p_err[i,0]=p1error ;sqrt(total((phase[*,0]-mean(phase[*,0])^2)/total((dist-mean(dist))^2)))
    wl_err[i,0]=1/p1^2*2*!pi*p_err[i,0]
    
    m=dist[3]/phase[3,1]
    p2=mpfitfun('steepness_fit', dist, reform(phase[*,1]), [0.01,0.01,0.01,0.01], [m], perror=p2error)
    wavelength[i,1]=1/p2[0]*(2*!pi)
    
    p_err[i,1]=p2error ;sqrt(total((phase[*,1]-mean((phase[*,1]))^2)/total((dist-mean(dist))^2)))
    wl_err[i,1]=1/p2^2*2*!pi*p_err[i,1]
    
    erase
    
;    plot, dist, phase[*,0], xstyle=1, ystyle=1, ytitle='Phase [rad]', xtitle='Distance [mm]',$
;          position=pos[0,*], title='SMBI_10-30kHz'+strtrim(timerange[0],2), /noerase, psym=4
;    oplot, dist, phase[*,0], color=160, psym=4, thick=3
;    oplot, dist, p1[0]*dist, color=255
;    
;    plot, dist, phase[*,1], xstyle=1, ystyle=1, ytitle='Phase [rad]', xtitle='Distance [mm]',$
;          position=pos[1,*], title='SMBI_30-50kHz'+strtrim(timerange[0],2), /noerase, psym=4
;    oplot, dist, phase[*,1], color=200, psym=4, thick=3
;    oplot, dist, p2[0]*dist, color=255
    
    ;cursor, x,y,/down
  endfor
stop
erase

if keyword_set(ps) then hardon, /color
device, decomposed=0
loadct, 5

;ymin=min(wavelength)
;ymax=max(wavelength)
ymin=0
ymax=300


plot, tvec_smbi+twin/2, wavelength[*,0], xstyle=1, ystyle=1, xtitle='Time [s]', ytitle='Wavelength [mm]',$
      position=[0.05,0.05,0.95,0.6], title='SMBI @ '+strtrim(t_smbi,2)+'s, Frequency range: 10-20kHz', /noerase, yrange=[ymin, 1000],$
      charsize=2, thick=3
oploterr, tvec_smbi+twin/2, wavelength[*,0], wl_err[*,1]

;plot, tvec_smbi+twin/2, wavelength[*,1], xstyle=1, ystyle=1, xtitle='Time [s]', ytitle='Wavelength [mm]',$
;      position=pos[1,*], title='SMBI @'+strtrim(t_smbi,2)+'s, Frequency range: 30-50kHz', /noerase ; ,yrange=[ymin, ymax]
;oploterr, tvec_smbi+twin/2, wavelength[*,1], wl_err[*,1]
if keyword_set(ps) then hardfile, 'plots/smbi_analysis/smbi_wavelength_calc_'+strtrim(shot,2)+'.ps'

end