;This procedure generate the BES movie and saves the file.

PRO bes_make_movie, shot, trange=trange, freq_filter=freq_filter

; This program generates a movie of BES: Normalised dn/n.

  default, trange, [1.000000, 1.001000]
  default, freq_filter, [20, 100]*1e3
  default, dt, 0.5e-6

; Read the bes data
  bes_data = bes_read_data(shot, '1-1', trange=trange)
  if bes_data.err lt 0 then begin
    PRINT, result.errmsg
    RETURN
  endif
; check the BES parameters
  orient = bes_data.orientation ;if 0, then 8radial x 4poloidal; if 1, then 4radial x 8 poloidal
  raw_time = bes_data.tvector
  nraw_time = N_ELEMENTS(raw_time)
  nR = 8
  nZ = 4
  raw_data = FLTARR(nR, nZ, nraw_time)
  bes_position = FLTARR(nR, nZ, 3)
  for i = 0, nR - 1 do begin
    for j = 0, nZ - 1 do begin
      chname = string(j+1, format='(i0)') + '-' + string(i+1, format='(i0)')
      bes_data = bes_read_data(shot, chname, trange=trange)
      raw_data[i, j, *] = bes_data.data
      bes_position[i, j, *] = bes_data.pos
      if chname eq '1-1' then position11 = [bes_position[i, j, 0], bes_position[i, j, 1]]
      if chname eq '1-8' then position18 = [bes_position[i, j, 0], bes_position[i, j, 1]]
      if chname eq '4-1' then position41 = [bes_position[i, j, 0], bes_position[i, j, 1]]
      if chname eq '4-8' then position48 = [bes_position[i, j, 0], bes_position[i, j, 1]]
    endfor
  endfor

; Calcualte the average values
  avg_data = FLTARR(nR, nZ)
  avg_data = TOTAL(raw_data, 3)/nraw_time

; Frequency filter the signal and calculate dn/n
  PRINT, 'Frequency filtering the signal from '+string(freq_filter[0]*1e-3, format='(f0.2)') + $
         ' to ' + string(freq_filter[1]*1e-3, format='(f0.2)') +'kHz...', format='(A,$)'
  for i=0, nR-1 do begin
    for j=0, nZ-1 do begin
      filtered = yc_freq_filter(raw_data[i, j, *], dt, freq_filter[0], freq_filter[1])
      if i eq 0 and j eq 0 then begin
        ntime = filtered.inx_nonzero_end - filtered.inx_nonzero_begin + 1
        data = FLTARR(nR, nZ, ntime)
        dn_n = FLTARR(nR, nZ, ntime)
        time = raw_time[filtered.inx_nonzero_begin:filtered.inx_nonzero_end]
      endif
      data[i, j, *] = filtered.data[filtered.inx_nonzero_begin:filtered.inx_nonzero_end]
      dn_n[i, j, *] = data[i, j, *]/avg_data[i, j]
    endfor
  endfor
  PRINT, 'Done!'

; Interpolate the dn_n which are irregular.
  case orient of 
    0: begin nx = 301 & ny = 151 & end
    1: begin nx = 151 & ny = 301 & end
  endcase
  xmin = MIN(bes_position[*, *, 0], MAX=xmax)
  ymin = MIN(bes_position[*, *, 1], MAX=ymax)
  xout = FINDGEN(nx)*(xmax - xmin)/(nx-1) + xmin
  yout = FINDGEN(ny)*(ymax - ymin)/(ny-1) + ymin
  new_dn_n = FLTARR(nx, ny, ntime)
;  faultVertices = [ [position11[0], position11[1]], $
;                    [position18[0], position18[1]], $
;                    [position48[0], position48[1]], $
;                    [position41[0], position41[1]], $
;                    [position11[0], position11[1]] ]
;  faultConnectivity = [4, 0, 1, 2, 3, -1]
  PRINT, 'Griding the data...', format='(A,$)'
  for i=0L, ntime - 1 do begin
    new_dn_n[*, *, i] = GRIDDATA(bes_position[*, *, 0], bes_position[*, *, 1], dn_n[*, *, i], /RADIAL_BASIS_FUNCTION, /GRID, xout=xout, yout=yout);, $
;                                 fault_polygons = faultConnectivity, fault_xy = faultVertices, missing = 100)
  endfor
  x11 = position11[0] & x18 = position18[0] & x41 = position41[0] & x48 = position48[0]
  y11 = position11[1] & y18 = position18[1] & y41 = position41[1] & y48 = position48[1]
  if orient eq 0 then begin
    in_line_eq = [(y18-y48)/(x18-x48), (x18*y48-x48*y18)/(x18-x48)] ;slope and y-axis crossing-point
    out_line_eq = [(y11-y41)/(x11-x41), (x11*y41-x41*y11)/(x11-x41)]
    up_line_eq = [(y18-y11)/(x18-x11), (x18*y11-x11*y18)/(x18-x11)]
    down_line_eq = [(y48-y41)/(x48-x41), (x48*y41-x41*y48)/(x48-x41)]
  endif else begin
    in_line_eq = [(y48-y41)/(x48-x41), (x48*y41-x41*y48)/(x48-x41)]
    out_line_eq = [(y18-y11)/(x18-x11), (x18*y11-x11*y18)/(x18-x11)]
    up_line_eq = [(y18-y48)/(x18-x48), (x18*y48-x48*y18)/(x18-x48)]
    down_line_eq = [(y11-y41)/(x11-x41), (x11*y41-x41*y11)/(x11-x41)]
  endelse
  for i=0L, nx-1 do begin
    yinx = WHERE( (yout GE in_line_eq[0]*xout[i]+in_line_eq[1]) AND (yout LE out_line_eq[0]*xout[i]+out_line_eq[1]) AND $
                  (yout GE down_line_eq[0]*xout[i]+down_line_eq[1]) AND (yout LE up_line_eq[0]*xout[i]+up_line_eq[1]), $ 
                  complement = cyinx, ncomplement = cnt_cyinx )
    if cnt_cyinx gt 0 then new_dn_n[i, cyinx, *] = !values.f_nan
  endfor
  PRINT, 'Done!'

  ycshade, new_dn_n, xout, yout, time

END
