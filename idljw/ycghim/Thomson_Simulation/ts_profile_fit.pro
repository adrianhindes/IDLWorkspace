
function ts_profile_fit, dsch, dssys, dscon, dsts, dste, dsne, ncheby

; Fit all of the scattered signals for measured n_e and t_e profiles

; Set up indices of used spectral channels
  usefilt = reform(dssys.usefilt, dsts.nsigs)
  index = where(usefilt)

; Scattered and background signal of all channels
  signal = reform(dsts.signal, dsts.nsigs)

; Plasma background signal of all channels
  bgsig = reform(dsts.bgsig, dsts.nsigs)

; Signal noise of all channels
  signoise = reform(dsts.signoise, dsts.nsigs)

; Background noise of all channels
  bgnoise = reform(dsts.bgnoise, dsts.nsigs)

; Select signals from used spectral channels only
  signal = signal[index]
  bgsig = bgsig[index]
  signoise = signoise[index]
  bgnoise = bgnoise[index]

; Scattered signal for used channels
  scsig = signal - bgsig

; Standard deviation of scattered signal assuming a Poisson distribution
  dscsig = sqrt(signal + bgsig)

; Select finite points as valid
  ok = where(scsig gt 0)
  ind_ok = index[ok]
  scsig_ok = scsig[ok]
  dscsig_ok = dscsig[ok]
  bgsig_ok = bgsig[ok]
  signal_ok = signal[ok]
  signoise_ok = signoise[ok]
  bgnoise_ok = bgnoise[ok]

; Use fit coefficients from original fits
  ate = dsts.dstefit.a
  ane = dsts.dsnefit.a

  nate = ncheby
  nane = ncheby

  a = [ate, ane]
  na = nate + nane
  sigma = fltarr(na)

  amask = fltarr(na)
  amask[*] = 1

  fitsig = lmbevfit(ind_ok, scsig_ok, dscsig_ok, a, sigma=sigma, amask=amask, $
                        function_name = 'prof_sig_function', dste=dste, dsne=dsne, $
                        nate=nate, nane=nate, dsch=dsch, dssys=dssys, dscon=dscon, $
                        /double, /debug, tol=1e-3, itmax=1000)

  ate = a[0:nate-1]
  tefit = chebyschev_polynomial(dste.r, ate)

  ane = a[nate:nate+nane-1]
  nefit = chebyschev_polynomial(dsne.r, ane)

  outside = where(dste.r gt max(dsch.rch))
  inside = where(dste.r lt min(dsch.rch))
  tefit[[inside, outside]]  = 0.
  nefit[[inside, outside]] = 0.

  index= indgen(n_elements(ind_ok))
  
  ds = {nane:nane, ane:ane, nate:nate, ate:ate, ind_ok:ind_ok, scsig:scsig_ok, $
           dscsig:dscsig_ok, fitsig:fitsig, sigma:sigma, rfit:dste.r, tefit:tefit, nefit:nefit, $
           a:a, index:index, signal:signal_ok, signoise:signoise_ok, bgsig:bgsig_ok, $
           bgnoise:bgnoise_ok}

  return, ds

end

