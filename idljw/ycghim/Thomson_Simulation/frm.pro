
function frm, dspsi, r, rmin, rmax, m, n, rhos, ws, cs, wi, rhoi, ntm

  fr = fltarr(n_elements(r))

  in = where(r lt dspsi.r0)
  out = where(r ge dspsi.r0)  

  rhoin = interpol(dspsi.rho, dspsi.r, r[in])
  rhoout = interpol(dspsi.rho, dspsi.r, r[out])

  bad = where(rhoin gt 1.0, count)
  if count gt 0 then $
    rhoin[bad] = 1.0

  bad = where(rhoout gt 1.0, count)
  if count gt 0 then $
    rhoout[bad] = 1.0

  fr[in] = frho(rhoin, m, n, rhos, ws, cs, wi, rhoi, ntm)
  fr[out] = frho(rhoout, m, n, rhos, ws, cs, wi, rhoi, ntm)

  return, fr

end

