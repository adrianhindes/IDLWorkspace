pro fluc_induce_flux
  points_num2 = 41
  
  probe = ptrarr(points_num2)
  discharge_time = 0.3
  base_shot = 639+3*123+1
  for i = 0, points_num2-1 do begin
    shot_number = i*3+639+3*123+2;1916;639 ;2047
    probe[i] = ptr_new(phys_quantity(shot_number,discharge_time=discharge_time))
;    print, 'get_data : ', i
  endfor
  print, 'done'
  
  middle_point = 2.25 ;[cm]
  
  subwindow_npts = 4096
  
  match_point = phys_quantity(639+21*3)
  filter = jw_spectrum(match_point.tvector, match_point.isat, match_point.isat_rot, [0.1, 0.29], subwindow_npts = subwindow_npts)
  
  trange = [0.01,discharge_time-0.01]
  cross_spectrum = ptrarr(points_num2)
  for i = 0, points_num2-1 do begin
    cross_spectrum[i] = ptr_new(jw_spectrum((*probe[i]).tvector, (*probe[i]).dens, (*probe[i]).vplasma, trange,subwindow_npts = subwindow_npts))
;    print, 'get_data : ', i
  endfor
  print, 'done'
  
;  ycplot, filter.freq, filter.coherency, error= filter.coherency_err
  
  finduced_flux_20kHz = dblarr(points_num2)
  radius = dblarr(points_num2)
  faxis = (*cross_spectrum[0]).freq
  for i = 0, points_num2-1 do begin
    radius[i] = (*probe[i]).location-middle_point
    finduced_flux_20kHz[i] = -total((*cross_spectrum[i]).power[where(faxis ge 15e3 and faxis le 25e3)]/2* $
        cos((*cross_spectrum[i]).phase[where(faxis ge 15e3 and faxis le 25e3)]+!pi/2)/abs(radius[i])/0.01 $
        *((*cross_spectrum[i]).freq[1]-(*cross_spectrum[i]).freq[0]))

;    if (i ge 20) and (i le 25)then begin
;      print, i
;      print, 1/abs((*probe[i]).location-middle_point)
;      
;      print, (*cross_spectrum[i]).power[where(faxis ge 10e3 and faxis le 30e3)]/2* $
;        cos((*cross_spectrum[i]).phase[where(faxis ge 10e3 and faxis le 30e3)]+!pi/2)/radius[i]/0.01*((*cross_spectrum[i]).freq[1]-(*cross_spectrum[i]).freq[0])
;      ycplot, faxis[where(faxis ge 10e3 and faxis le 30e3)], (*cross_spectrum[i]).power[where(faxis ge 10e3 and faxis le 30e3)]/2* $
;        cos((*cross_spectrum[i]).phase[where(faxis ge 10e3 and faxis le 30e3)]+!pi/2)/radius[i]/0.01*((*cross_spectrum[i]).freq[1]-(*cross_spectrum[i]).freq[0]), /ylog
;    endif
;    print, 'get_data : ', i
  endfor
  print, 'done'
  
  finduced_flux_40kHz = dblarr(points_num2)
  for i = 0, points_num2-1 do begin
    finduced_flux_40kHz[i] = -total((*cross_spectrum[i]).power[where(faxis ge 35e3 and faxis le 45e3)]/2* $
        cos((*cross_spectrum[i]).phase[where(faxis ge 35e3 and faxis le 45e3)]+!pi/2)/abs(radius[i])/0.01 $
        *((*cross_spectrum[i]).freq[1]-(*cross_spectrum[i]).freq[0]))
;    if (i ge 20) then begin
;      print, i
;      print, 1/abs((*probe[i]).location-middle_point)
;      print, (*cross_spectrum[i]).power[where(faxis ge 30e3 and faxis le 50e3)]/2* $
;        cos((*cross_spectrum[i]).phase[where(faxis ge 30e3 and faxis le 50e3)]+!pi/2)/abs(radius[i])/0.01 $
;        *((*cross_spectrum[i]).freq[1]-(*cross_spectrum[i]).freq[0])
;      ycplot, faxis[where(faxis ge 30e3 and faxis le 50e3)], (*cross_spectrum[i]).power[where(faxis ge 30e3 and faxis le 50e3)]/2* $
;        cos((*cross_spectrum[i]).phase[where(faxis ge 30e3 and faxis le 50e3)]+!pi/2)/abs(radius[i])/0.01 $
;        *((*cross_spectrum[i]).freq[1]-(*cross_spectrum[i]).freq[0]), /ylog
;    endif
;    print, 'get_data : ', i
  endfor
  
  finduced_flux = dblarr(points_num2)
  for i = 0, points_num2-1 do begin
    finduced_flux[i] = -total((*cross_spectrum[i]).power[where(faxis gt 5e3 and faxis lt 50e3)]/2* $
        cos((*cross_spectrum[i]).phase[where(faxis gt 5e3 and faxis lt 50e3)]+!pi/2)*(*cross_spectrum[i]).coherency[where(faxis gt 5e3 and faxis lt 50e3)]/abs(radius[i])/0.01 $
        *((*cross_spectrum[i]).freq[1]-(*cross_spectrum[i]).freq[0]))
;    ycplot, faxis, (*cross_spectrum[i]).phase
;    stop
;    if i ge 15 then begin
;;      print, (*cross_spectrum[i]).power[where(faxis ge 1e3)]/2* $
;;        cos((*cross_spectrum[i]).phase[where(faxis ge 1e3)]+!pi/2)*filter.coherency[where(faxis ge 1e3)]/abs(radius[i])/0.01 $
;;        *((*cross_spectrum[i]).freq[1]-(*cross_spectrum[i]).freq[0])
;;      ycplot, faxis, (*cross_spectrum[i]).power, error = (*cross_spectrum[i]).power_err, /ylog
;      ycplot, faxis[where(faxis ge 1e3)], (*cross_spectrum[i]).power[where(faxis ge 1e3 and faxis ge 1e3)]/2* $
;        cos((*cross_spectrum[i]).phase[where(faxis ge 1e3)]+!pi/2)*(*cross_spectrum[i]).coherency[where(faxis ge 1e3)]/abs(radius[i])/0.01 $
;        *((*cross_spectrum[i]).freq[1]-(*cross_spectrum[i]).freq[0])
;    endif
    print, 'get_data : ', i
  endfor
  
  dens_profile = dblarr(points_num2)
  temp_profile = dblarr(points_num2)
  for i = 0, points_num2-1 do begin
    dens_profile[i] = mean((*probe[i]).dens)
    temp_profile[i] = mean((*probe[i]).temp)
  endfor
  
  end_value = 0.25
  ycplot, radius[where(radius ge end_value)], finduced_flux_40kHz[where(radius ge end_value)]+finduced_flux_20kHz[where(radius ge end_value)], out_base_id = oid
;  ycplot, radius[where(radius ge end_value)], finduced_flux_40kHz[where(radius ge end_value)], oplot_id = oid
  ycplot, radius[where(radius ge end_value)], dens_profile[where(radius ge end_value)]
  ycplot, radius[where(radius ge end_value)], temp_profile[where(radius ge end_value)]
  ycplot, radius[where(radius ge end_value)], finduced_flux[where(radius ge end_value)];, oplot_id = oid
  
;  pro ycplot,  xdata, ydata, error = in_error, $
;             oplot_id = in_oplot_id, saved_file = in_saved_file, $
;             title = in_title, xtitle = in_xtitle, ytitle = in_ytitle, xlog = in_xlog, ylog = in_ylog, $
;             xsize = in_xsize, ysize = in_ysize, legend_item = in_legend_item, $
;             description = in_description, note = in_note, $
;             out_base_id = out_base_id

  
end

;a = phys_quantity(639)
;b = jw_spectrum(a.tvector, a.dens, a.vplasma, [0.01, 0.29])
;ycplot, b.freq, b.PHASE
;ycplot, b.freq, b.power
;d = b.power*cos(b.PHASE+!pi/2)*b.coherency





