
pro plot_profile_fit, dsts, dste, dsne, dsfit, psplot

; Save system variables
  psys = !p
  xsys = !x
  ysys = !y

; Initialise plotting
  aspectratio = 0.7
  ct = 5

  if psplot then begin
    psfile = 'plot_profile_fit.eps'
    sys = ps_init(psfile, fontsize=fontsize,aspect=aspectratio)
    device,bits_per_pixel=8
  endif else $
    sys = plot_init(fontsize=fontsize,aspect=aspectratio)

  loadct,ct
  safe_colors,/first

  !p.multi = [0,2,2]

  aplot = dsfit.a
  aplot[0:dsfit.nate-1] = aplot[0:dsfit.nate-1] / 1e3
  aplot[dsfit.nate:dsfit.nate+dsfit.nane-1] = aplot[dsfit.nate:dsfit.nate+dsfit.nane-1] / 1e19

  title = 'Fit coefficients'
  plot, aplot, psym=10, title=title

  title = 'Fitted signals'

  plot, dsfit.index, dsfit.signal, psym=10, title=title
  oplot, dsfit.index, dsfit.scsig
  oplot, dsfit.index, dsfit.fitsig, col=2
  oplot, dsfit.index, dsfit.bgsig, col=4
  oplot, dsfit.index, dsfit.signoise, linestyle=2
  oplot, dsfit.index, dsfit.bgnoise, linestyle=2, col=4

  title = 'Te profile'
  plot, dste.r, dste.te, title=title, yr=[0, 1.2*max(dste.te)]
  oplot, dsfit.rfit, dsfit.tefit, col=2
  errorplot, dsts.rch, dsts.temes, dsts.dtemes, /over, /noline

  title = 'Ne profile'
  plot, dsne.r, dsne.nel, title=title, yr=[0, 1.2*max(dsne.nel)]
  oplot, dsfit.rfit, dsfit.nefit, col=2
  errorplot, dsts.rch, dsts.nemes, dsts.dnemes, /over, /noline

; Close the PS plot
  if keyword_set(psplot) then $
    dum=ps_restore(sys) $
  else  $
    dum =plot_restore(sys)

; Restore system variables
  !p = psys
  !x = xsys
  !y = ysys

  return

end


