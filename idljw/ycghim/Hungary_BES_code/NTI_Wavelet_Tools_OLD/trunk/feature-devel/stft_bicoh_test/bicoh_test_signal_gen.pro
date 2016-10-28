pro bicoh_test_signal_gen

;Generate oscillating phase for the signal
;-----------------------------------------

  length = 0.01		;in sec
  dt = 5e-6		;sampling time
  blocknum = 20.	;number of blocks
  deviation = 750		;deviation of phase

  phi_1 = bicoh_test_phase_gen(length = length, dt = dt, blocknum = blocknum, deviation = deviation)
  phi_2 = bicoh_test_phase_gen(length = length, dt = dt, blocknum = blocknum, deviation = deviation)
  phi_3 = bicoh_test_phase_gen(length = length, dt = dt, blocknum = blocknum, deviation = deviation)

;Generate signal
;---------------

  f1 = 1d4	;in Hz
  f2 = 1.7d4	;in Hz
  
  timeax = dindgen(round(length/dt))/(round(length/dt)-1)*length
  data = 	sin(2*!DPI*f1*timeax + phi_1) + $
		sin(2*!DPI*f2*timeax + phi_2) + $
		sin(2*!DPI*(f1 + f2)*timeax + phi_3) + $
		0.1*randomn(seed, n_elements(timeax), /normal)

;Save data
;---------
  
  channels = ['T1','T2']
  coord_history = 'Loaded_with_MTR'
  data = [[data],[data]]
  data_history = 'Simulated, oscillating phase'
  expname = 'STFT_BICOH'
  phi = [0.,0.]
  shotnumber = 0L
  theta = [0.,0.]
  timeax = timeax

  save, filename = 'bicoh_test_signal.sav', channels, coord_history, data, data_history, $
    expname, phi, shotnumber, theta, timeax

end