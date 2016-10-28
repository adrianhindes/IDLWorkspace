pro fluc_induce_flux_02
  points_num2 = 41
  
  probe = ptrarr(points_num2)
  for i = 0, points_num2-1 do begin
    shot_number = i*3+1007;638 ;2047
    probe[i] = ptr_new(phys_quantity(shot_number))
    print, 'get_data : ', i
  endfor
  
  middle_point = 2.25 ;[cm]
  
  subwindow_npts = 4096
  
  match_point = phys_quantity(2112)
  filter = jw_spectrum(match_point.tvector, match_point.isat, match_point.isat_rot, [0.1, 0.29], subwindow_npts = subwindow_npts)
  
  trange = [0.1,0.29]
  cross_spectrum = ptrarr(points_num2)
  for i = 0, points_num2-1 do begin
    cross_spectrum[i] = ptr_new(jw_spectrum((*probe[i]).tvector, (*probe[i]).dens, (*probe[i]).vplasma, trange,subwindow_npts = subwindow_npts))
    print, 'get_data : ', i
  endfor
  
  finduced_flux_20kHz = dblarr(points_num2)
  radius = dblarr(points_num2)
  for i = 0, points_num2-1 do begin
    finduced_flux_20kHz[i] = -total((*cross_spectrum[i]).power[where((*cross_spectrum[i]).freq ge 15e3 and (*cross_spectrum[i]).freq le 25e3)]/2* $
      cos((*cross_spectrum[i]).phase[where((*cross_spectrum[i]).freq ge 15e3 and (*cross_spectrum[i]).freq le 25e3)]+!pi/2)/abs((*probe[i]).location-middle_point))/0.01* $
      ((*cross_spectrum[i]).freq[1]-(*cross_spectrum[i]).freq[0])
    radius[i] = abs((*probe[i]).location-middle_point)
;    if i eq 22 then begin
;      ycplot, (*cross_spectrum[i]).freq, (*cross_spectrum[i]).power, /ylog
;      ycplot, (*cross_spectrum[i]).freq, (*cross_spectrum[i]).phase
;    endif else if i eq 25 then begin
;      ycplot, (*cross_spectrum[i]).freq, (*cross_spectrum[i]).power, /ylog
;      ycplot, (*cross_spectrum[i]).freq, (*cross_spectrum[i]).phase
;    endif
    
    print, 'get_data : ', i
  endfor
  
  finduced_flux_40kHz = dblarr(points_num2)
  radius = dblarr(points_num2)
  for i = 0, points_num2-1 do begin
    finduced_flux_40kHz[i] = -total((*cross_spectrum[i]).power[where((*cross_spectrum[i]).freq ge 35e3 and (*cross_spectrum[i]).freq le 45e3)]/2* $
      cos((*cross_spectrum[i]).phase[where((*cross_spectrum[i]).freq ge 35e3 and (*cross_spectrum[i]).freq le 45e3)]+!pi/2)/abs((*probe[i]).location-middle_point))/0.01* $
      ((*cross_spectrum[i]).freq[1]-(*cross_spectrum[i]).freq[0])
    radius[i] = abs((*probe[i]).location-middle_point)
;    if i eq 22 then begin
;      ycplot, (*cross_spectrum[i]).freq, (*cross_spectrum[i]).power
;      ycplot, (*cross_spectrum[i]).freq, (*cross_spectrum[i]).phase
;      ycplot, (*cross_spectrum[i]).freq, (*cross_spectrum[i]).coherency
;    endif else if i eq 25 then begin
;      ycplot, (*cross_spectrum[i]).freq, (*cross_spectrum[i]).power
;      ycplot, (*cross_spectrum[i]).freq, (*cross_spectrum[i]).phase
;    endif
    
    print, 'get_data : ', i
  endfor
  
  finduced_flux = dblarr(points_num2)
  radius = dblarr(points_num2)
  for i = 0, points_num2-1 do begin
    finduced_flux[i] = -total((*cross_spectrum[i]).power[where((*cross_spectrum[i]).freq ge 1e3 and (*cross_spectrum[i]).freq le 500e3)]/2* $
      cos((*cross_spectrum[i]).phase[where((*cross_spectrum[i]).freq ge 1e3 and (*cross_spectrum[i]).freq le 500e3)]+!pi/2)* $
      filter.coherency[where((*cross_spectrum[i]).freq ge 1e3 and (*cross_spectrum[i]).freq le 500e3)]) $ 
      /abs((*probe[i]).location-middle_point) /0.01* $
      ((*cross_spectrum[i]).freq[1]-(*cross_spectrum[i]).freq[0])
    radius[i] = (*probe[i]).location-middle_point ;(*cross_spectrum[i]).coherency[where((*cross_spectrum[i]).freq ge 0 and (*cross_spectrum[i]).freq le 500e3)])/0.01* $
    if i ge 15 and i le 25 then begin
      ycplot, (*cross_spectrum[i]).freq,(*cross_spectrum[i]).power/2* $
      cos((*cross_spectrum[i]).phase+!pi/2)* $
      filter.coherency
      ycplot, (*cross_spectrum[i]).freq[where((*cross_spectrum[i]).freq ge 1e3 and (*cross_spectrum[i]).freq le 500e3)] ,(*cross_spectrum[i]).power[where((*cross_spectrum[i]).freq ge 1e3 and (*cross_spectrum[i]).freq le 500e3)]/2* $
      cos((*cross_spectrum[i]).phase[where((*cross_spectrum[i]).freq ge 1e3 and (*cross_spectrum[i]).freq le 500e3)]+!pi/2)* $
      filter.coherency[where((*cross_spectrum[i]).freq ge 1e3 and (*cross_spectrum[i]).freq le 500e3)]
      print, total((*cross_spectrum[i]).power[where((*cross_spectrum[i]).freq ge 1e3 and (*cross_spectrum[i]).freq le 500e3)]/2* $
      cos((*cross_spectrum[i]).phase[where((*cross_spectrum[i]).freq ge 1e3 and (*cross_spectrum[i]).freq le 500e3)]+!pi/2)* $
      filter.coherency[where((*cross_spectrum[i]).freq ge 1e3 and (*cross_spectrum[i]).freq le 500e3)])
    endif
;    if i eq 22 then begin
;      ycplot, (*cross_spectrum[i]).freq, (*cross_spectrum[i]).power
;      ycplot, (*cross_spectrum[i]).freq, (*cross_spectrum[i]).phase
;    endif else if i eq 25 then begin
;      ycplot, (*cross_spectrum[i]).freq, (*cross_spectrum[i]).power
;      ycplot, (*cross_spectrum[i]).freq, (*cross_spectrum[i]).phase
;    endif
    
    print, 'get_data : ', i
  endfor
  
  ycplot, radius[where(radius ge 1.0)], finduced_flux_20kHz[where(radius ge 1.0)], out_base_id = oid
  ycplot, radius[where(radius ge 1.0)], finduced_flux_40kHz[where(radius ge 1.0)], oplot_id = oid
  ycplot, radius[where(radius ge 1.0)], finduced_flux[where(radius ge 1.0)];, oplot_id = oid

  
end