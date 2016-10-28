

PRO apd_test

  noise_level = [0.05, 0.10, 0.20, 0.30]
  integ_duration = [60.0, 100.0, 150.0, 200.0] ;in [nsec]

; Generate signal
  num_pulses = 1000.0
  npts = 500.0
  t = findgen(npts)
  gaussian_center = npts/2.0  ;in [nsec]
  gaussian_height = 40.0      ;in [mV]
  gaussian_width = 10.0       ; in [mV]
  y = gaussian_height * exp(-(t-gaussian_center)^2.0/(2.0*gaussian_width^2.0))

; prepare for plot
  safe_colors, /first

; calculate
  value_true = gaussian_height*gaussian_width*sqrt(2.0*!pi) ;true area under the curve in [mV nsec]
  value_from_window = fltarr(N_ELEMENTS(noise_level), N_ELEMENTS(integ_duration), num_pulses)
  value_from_fit = fltarr(N_ELEMENTS(noise_level), num_pulses)
  flag = 0
  for i=0, N_ELEMENTS(noise_level)-1 do begin
    print, string(i+1, format='(i0)')+'/'+string(n_elements(noise_level), format='(i0)') + ' ', format='(A,$)'
    for j=0, N_ELEMENTS(integ_duration)-1 do begin
      for k=0, num_pulses-1 do begin
        noise = randomn(seed, npts)*noise_level[i]*gaussian_height
        s = y + noise
        if j eq 0 then begin
        ; use the gaussian fitting function
          gauss_fit = gaussfit(t, s, A, nterms=3, measure_errors = replicate(noise_level[i]*gaussian_height ,npts), estimates=[30, gaussian_center, gaussian_width])
          value_from_fit[i, k] =A[0]*A[2]*sqrt(2.0*!pi)
          if k eq 0 then begin
            if flag eq 0 then begin
              !p.multi = [0, 2, 2]
              window, /free, xs = 1000, ys = 1000
              flag = 1
            endif
            plot, t, s, xtitle='Time [nsec]', ytitle = '[mV]', $
                        title = 'Noise Level='+string(noise_level[i]*100.0, format='(f0.1)')+'%', col=1, $
                        yr = [-gaussian_height/2.0, gaussian_height*1.5], charsize=2
            oplot, t, gauss_fit, col=2, thick=2
            legendd, ['Data', 'Gaussian Fit'], linestyle=[0, 0], col=[1, 2], /right, charsize=2
          endif 
        endif
        ; use the window integration
        value_from_window[i, j, k] = TOTAL(s[gaussian_center-integ_duration[j]/2.0:gaussian_center+integ_duration[j]/2.0])
      endfor
    endfor 
  endfor

; Calculate standard deviations
  stddev_from_fit = STDDEV(value_from_fit, dimension=2)
  stddev_from_window = STDDEV(value_from_window, dimension=3)
  
  !p.multi = [0, 2, 2]
  window, /free, xs = 1000, ys = 1000
  for i=0, N_ELEMENTS(noise_level)-1 do begin
    inx_integ_window = 1
    plot, findgen(num_pulses), value_from_window[i, inx_integ_window, *], col=1, xtitle='Number of pulses', ytitle='Integrated signal [mV nsec]', $
          title = 'Noise Level='+string(noise_level[i]*100.0, format='(f0.1)')+'%, Integ. window='+$
                  string(integ_duration[inx_integ_window], format='(f0.1)')+' nsec', $
          yr = [value_true*0.5, value_true*1.5], charsize=1.5
    oplot, findgen(num_pulses), value_from_fit[i, *], thick=1.5, col=2
    oplot, !x.crange, [value_true, value_true], thick=2, col=3
    legendd, ['Integ. Window', 'Gaussian Fit', 'True value'], linestyle=[0, 0, 0], col=[1, 2, 3], /right, /bottom, charsize=2.0
  endfor

  !p.multi = 0
  window, /free, xs = 500, ys=500
  plot, noise_level*100.0, stddev_from_fit, col=1, xtitle='Noise Level [%]', ytitle='Std. Dev.', psym=2, yr=[0, max([stddev_from_fit, stddev_from_window[*, 3]])], xr=[0.0, max(noise_level*100)+10], charsize=2.0
  oplot, noise_level*100.0, stddev_from_fit, col=1, linestyle=0
  oplot, noise_level*100.0, stddev_from_window[*, 0], col=1, psym=6
  oplot, noise_level*100.0, stddev_from_window[*, 0], col=1, linestyle=2
  oplot, noise_level*100.0, stddev_from_window[*, 1], col=2, psym=6
  oplot, noise_level*100.0, stddev_from_window[*, 1], col=2, linestyle=2
  oplot, noise_level*100.0, stddev_from_window[*, 2], col=3, psym=6
  oplot, noise_level*100.0, stddev_from_window[*, 2], col=3, linestyle=2
  oplot, noise_level*100.0, stddev_from_window[*, 3], col=4, psym=6
  oplot, noise_level*100.0, stddev_from_window[*, 3], col=4, linestyle=2
  item = string(integ_duration, format='(f0.1)')+' nsec window'
  item = ['Gaussian Fit', item]
  legendd, item, linestyle=[0, 2, 2, 2, 2], psym=[2, 6, 6, 6, 6], col=[1, 1, 2, 3, 4], /right, /bottom, charsize=1.5


END
