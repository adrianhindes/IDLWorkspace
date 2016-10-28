
pro plot_plan_view, dssys, dsch, psplot

; Save system variables
  psys = !p
  xsys = !x
  ysys = !y

; Initialise plotting
  fontsize = 12
  aspectratio = 0.9
  ct = 5

  if psplot then begin
    psfile = 'ts_plan_view.eps'
    sys = ps_init(psfile, fontsize=fontsize,aspect=aspectratio)
    device,bits_per_pixel=8
  endif else $
    sys = plot_init(fontsize=fontsize,aspect=aspectratio)

  loadct,ct
  safe_colors,/first

  !y.omargin = [0, 5]
  !p.multi = [0, 1, 1]

; Initialise plot
  xtitle = '[m]'
  ytitle = '[m]'
  plot, [-2.1, 2.1], [-2.1, 2.1], /nodata, xtitle=xtitle, ytitle=ytitle

; Plot axes
  oplot, !x.crange, [0, 0], linestyle=4
  oplot, [0, 0], !y.crange, linestyle=4

; Plot vessel wall
  draw_circle, 0., 0., 2.0

; Plot central column
  draw_circle, 0., 0., 0.2

; Plot plasma edge (nominal)
  draw_circle, 0., 0., 1.4, linestyle = 2

; Plot plasma axis (nominal)
  draw_circle, 0., 0., 0.9, linestyle = 1

; Plot laser trajectory
  oplot, dssys.laser_pr[0, *], dssys.laser_pr[1, *], col=2

; Plot near viewing locations
  oplot, dssys.view_pr[0, 0, *], dssys.view_pr[1, 0, *], psym=1

; Plot viewing chords
  for i=0, dsch.nch-1 do begin

    xl = dssys.lens_pr[0, dsch.system[i]]
    yl = dssys.lens_pr[1, dsch.system[i]]

    xv = dssys.view_pr[0, dsch.location[i], i]
    yv = dssys.view_pr[1, dsch.location[i], i]

    oplot, [xl, xv], [yl, yv], linestyle=2, col=1+dsch.system[i]

  endfor

; Annotation
  xyouts, .05, .95, 'MAST: TS System - Plan View', /norm

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
