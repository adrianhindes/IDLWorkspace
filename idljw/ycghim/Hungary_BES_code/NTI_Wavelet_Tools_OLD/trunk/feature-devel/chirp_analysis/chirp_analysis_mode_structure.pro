;INPUTS
;------

;amplitudes:	amplitudes of the mode measured with different SXR channels
;timeax:	time axis of amplitudes

pro chirp_analysis_mode_structure, timeax = timeax, amplitudes = amplitudes, rho = rho

restore, 'amp_test.sav' 
rho1 = [0.234195, 0.149670, 0.0551692]
rho2 = [0.0424668, 0.146960]

pg_initgraph
loadct, 5

;shade_surf, amplitudes, rho, timeax, ax = 45

legend = strarr(7)
legend(0) = pg_num2str(timeax(0), length = 7) + 's'
legend(1) = pg_num2str(timeax(78), length = 7) + 's'
legend(2) = pg_num2str(timeax(2*78), length = 7) + 's'
legend(3) = pg_num2str(timeax(3*78), length = 7) + 's'
legend(4) = pg_num2str(timeax(4*78), length = 7) + 's'
legend(5) = pg_num2str(timeax(5*78), length = 7) + 's'
legend(6) = pg_num2str(timeax(465), length = 7) + 's'

nti_wavelet_plot_1d, rho1, transpose(amplitudes(0:2,[0,78,2*78,3*78,4*78,5*78,465])), $
  xdouble = rho2, ydouble = transpose(amplitudes(3:4,[0,78,2*78,3*78,4*78,5*78,465])), $
  xrange = [0.,0.25], yrange = [0,max(amplitudes)], legend = legend, $
  title = 'Eigenfunctions', xtitle = 'Rho', ytitle = 'Amplitude', info = info, psym = -2



stop


interrho = (findgen(101)/100)*(rho(n_elements(rho)-1) - rho(0)) + rho(0)
interamps = fltarr(101,n_elements(timeax))
for i = 0,n_elements(timeax)-1 do begin
  interamps(*,i) = interpol(amplitudes(*,i), rho, interrho, /spline)
endfor

shade_surf, interamps, interrho, timeax, ax = 25

stop

end