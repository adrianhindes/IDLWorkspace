
pro ts_simulation, psplot=psplot, ntm=ntm, rrange=rrange, ncheby=ncheby, iregion=iregion, $
                   itb=itb, etb=etb, ne0=ne0, wste=wste, nchisl=nchisl, te0=te0

  if not keyword_set(psplot) then psplot = 0
  if not keyword_set(ntm) then ntm = 0
  if not keyword_set(rrange) then rrange = [.2, 1.5]
  if not keyword_set(ncheby) then ncheby = 20
  if not keyword_set(nchisl) then nchisl = 5
  if not keyword_set(iregion) then iregion = [1.1, 1.3]
  if not keyword_set(itb) then itb = 0
  if not keyword_set(etb) then etb = 0
  if not keyword_set(ne0) then ne0 = 3e19
  if not keyword_set(te0) then te0 = 1e3
  if not keyword_set(wste) then wste = 0.02
  if not keyword_set(time) then time = 0.3
  if not keyword_set(shot) then shot = 16468

  if ntm then $
    rrange = iregion

; Fundamental constants
  dscon = {c:2.99e8, h:6.62e-34, re:2.8179e-15}

; Major radius array
  rmin = .2
  rmax = 1.5
  r0 = .9

; Model profiles
  nr = 200
  r = findgen(nr) / (nr - 1) * (rmax - rmin) + rmin

; Fitted profiles
  nrfit = nr / 4
  rfit = findgen(nrfit) / (nrfit - 1) * (rmax - rmin) + rmin

; Set up channel locations
  dsch = setup_channels(ntm)

; Select region around island
  isl = where(dsch.rch ge iregion[0] and dsch.rch le iregion[1])
stop

; Read normalised flux from EFIT data
  dspsi = read_psi(shot, time)

; Set up density profile
  dsne = density_profile(dspsi, r, rmin, rmax,  ne0, ntm, etb)

; Set up temperature profile
  dste = temperature_profile(dspsi, r, rmin, rmax, wste, ntm, itb, te0)

; Setup TS system parameters
  dssys = setup_ts_system(dsch, dscon)

; Caculate TS scattering geometry
  dssys = calc_ts_geometry(dsch, dssys)

; Plot plan view of TS scattering geometry
  plot_plan_view, dssys, dsch, psplot

; Calculate profile of bremsstrahlung emissivity
  dssys = brems_emiss(dste, dsne, dssys)

; Simulate TS measurements
  seed = 1
  dsts = ts_measurement(dsch, dssys, dscon, dste=dste, dsne=dsne, $
                                     seed=seed)

; Plot TS parameters
  plot_ts_parameters, dssys, dsch, dsts, psplot

; Simulate TS point-by-point analysis
  dsts = ts_analysis(dsch, dssys, dscon, dsts, dste, dsne)

; Fit the measured Te and Ne profiles with Chebyschev polynomials
  dsfit = ts_poly_fits(dsts, ncheby)

; Simulate TS analysis
  dsfit = ts_profile_fit(dsch, dssys, dscon, dsts, dste, dsne, ncheby)

; Plot the fitted full profiles, psplot
  plot_profile_fit, dsts, dste, dsne, dsfit, psplot

; Perform multiple spline fits to point-by-point analysed data

  nfits = 10

  iltefit = fltarr(nrfit, nfits)
  ilnefit = fltarr(nrfit, nfits)

  wntm = fltarr(nfits)
  rntm = fltarr(nfits)

  seed = 2.

  for i=0, nfits-1 do begin

; Repeated TS measurement on model profiles
  dsts = ts_measurement(dsch, dssys, dscon, dste=dste, dsne=dsne, seed=seed)

; Simulate TS point-by-point analysis
  dsts = ts_analysis(dsch, dssys, dscon, dsts, dste, dsne)

; Cludge to get rest of program working as before
  temes = dsts.temes
  nemes = dsts.nemes
  sdtemes = dsts.temes
  sdnemes = dsts.dnemes

; Weights for spline fits
    wne = 1./sdnemes

; Select valid points
    ok = where(finite(nemes) and finite(wne))

; Spline fit to measurement points
    nefit = nag_aspline(dsch.rch[ok], nemes[ok], xfit=rfit, weights=wne[ok], scale=1)
    nefit = nefit.yfit

; Calculate inverse scale length of fit 
    ilnefit[*, i] = abs(deriv(rfit, nefit) / nefit)

; Chebyshev polynomial fit to island density profile
    dsnech = fit_cheby(dsch.rch[isl], nemes[isl], sdnemes[isl], nchisl)

; Inverse scale length from Chebyshev fit
    ilnech = abs(deriv(dsnech.xfit, dsnech.yfit) / dsnech.yfit)

; Standard deviation of temperaure measurements (same fractional error as density)
    sdtemes = dsts.tech * sdnemes / nemes

; Measured temperature with random fluctuating uncertainty
    temes = dsts.tech + sdtemes * randomn(seed, dsch.nch)

; Allow only positive temperatures
    neg = where(temes lt 0., count)
    if count gt 0 then begin
      temes[neg] = !values.f_nan
      sdtemes[neg] = !values.f_nan
    endif

; Fit the temperature profile

; Weights for spline fits
    wte = 1./sdtemes

; Select valid points
    ok = where(finite(temes) and finite(wte) and wte gt 0)

; Spline fit to measurement points
    tefit = nag_aspline(dsch.rch[ok], temes[ok], xfit=rfit, weights=wte[ok], scale=1)
    tefit = tefit.yfit

; Calculate inverse scale length of fit 
    iltefit[*, i] = abs(deriv(rfit, tefit) / tefit)

; Chebyshev polynomial fit to island temperature profile
    dstech = fit_cheby(dsch.rch[isl], temes[isl], sdtemes[isl], nchisl)

; Inverse scale length from Chebyshev fit
    iltech = abs(deriv(dstech.xfit, dstech.yfit) / dstech.yfit)

; Location and width of island

    ilntm = 2.
    island = where(iltech le ilntm, count)

    if count gt 0 then begin

      i0 = island[0]
      i1 = island[n_elements(island)-1]

      rin = dstech.x[i0]
      rout = dstech.x[i1]

      wntm[i]  = rout - rin
      rntm[i] = (rout + rin) / 2

    endif else begin

      wntm[i] = !values.f_nan
      rntm[i] = !values.f_nan

    endelse

  endfor

; Calculate mean and std dev of inverse scale length

  iltefit_avr = fltarr(nrfit)
  iltefit_std = fltarr(nrfit)

  ilnefit_avr = fltarr(nrfit)
  ilnefit_std = fltarr(nrfit)

  for j=0, nrfit-1 do begin 

    result = moment(iltefit[j, *])

    iltefit_avr[j] = result[0]
    iltefit_std[j] = sqrt(result[1])

    result = moment(ilnefit[j, *])

    ilnefit_avr[j] = result[0]
    ilnefit_std[j] = sqrt(result[1])

  endfor

; Calculate mean and standard deviation of island parameters

  result = moment(rntm, /nan)
  rntm_avr = result[0]
  rntm_std = sqrt(result[1])

  result = moment(wntm, /nan)
  wntm_avr = result[0]
  wntm_std = sqrt(result[1])

  plot_profiles, dste, dsne, dsts, temes, sdtemes, rfit, tefit, iltefit, iltefit_avr, iltefit_std, $
                      nemes, sdnemes, nefit, ilnefit, ilnefit_avr, ilnefit_std, dstech, dsnech, $
                      iltech, ilnech, rrange, psplot, ntm, rntm_avr, rntm_std, wntm_avr, wntm_std

  stop

  return

end
