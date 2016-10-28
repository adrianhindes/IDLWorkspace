function envelope_signal, tvector, signal, freq_filter = freq_filter, plot = plot
  dt = tvector[1]-tvector[0]
  
  default, nyquist_freq, (1.0/dt)*0.5
  default, freq_filter, [0.0, nyquist_freq]
  default, plot, 0
  

  fs = 1.0/dt
  df = 1.0/(n_elements(signal)*dt)
  freq_vector = (dindgen(fs/df)-floor(fs/df/2))*df
  high_pass = freq_filter[0]/(fs/2)
  low_pass = freq_filter[1]/(fs/2)
  
  filtered_signal = JW_BANDPASS(signal, high_pass, low_pass, BUTTERWORTH=50)
  
  envelope = sqrt((hilbert(filtered_signal))^2.0 + filtered_signal^2.0)
  
  if KEYWORD_SET(plot) then begin
    ycplot, tvector, signal, out_base_id = oid
    ycplot, tvector, filtered_signal, oplot_id = oid
    ycplot, tvector, envelope, oplot_id = oid
  endif
  return, envelope
end