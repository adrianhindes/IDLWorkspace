;This routine is generated to help studnets on using IDL


FUNCTION gen_rand, npts, norm=norm, uniform=uniform

  default, norm, 0
  default, uniform, 1

  if norm EQ 1 then begin
    f = RANDOMN(seed, npts) ;generate normaly distributed random numbers
  endif else begin
    f = RANDOMU(seed, npts) ;generate uniformly distributed random numbers
  endelse

; calcuate mean, variance, skewness and kurtosis
  stat_moment = MOMENT(f)

; subtract the mean value from f so that f has no DC component
  f = f-stat_moment[0]

; generate the probability density function (PDF) so that we can
; confirm that whether we have correct random numbers
  pdf_f = HISTOGRAM(f, nbins=50, locations=pdf_f_loc)

; create a structure as the return value
  result = {f:f, pdf:pdf_f, loc:pdf_f_loc}

; returne the result
  return, result

END


PRO practice_power

; Generate time array
  npts = 2.0^15.0 ;number of data points (2^15 = 32768 points)
  dt = 0.5*1e-6 ;time resolution is 0.5 usec.
  taxis = FINDGEN(npts)*dt ;generate the time axis

; Generate uniformly distributed random numbers
  result = gen_rand(npts, /uniform)
  fu = result.f
  pdf_fu = result.pdf
  pdf_fu_loc = result.loc

; Plot the results to check the generated random numbers
  window, /free, xsize = 600, ysize=800
  !p.multi = [0, 1, 2]
  plot, taxis*1e6, fu, title='uniformly distributed random numbers', xtitle='Time [usec]', ytitle = 'Values'; Plot the result
  plot, pdf_fu_loc, pdf_fu/npts, title='PDF of uniformly distibuted random numbers', xtitle='Values', ytitle='PDF', psym=2
  !p.multi = 0  

; Generate normaly distributed random numbers
  result = gen_rand(npts, /norm)
  fn = result.f
  pdf_fn = result.pdf
  pdf_fn_loc = result.loc

; Plot the results to check the generated random numbers
  window, /free, xsize=600, ysize=800
  !p.multi = [0, 1, 2]
  plot, taxis*1e6, fn, title='normally distributed random numbers', xtitle='Time [usec]', ytitle = 'Values'; Plot the result
  plot, pdf_fn_loc, pdf_fn/npts, title='PDF of normally distibuted random numbers', xtitle='Values', ytitle='PDF', psym=2
  !p.multi = 0

; Now generate 'structured' random numbers by convolving the random
; numbers with a 'structured' signal.
  freq = 500e3 ;set the frequency to be 500 kHz.
  n_kernel = npts/4.0 ;set the number of kernel points
  t_kernel = findgen(n_kernel)*dt
  kernel = sin(2.0*!PI*freq*t_kernel)
  new_fu = CONVOL(fu, kernel, /edge_zero)
  new_fn = CONVOL(fn, kernel, /edge_zero)

; plot the results to check the 'structure'
  window, /free, xsize=600, ysize=800
  !p.multi = [0, 1, 2]
  plot, taxis*1e6, new_fu, title='Uniformly dist. random numbers with a structure', xtitle='Time [usec]', ytitle='Values'
  plot, taxis*1e6, new_fn, title='Normally dist. random numbers with a structure', xtitle='Time [usec]', ytitle='Values'
  !p.multi = 0

; Now generate the power spectra
; Let's first calculate the frequency domain
; This routine is valid only for npts is even. If it is odd, then you
; must check the validity.
  n21 = npts/2 + 1 ;midpoint+1 is the most negative frequency subscript
  ff = FINDGEN(npts)
  ff[n21] = n21 - npts + FINDGEN(n21-2)
  faxis = ff/(npts*dt)
  faxis = SHIFT(faxis, -n21)

; Generate power spectra for each signals
  FFT_fu = FFT(fu) & power_fu = FFT_fu * CONJ(FFT_fu) & power_fu = SHIFT(power_fu, -n21)
  FFT_fn = FFT(fn) & power_fn = FFT_fn * CONJ(FFT_fn) & power_fn = SHIFT(power_fn, -n21)
  FFT_new_fu = FFT(new_fu) & power_new_fu = FFT_new_fu * CONJ(FFT_new_fu) & power_new_fu = SHIFT(power_new_fu, -n21)
  FFT_new_fn = FFT(new_fn) & power_new_fn = FFT_new_fn * CONJ(FFT_new_fn) & power_new_fn = SHIFT(power_new_fn, -n21)
  
; plot the results
  window, /free, xsize=1000, ysize=1000
  !p.multi=[0, 2, 2]
  plot, faxis*1e-3, power_fu, title='uni. random numbers', xtitle='Freq. [kHz]', ytitle='Power', /ylog
  plot, faxis*1e-3, power_fn, title='norm. random numbers', xtitle='Freq. [KHz]', ytitle='Power', /ylog
  plot, faxis*1e-3, power_new_fu, title='structured uni.random numbers', xtitle='Freq [kHz]', ytitle='Power', /ylog
  plot, faxis*1e-3, power_new_fn, title='structured norm. random numbers', xtitle='Freq [kHz]', ytitle='Power', /ylog
  !p.multi = 0




;stop

END
