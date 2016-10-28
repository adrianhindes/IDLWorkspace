
pro plot_ts_parameters, dssys, dsch, dsts, psplot

; Save system variables
  psys = !p
  xsys = !x
  ysys = !y

; Initialise plotting
  aspectratio = 0.7
  ct = 5

  if psplot then begin
    psfile = 'plot_ts_parameters.eps'
    sys = ps_init(psfile, fontsize=fontsize,aspect=aspectratio)
    device,bits_per_pixel=8
  endif else $
    sys = plot_init(fontsize=fontsize,aspect=aspectratio)

  loadct,ct
  safe_colors,/first

  !p.multi = [0, 1, 4]

  title ='Scattering angle'
  plot, dsch.rch, 180./!PI * dssys.angle, title=title, psym=4

  scale = 1e-2
  title = 'Scattering length'
  ytitle = '[cm]'
  plot, dsch.rch, dssys.scatlen / scale, title=title, ytitle=ytitle, psym=4

  title = 'Radial resolution'
  ytitle = '[cm]'
  plot, dsch.rch, dssys.drch / scale, title=title, ytitle=ytitle, psym=4

  title = 'Scattered spectra'
  ytitle = '[-]'
  xtitle = '[nm]'
  xrange = [600., 1200.]
  yrange = [0., 1.2]
  plot, dssys.lam, dsts.iscat[*, 0] / max(dsts.iscat[*, 0]), xr = xrange, xs=1, $
                          title=title, xtitle=xtitle, ytitle=ytitle, yr=yrange
  for i=0, dsch.nch-1 do $
    oplot, dssys.lam, dsts.iscat[*, i] / max(dsts.iscat[*, i]), col=1+dsch.system[i]

  for i=0, dssys.nfilt-1 do $
    oplot, dssys.lam, dssys.f_trans[*, i], color=1+i

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

