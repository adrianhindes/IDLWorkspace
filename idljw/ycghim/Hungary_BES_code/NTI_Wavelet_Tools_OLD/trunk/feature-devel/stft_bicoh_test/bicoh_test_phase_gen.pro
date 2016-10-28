function bicoh_test_phase_gen, length = length, dt = dt, blocknum = blocknum, deviation = deviation

;Generate oscillating phase for the signal
;-----------------------------------------

  nti_wavelet_default, length, 0.01		;in sec
  nti_wavelet_default, dt, 5e-7		;sampling time
  nti_wavelet_default, blocknum, 20.	;number of blocks
  nti_wavelet_default, deviation, 1		;deviation of phase

  ;Number of datapoints
  dtp = round(length/dt)
  ;Number of datapoints in a block
  blocksize = round(dtp/blocknum)
  ;Time vector of one block
  block = dindgen(blocksize)/(blocksize-1)*(length/blocknum)
  ;Grad phases of the blocks
  dphi = deviation*randomn(seed,blocknum,/NORMAL)

  ;Phase vector
  phi=dindgen(dtp)
  phi[0:blocksize-1] = dphi[0]*block
  for i=1L,blocknum-1 do begin
    phi[i*blocksize:(i+1)*blocksize-1]=phi[i*blocksize-1]+dphi[i]*block
  end
  
  ;Return phase vector
  return, phi

end