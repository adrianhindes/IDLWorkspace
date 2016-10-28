; This procedure plots BES data from all channels for a specified time window

PRO bes_plot_all_ch_data, shot, trange=trange, freq_filter = freq_filter, filter_radiation_pulses=filter_radiation_pulses, $
                                fusion01=fusion01, bes03=bes03, error_out = error_out

;******************************************************************************************************
; PROCEDURE: bes_plot_all_ch_data                                                                     *
; Author   : Young-chul Ghim                                                                          *
; Date     : 23rd. Sep. 2014                                                                          *
;******************************************************************************************************
; PURPOSE  :                                                                                          *
;   1. To plot BES data from all channels within a specified time window                              *
;******************************************************************************************************
; INPUT parameters                                                                                    *
;     shot: <integer>: Shot number                                                                    *
; Keywords                                                                                            *
;     trange: two element vector <floating>: time range to be read                                    *
;         if trange is not specified, then it reads from the shot start time to end time              *
;     freq_filter: two element vector <floating>: frequency range to be filtered in [Hz]              *
;     filter_radiation_pulses: <floating>                                                             *
;     fusion01: <0 or 1> If this is set, then the data is read from fusion01.kaist.ac.kr server       *
;     bes03:    <0 or 1> If this is set, then the data is read from BES03 server on KSTAR             *
;        NOTE: default read location is fusion01                                                      *
;     error: output --> if 0 then no error. if 1 then error.
;******************************************************************************************************
; Return value                                                                                        *
;  None                                                                                               *
;******************************************************************************************************
; Examples                                                                                            *
;    bes_plot_all_ch_data, 9197, trange=[1.2, 1.3], filter_radia=0.02, /fusion01                      *
;******************************************************************************************************

  default, error_out, 0
  default, filter_radiation_pulses, 0.02
  default, dt, 0.5e-6
  default, freq_filter, [0.0, 1.0e6]

  nrow = 8
  ncol = 4

  inx_row = INDGEN(nrow) + 1
  inx_col = INDGEN(ncol) + 1

;Read the BES data
  for i=0, nrow - 1 do begin
    for j=0, ncol -1 do begin
      chname = STRING(inx_col[j], format='(i0)') + '-' + STRING(inx_row[i], format='(i0)')
      data_struct = bes_read_data(shot, chname, trange=trange, freq_filter = freq_filter, filter_rad=filter_radiation_pulses, fusion01=fusion01, bes03=bes03)
      if data_struct.err ne 0 then begin
        print, 'Failed to read the data'
        error_out = 1
        return
      endif
      if i eq 0 and j eq 0 then begin
        ndata = N_ELEMENTS(data_struct.tvector)
        data = FLTARR(nrow, ncol, ndata)
        time = data_struct.tvector
 ;       orientation = data_struct.orientation ;0:horizontal, 1:vertical, -1:unknown
      endif
      data[i, j, *] = data_struct.data
    endfor
  endfor

; Frequency filter the signal
;  PRINT, 'Frequency filtering starts...', format='(A,$)'
;  for i=0, nrow - 1 do begin
;    for j=0, ncol - 1 do begin
;      PRINT, STRING(inx_col[j], format='(i0)') + '-' + STRING(inx_row[i], format='(i0)') + ' ', format='(A,$)'
;      temp_data = REFORM(raw_data[i, j, *])
;      filtered_data_struct = yc_freq_filter(temp_data, dt, freq_filter[0], freq_filter[1])
;      if i eq 0 and j eq 0 then begin 
;        inx_start = filtered_data_struct.inx_nonzero_begin
;        inx_end = filtered_data_struct.inx_nonzero_end
;        ndata = inx_end - inx_start + 1
;        data = FLTARR(nrow, ncol, ndata)        
;        time = raw_time[inx_start : inx_end]
;      endif
;      data[i, j, *] = filtered_data_struct.data[inx_start : inx_end]
;    endfor
;  endfor
;  PRINT, 'Done!'

; plot the data
  ymax = MAX(data, MIN=ymin)
  xmax = MAX(time, MIN=xmin)
  yrange = [0.0, ymax]
  xrange = [xmin, xmax]
  !p.multi = [0, nrow, ncol]
  loadct, 5
  safe_colors, /first

  window, /free, xs=2000, ys=1000
  for j=0, ncol - 1 do begin
    for i=0, nrow - 1 do begin
      title = STRING(shot, format='(i0)') + ': ' + STRING(ncol-j, format='(i0)') + '-' + STRING(nrow-i, format='(i0)')
      plot, time, data[nrow-i-1, ncol-j-1, *], xr=xrange, yr=yrange, $
            xtitle = 'Time [sec]', ytitle = '[V]', title = title, xstyle=1
    endfor
  endfor

  !p.multi = 0

END
