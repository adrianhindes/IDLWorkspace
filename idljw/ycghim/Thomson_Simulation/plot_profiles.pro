
pro plot_profiles, dste, dsne, dsts, temes, sdtemes, rfit, tefit, iltefit, iltefit_avr, iltefit_std,  $
                          nemes, sdnemes, nefit, ilnefit, ilnefit_avr, ilnefit_std, dstech, dsnech, $
                          iltech, ilnech, rrange, psplot, ntm, rntm_avr, rntm_std, wntm_avr, wntm_std

; Save system variables
  psys = !p
  xsys = !x
  ysys = !y

; Initialise plotting
  aspectratio = 0.7
  ct = 5

  if psplot then begin
    psfile = 'plot_profiles.eps'
    sys = ps_init(psfile, fontsize=fontsize,aspect=aspectratio)
    device,bits_per_pixel=8
  endif else $
    sys = plot_init(fontsize=fontsize,aspect=aspectratio)

  loadct,ct
  safe_colors,/first

; Plot profiles
  if ntm then begin
    fontsize = 12
    !p.multi = [0, 2, 2]
  endif else begin
    fontsize = 14
    !p.multi = [0, 2, 3]
  endelse
  !p.charsize = 1.
  !p.thick = 1

; Plot the electron density profile

  title = 'Electron density'
  xtitle = 'R [m]'
  ytitle = '[10!E19!N m!E-3!N]'
  yscale = 1e19
  yrange = [0, 1.2 * max(dsne.nel)/yscale]
  plot, rrange, yrange, /nodata, title=title, xtitle=xtitle, ytitle=ytitle, xs=1

  oplot, dsne.r, dsne.nel/yscale, col=3, thick=2

  errorplot, dsts.rch, dsts.drch, nemes/yscale, sdnemes/yscale, /over, psym=3

  oplot, rfit, nefit / yscale, thick=2

  if ntm then $
    oplot, dsnech.x, dsnech.yfit/yscale, col=6, thick=2

; Plot the electron temperature profile

  title = 'Electron temperature'
  xtitle = 'R [m]'
  ytitle = '[eV]'
  yrange = [0, 1.2 * max(dste.te)]
  plot, rrange, yrange, /nodata, title=title, xtitle=xtitle, ytitle=ytitle, xs=1

  oplot, dste.r, dste.te, col=2, thick=2

  errorplot, dsts.rch, dsts.drch, temes, sdtemes, /over, psym=3, ylog=1

  oplot, rfit, tefit, thick=2

  if ntm then $
    oplot, dstech.x, dstech.yfit, col=6, thick=2

; Plot the inverse density scale length

  title = '|1/L!Dne!N|'
  xtitle = 'R [m]'
  ytitle = '[m!E-1!N]'

  if ntm then begin
    ylog=0
    yrange=[0, 5]
  endif else begin
    ylog=1
    yrange=[.1, 100.]
  endelse

  plot, rrange, yrange, /nodata, title=title, xtitle=xtitle, ytitle=ytitle, xs=1, ylog=ylog

  if ntm then begin

    oplot, [rntm_avr, rntm_avr], !y.crange, linestyle=2
    oplot, [rntm_avr-rntm_std/2, rntm_avr-rntm_std/2], !y.crange, linestyle=1 
    oplot, [rntm_avr+rntm_std/2, rntm_avr+rntm_std/2], !y.crange, linestyle=1

    errorplot, [rntm_avr], [(wntm_avr-wntm_std)/2], [total(!y.crange)/2], noyerror=1, /over
    errorplot, [rntm_avr], [(wntm_avr+wntm_std)/2], [total(!y.crange)/2], noyerror=1, /over

  endif

  oplot, dsne.r, dsne.ilne, col=3, thick=2

  oplot, rfit, ilnefit, thick=2

  errorplot, rfit, ilnefit_avr, ilnefit_std, /over, ylog=1

  if ntm then $
    oplot, dsnech.x, ilnech, col=6, thick=2

; Plot the inverse temperature scale length

  title = '|1/L!DTe!N|'
  xtitle = 'R [m]'
  ytitle = '[m!E-1!N]'

  if ntm then begin
    ylog=0
    yrange=[.0, 5.]
  endif else begin
    ylog=1
    yrange=[.1, 100.]
  endelse

  plot, rrange, yrange, /nodata, title=title, xtitle=xtitle, ytitle=ytitle, xs=1, ylog=ylog

  if ntm then begin

    oplot, [rntm_avr, rntm_avr], !y.crange, linestyle=2
    oplot, [rntm_avr-rntm_std/2, rntm_avr-rntm_std/2], !y.crange, linestyle=1 
    oplot, [rntm_avr+rntm_std/2, rntm_avr+rntm_std/2], !y.crange, linestyle=1

    errorplot, [rntm_avr], [(wntm_avr-wntm_std)/2], [total(!y.crange)/2], noyerror=1, /over
    errorplot, [rntm_avr], [(wntm_avr+wntm_std)/2], [total(!y.crange)/2], noyerror=1, /over

    str = 'W!DNTM!N = ' + string(1e2*wntm_avr, format='(f5.2)')+'+/-' + $
                                         string(1e2*wntm_std, format='(f5.2)')+' cm'
    xyouts, .67, .40, str, /norm, charsize=.8

  endif

  oplot, dste.r, dste.ilte, col=2, thick=2

  oplot, rfit, iltefit, thick=2

  errorplot, rfit, iltefit_avr, iltefit_std, /over, ylog=1

  if ntm then $
    oplot, dstech.x, iltech, col=6, thick=2

; Plot the ratio of model to fitted inverse scale lengths

  if not ntm then begin

    ilneint = interpol(dsne.ilne, dsne.r, rfit)

    xtitle = 'R [m]'
    ytitle = '[-]'
    title = 'L!Dne, fit!N/L!Dne!N'
    yrange = [.1, 10.]
    plot_io, rfit, ilneint/ilnefit, yr=yrange, xtitle=xtitle, ytitle=ytitle, title=title, xr=rrange, xs=1
    oplot, rrange, [1, 1], linestyle=2

    ilteint = interpol(dste.ilte, dste.r, rfit)

    xtitle = 'R [m]'
    ytitle = '[-]'
    title = 'L!DTe, fit!N/L!DTe!N'
    yrange = [.1, 10.]
    plot_io, rfit, ilteint/iltefit, yr=yrange, xtitle=xtitle, ytitle=ytitle, title=title, xr=rrange, xs=1
    oplot, rrange, [1, 1], linestyle=2

  endif

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


