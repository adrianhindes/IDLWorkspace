
function ts_measurement, dsch, dssys, dscon, dste=dste, dsne=dsne, $
                                       single=single, chan=chan, tel=tel, nel=nel, seed=seed, $
                                       ebrems=ebrems

  if not keyword_set(single) then single = 0

  if single then begin

    nch = 1
    chans = intarr(nch)
    chans[0] = chan

    tech = fltarr(nch)
    tech[0] = tel

    nech = fltarr(nch)
    nech[0] = nel

  endif else begin

    nch = dsch.nch
    chans = indgen(nch)

; Average density and density weighted temperature in each channel
    nech = fltarr(nch)
    tech = fltarr(nch)

    for i=0, nch-1 do begin

      ind = where(dsne.r ge dsch.rch[i] - dssys.drch[i] and $
                         dsne.r le dsch.rch[i] + dssys.drch[i])

      nind = n_elements(ind)

      nech[i] = total(dsne.nel[ind]) / nind

      tech[i] = total(dsne.nel[ind] * dste.te[ind]) / total(dsne.nel[ind])

    endfor

  endelse

; Classical electron cross-section
  dsdomg = dscon.re*dscon.re

; Number of incident photons
  nphotons = dssys.laser_energy * dssys.lam0 * 1e-9 / (dscon.c*dscon.h)

; Calculate solid angle for all channels
  domg = !Pi / (4. * dssys.f_im[dsch.system]^2)

; Calculate image area for all channels
  darea = dssys.dxim[dsch.system] * dssys.dzim[dsch.system]

; Calculate scattered signal in each channel

; Number of scattered photons
  nscat = nech * dsdomg * domg[chans] * dssys.scatlen[chans] * nphotons * dssys.trans

; Calculate average of bremsstrahlung emissivity over profile
  ebrems_mean = total(dssys.ebrems, /nan) / n_elements(dssys.ebrems)

; Plasma background signal intensity [nm^-1]
  ibg = fltarr(dssys.nlam, nch)
  
  for i=0, nch-1 do $
    ibg[*, i] = dssys.bgfact * dssys.trans * ebrems_mean * domg[chans[i]] * darea[chans[i]] * $
                   dssys.dtgate * dssys.dlview / dssys.lam

; Calculate scattered intensity spectra and derivative with T_e
  iscat = fltarr(dssys.nlam, nch)
  discat_dte = fltarr(dssys.nlam, nch)

  for i=0, nch-1 do begin

    iscat[*, i] = selden_matoba(tech[i], dssys.lam, dssys.angle[chans[i]], dssys.lam0)

    discat_dte[*, i] = selden_matoba(tech[i], dssys.lam, dssys.angle[chans[i]], dssys.lam0, /dte)

  endfor

; Calculate signal in each spectral channel

  nsigs = nch * dssys.nfilt
  signal = fltarr(nch, dssys.nfilt)
  signoise = fltarr(nch, dssys.nfilt)
  bgnoise = fltarr(nch, dssys.nfilt)
  scsig = fltarr(nch, dssys.nfilt)
  bgsig = fltarr(nch, dssys.nfilt)
  dsig_dte = fltarr(nch, dssys.nfilt)
  dsig_dne = fltarr(nch, dssys.nfilt)

  for i=0, nch-1 do begin

    for j=0, dssys.nfilt-1 do begin

      scsig[i, j] = dssys.usefilt[chans[i], j] * nscat[i] * dssys.dlam / dssys.lam0^2 * dssys.qeff * $
                       total(dssys.f_trans[*, j] * dssys.lam * iscat[*, i], /nan)

      bgsig[i, j] = dsch.multi[chans[i]] * dssys.usefilt[chans[i], j] * dssys.dlam * dssys.qeff * $
                        total(dssys.f_trans[*, j] * ibg[*, i], /nan)

      dsig_dne[i, j] =  scsig[i, j] / nech[i]

      dsig_dte[i, j] = dssys.usefilt[chans[i], j] * nscat[i] * dssys.dlam / dssys.lam0^2 * dssys.qeff * $
                            total (dssys.f_trans[*, j] * dssys.lam * discat_dte[*, i], /nan)

    endfor

  endfor

; Set measured signals to zero that are less than one detected photon

  iz = where(scsig lt 1., count)
  if count gt 0 then $
    scsig[iz] = 0.

  iz = where(bgsig lt 1., count)
  if count gt 0 then $
    bgsig[iz] = 0.

; Add plasma background to scattered signals
  signal = scsig + bgsig

; Generate random Poisson noise on scattered and background signals and add 
; random noise component

  if keyword_set(seed) then begin

    for i=0, nch-1 do begin

      for j=0, dssys.nfilt-1 do begin

        if signal[i, j] gt 0. then $
          signal[i, j] = randomn(seed, 1, poisson=signal[i, j])

        if bgsig[i, j] gt 0. then $
          bgsig[i, j] = randomn(seed, 1, poisson=bgsig[i, j])

        if dssys.noise gt 0. then $
          signoise[i, j] = dssys.f_noise * randomn(seed, 1, poisson=dssys.noise)

        if dssys.noise gt 0. then $
          bgnoise[i, j] = dssys.f_noise * randomn(seed, 1, poisson=dssys.noise)

      endfor

    endfor

    signal = signal + signoise

    bgsig = bgsig + bgnoise

  endif

  ds = {nech:nech, tech:tech, nscat:nscat, iscat:iscat, discat_dte:discat_dte, $
           signal:signal, dsig_dte:dsig_dte, dsig_dne:dsig_dne, nsigs:nsigs, $
           rch:dsch.rch, drch:dssys.drch, ibg:ibg, bgsig:bgsig, scsig:scsig, $
           signoise:signoise, bgnoise:bgnoise}

  return, ds

end

