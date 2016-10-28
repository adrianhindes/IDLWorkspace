pro lithium_filter_analysis, cwl, bw

default, cwl, 670.
default, bw, '1.0'
energy=dblarr(10)
radius=dblarr(10)
energy=dindgen(21)*1.5+30.
radius=2340-dindgen(36)*10
nrad=n_elements(radius)
nener=n_elements(energy)
matrix_ds=dblarr(nrad,nener)
matrix_wd_g=dblarr(nrad,nener)
matrix_dt=dblarr(nrad,nener)
matrix_wd=dblarr(nrad,nener)

for i=0, nrad-1 do begin 
  for j=0, nener-1 do begin
    CALCULATE_LITHIUM_FILTER, ebeam=energy[j], radius=radius[i], doppler_shift=doppler_shift, filter_transmission=filter_transmission, trans_doppler=trans_doppler, $
                              w_doppler_i=w_doppler_i, w_doppler_geom=w_doppler, /equation, trans_fix=trans_fix, cwl=cwl, bw=bw
    matrix_ds[i,j]=doppler_shift
    matrix_wd_g[i,j]=w_doppler
    matrix_dt[i,j]=trans_doppler
    matrix_wd[i,j]=w_doppler_i
  endfor
endfor
device, decomposed=0

plot, radius, matrix_dt[*,0], xtitle='Radius [mm]', ytitle='Transmission [%]', title='Radius - Transmission curve for 30keV and 60keV for !C'+bw+'nm bandwidth and '+strtrim(cwl,2)+'nm CWL', thick=3, charsize=2, xrange=[2340, 1990], yrange=[0,50]
oplot, radius, matrix_dt[*,20], thick=3, color=80
;contour, matrix_dt, radius, energy, nlevels=255, /fill, xtitle='Radius [mm]', ytitle='Beam energy [keV]', title='Doppler shifted wavelength transmission !Cas a function of radius and beam energy',$
;    position=[0.05,0.05,0.90,0.95], xrange=[2340, 1990], yrange=[30,60], xstyle=1, ystyle=1, charsize=2, thick=3
;colorbar, position=[0.96,0.05, 0.98, 0.95], ncolors=255, /vertical, min=min(matrix_dt), max=max(matrix_dt), color=255
;xyouts, 0.9,0.98, 'Ar II transmission:!C'+strtrim(trans_fix,2)+'%', /norm
;erase
;contour, matrix_wd, radius, energy, nlevels=255, /fill, xtitle='Radius [mm]', ytitle='Beam energy [keV]', title='Doppler shifted wavelength as a function of !Cradius and beam energy',$
;    position=[0.05,0.05,0.90,0.95], xrange=[2340, 1990], yrange=[30,60], xstyle=1, ystyle=1, charsize=2, thick=3
;colorbar, position=[0.96,0.05, 0.98, 0.95], ncolors=255, /vertical, min=min(matrix_wd), max=max(matrix_wd), color=255
;erase
;contour, matrix_wd_g, radius, energy, nlevels=255, /fill, xtitle='Radius [mm]', ytitle='Beam energy [keV]', title='Doppler shifted wavelength (only geometry) as !Ca function of radius and beam energy',$
;    position=[0.05,0.05,0.90,0.95], xrange=[2340, 1990], yrange=[30,60], xstyle=1, ystyle=1, charsize=2, thick=3
;colorbar, position=[0.96,0.05, 0.98, 0.95], ncolors=255, /vertical, min=min(matrix_wd_g), max=max(matrix_wd_g), color=255
;erase
;contour, matrix_ds, radius, energy, nlevels=255, /fill, xtitle='Radius [mm]', ytitle='Beam energy [keV]', title='Doppler shift (only geometry) as !Ca function of radius and beam energy',$
;    position=[0.05,0.05,0.90,0.95], xrange=[2340, 1990], yrange=[30,60], xstyle=1, ystyle=1, charsize=2, thick=3
;colorbar, position=[0.96,0.05, 0.98, 0.95], ncolors=255, /vertical, min=min(matrix_ds), max=max(matrix_ds), color=255
print, (70-23)*0.018
print, trans_fix
erase
end