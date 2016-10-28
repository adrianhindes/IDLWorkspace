; this procedures read the bes data plots all (32 channels) bes data

pro plot_all_bes_data, shot, trange=trange, freq_range=freq_range

; constant in the code
  dt = 0.5e-6 ;BES time step, i.e, 2MHz

; set datapath and data source
  if shot LT 7092 then begin ;KSTAR 2011 campaign
    datapath = '/media/DATA/APDCAM'
  endif else begin ;KSTAR 2012 campaign
    datapath = '/media/DATA/APDCAM'
  endelse 
  data_source = 32 ;for KSTAR

; set the channel number
  column = [8, 7, 6, 5, 4, 3, 2, 1]
  row = [1, 2, 3, 4]
  ncol = N_ELEMENTS(column)
  nrow = N_ELEMENTS(row)

; Set the channel name in string
  ch = strarr(nrow, ncol)
  for i=0, nrow - 1 do begin
    for j=0, ncol-1 do begin
      ch[i, j] = strcompress(string(row[i]), /remove_all) + '-' + strcompress(string(column[j]), /remove_all)
    endfor
  endfor

; get the data
  PRINT, 'Reading the BES data...', format='(A,$)'
  for i=0, nrow - 1 do begin
    for j=0, ncol - 1 do begin
      ch_name = 'BES-' + ch[i, j]
      PRINT, ch_name + ' ', format='(A,$)'      
      get_rawsignal, shot, ch_name, t, d, data_source=data_source, datapath=datapath, timerange=trange, /nocalibrate, errormess=errmsg
      if i eq 0 and j eq 0 then begin
        data = fltarr(nrow, ncol, n_elements(t))
        time = t
      endif
      data[i, j, *] = d
    endfor
  endfor 
  PRINT, 'Done!'
  
; frequency filter the data
  if DEFINED(freq_range) then begin
    PRINT, 'Frqeuency filtering...', format='(A, $)'
    filtered_data = fltarr(nrow, ncol, n_elements(t))
    for i=0, nrow - 1 do begin
      for j=0, ncol - 1 do begin
        PRINT, ch[i, j]+' ', format='(A,$)'
        temp_data = yc_freq_filter(data[i, j, *], dt, freq_range[0], freq_range[1])
        filtered_data[i, j, *] = temp_data.data
      endfor
    endfor
  PRINT, 'Done!'
  endif else begin
    filtered_data = data
  endelse

; plot 
  !p.multi = [0, 8, 4]
  loadct, 5
  safe_colors, /first
  window, /free, xsize=1600, ysize=800
  ymax = max(filtered_data, min=ymin)
  ymax = ymax[0]*1.1
  ymin = ymin[0]*1.1
  for i=0, nrow - 1 do begin
    for j=0, ncol-1 do begin
      plot, time, filtered_data[i, j, *], yr=[0.0, ymax], title=strcompress(string(shot)+':'+string(ch[i, j])), xstyle=1, ystyle=1, charsize=1.5
    endfor
  endfor


end
