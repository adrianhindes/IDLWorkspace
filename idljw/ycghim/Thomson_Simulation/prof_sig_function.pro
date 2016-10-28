
pro prof_sig_function, x, a, f, pder, dste=dste, dsne=dsne, nate=nate, nane=nane, $
                                 dsch=dsch, dssys=dssys, dscon=dscon, amask=amask

  na = n_elements(a)
  ate = a[0:nate-1]

  dstefit = dste
  dstefit.te = chebyschev_polynomial(dstefit.r, ate, pder_te)

  ane = a[nate:nate+nane-1]

  dsnefit = dsne
  dsnefit.nel = chebyschev_polynomial(dsnefit.r, ane, pder_ne)

  dsts = ts_measurement(dsch, dssys, dscon, dste=dstefit, dsne=dsnefit)

; Subtract measured background signals from scattered signals
  f = reform(dsts.scsig, dsts.nsigs)

; Average the partial derivatives over the scattering lengths
  pder_tem = fltarr(dsch.nch, nate)
  pder_nem = fltarr(dsch.nch, nane)
  dsig_da = fltarr(dsch.nch, dssys.nfilt, na)

  for i=0, dsch.nch-1 do begin

    ind = where(dsne.r ge dsch.rch[i] - dssys.drch[i] and $
                       dsne.r le dsch.rch[i] + dssys.drch[i])
    nind = n_elements(ind)

    for j=0, nate-1 do $
      pder_tem[i, j] = total(pder_te[ind, j]) / nind

    for j=0, nate-1 do $
      pder_nem[i, j] = total(pder_ne[ind, j]) / nind

    dsig_date = reform(pder_tem[i, *]) # reform(dsts.dsig_dte[i, *])

    dsig_dane = reform(pder_nem[i, *]) # reform(dsts.dsig_dne[i, *])

    dsig_da[i, *, *] = transpose([dsig_date, dsig_dane])

  endfor

; Reform into 2D array
  dsig_dan = fltarr(dsch.nch*dssys.nfilt, na)
  for i=0, na-1 do $
    dsig_dan[*, i] = reform(dsig_da[*, *, i], dsch.nch*dssys.nfilt)
  dsig_da = dsig_dan

; Select only signals for which initial signal is gt 0
  ok = fix(x)
  nok = n_elements(ok)
  f = f[ok]
  pder = fltarr(nok, na)

  for i=0, na-1 do $
    pder[*, i] = dsig_da[ok, i]

  return

end

