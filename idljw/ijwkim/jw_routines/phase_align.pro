function phase_align, freq, phase, jump1 = jump1, jump2 = jump2, pickup = pickup ,pickup_size = pickup_size
  default, jump1, 50.0
  default, jump2, 200.0
  default, pickup, 150.0
  default, pickup_size, 0.5
  pos_freq = freq[where(freq ge 0)]
  
  temp_phase01 = phase[where(freq ge 0 and freq lt jump1*10^3)]
  temp_phase02 = phase[where(freq ge jump1*10^3 and freq lt jump2*10^3)]
  for i = 0L, n_elements(temp_phase02)-1 do begin
    if (temp_phase02[i] lt 0.0) then begin
      temp_phase02[i] = temp_phase02[i]+!PI*2.0
    endif
  endfor
  temp_phase03 = phase[where(freq ge jump2*10^3)]+!PI*2
  
  phase_jump = [temp_phase01, temp_phase02, temp_phase03]
  
  ycplot, freq[where(freq ge 0)], phase[where(freq ge 0)], out_base_id = oid
  
  ycplot, freq[where(freq ge 0)], phase_jump, oplot_id = oid
  
  phase_jump_smooth = smooth(phase_jump,30)
  
  ycplot, freq[where(freq ge 0)], phase_jump_smooth, oplot_id = oid
  
  phase_value = phase_jump_smooth[where(pos_freq ge (pickup-pickup_size)*10^3 and pos_freq lt (pickup+pickup_size)*10^3)]
  
  print, 'phase_value : ', phase_value
  print, where(pos_freq ge (pickup-pickup_size)*10^3 and pos_freq lt (pickup+pickup_size)*10^3)
;  ycplot, freq[where(freq ge 0)], phase_jump_smooth
  
  result = CREATE_STRUCT('freq', pos_freq, 'phase', phase_jump, 'phase_smooth', phase_jump_smooth, 'phase_value', phase_value)
  return, result
end