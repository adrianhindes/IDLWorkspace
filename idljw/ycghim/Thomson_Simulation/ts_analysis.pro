
function ts_analysis, dsch, dssys, dscon, dsts, dste, dsne

; Fit all of the scattered signals for each channel in turn

  temes = fltarr(dsch.nch)
  dtemes = temes
  nemes = temes
  dnemes = temes
  chisqr = temes

  for chan=0, dsch.nch-1 do begin

; Independent variable of signal index
    index = where(dssys.usefilt[chan, *])

; Scattered signals for all channels
    signal = dsts.signal[chan, *]

; Background signals for all channels
    bgsig = dsts.bgsig[chan, *]

; Scattered signals for all channels
    scsig = signal - bgsig

; Standard deviations of scattered signals assuming Poisson distribution
    dscsig = sqrt(signal + bgsig)

; Select finite points as valid
    ok = where(scsig[index] gt 0, count)

    if count gt 2 then begin

      ind_ok = index[ok]
      scsig_ok = scsig[ind_ok]
      dscsig_ok = dscsig[ind_ok]

      na = 2
      a = fltarr(na)
      a[0] = 100.
      a[1] = 1e19
      amask = intarr(na)
      amask[*] = 1
      sigma = fltarr(na)

      fitsig = lmbevfit(ind_ok, scsig_ok, dscsig_ok, a, sigma=sigma, chisq=chisq, $
                             function_name = 'chan_sig_function',  chan=chan, $
                             dsch=dsch, dssys=dssys, /double, tol=1e-3, itmax=100, $
                             dscon=dscon, amask=amask)

      temes[chan] = a[0]
      nemes[chan] = a[1]
      dtemes[chan] = sigma[0]
      dnemes[chan] = sigma[1]
      chisqr[chan] = chisq

    endif

  endfor

  dsts = create_struct(dsts, 'temes', temes, 'dtemes', dtemes, 'nemes', nemes, $
                                'dnemes', dnemes, 'chisqr', chisqr)

  return, dsts

end

