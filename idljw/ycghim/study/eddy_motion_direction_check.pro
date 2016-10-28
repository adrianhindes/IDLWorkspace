
PRO eddy_motion_direction_check

  xaxis = [-10:10:0.05]
  taxis = [0:50:0.05] ;timestep = 0.05
  
  nx = N_ELEMENTS(xaxis)
  nt = N_ELEMENTS(taxis)
  time_step = 0.05

  lx = 0.5
  vel = 0.2

  f = FLTARR(nx, nt)

  for i=0L, nx - 1 do begin
    f[i, *] = exp(-(xaxis[i]-vel*taxis)^2.0/(2.0*lx^2.0))
  endfor
  
  xmin = MIN(xaxis, max = xmax)
  ymin = MIN(f, max = ymax)

  window, /free & plot, xaxis, f[*, 0], xrange = [xmin, xmax], yrange = [ymin, ymax], /nodata
  for i=0L, nt - 1 do begin
    plot, xaxis, f[*, i], xrange = [xmin, xmax], yrange = [ymin, ymax]
    wait, 0.001
  endfor

  positions = [2.0, 1.0, 0.0]
  npos = N_ELEMENTS(positions)

  inx_pos = lonarr(npos)
  for i=0, npos-1 do inx_pos[i] = WHERE(xaxis eq positions[i])
  color = ['white', 'red', 'blue']

  for i=0, npos - 1 do oplot, [positions[i], positions[i]], !y.crange, col=truecolor(color[i]), linestyle=2

  f_pos = FLTARR(npos, nt)
  for i=0, npos - 1 do f_pos[i, *] = REFORM(f[inx_pos[i], *])

  inx_lag = [-(nt-5):(nt-5):1]
  lag_time = inx_lag*time_step

  corr = FLTARR(npos, N_ELEMENTS(lag_time))
  for i=0, npos - 1 do corr[i, *] = c_correlate(f_pos[0, *], f_pos[i, *], inx_lag)


  window, /free
  plot, lag_time, corr[0, *], col=truecolor(color[0])
  for i=1, npos-1 do oplot, lag_time, corr[i, *], col=truecolor(color[i])
  



stop

END
