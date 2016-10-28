; This function returns a structured data from a binary file taken from NI digitiser

FUNCTION read_ni_binary, plot=plot, avg_plot = avg_plot, offset_time = offset_time

  result = {err:0, errmsg:''}

  default, offset_time, -10 ;First trigger from the KSTAR TS system to NI digitizer comes typically at -10 sec. 

; Ask a user to select a file to be read
  data_fname = DIALOG_PICKFILE(filter='*.bin', get_path=directory,  path='/home/ycghim/Research/KSTAR/Thomson/data/NI_digitizer/')

  if data_fname eq '' then begin
    result.err = 1
    result.errmsg = 'File is not selected.'
    return, result
  endif

; time and info files
  time_fname = directory + 'Time.bin'
  info_fname = directory + 'info.txt'

; Read the info.txt file, first
  openr, inunit, info_fname, /get_lun
  line = ''
  count = 0
  WHILE NOT EOF(inunit) DO BEGIN
    readf, inunit, line
    line = STRUPCASE(line)

  ; Get the number of fetched data, i.e., number of records
    pos = strpos(line, 'FETCH DONE : ')
    if pos ge 0 then begin
      str_fetch_length = strmid(line, 13)
      fetch_length = float(str_fetch_length)
      count = count + 1       
    endif

  ; Get the number of data points per record
    pos = strpos(line, 'ACTUAL RECORD LENGTH : ')
    if pos ge 0 then begin
      str_record_length = strmid(line, 23)
      record_length = float(str_record_length)
      count = count + 1
    endif

  ; Get time step for each record (i.e., within a record)
    pos = strpos(line, 'XINCREMENT : ')
    if pos ge 0 then begin
      str_xIncrement = strmid(line, 13)
      xIncrement = float(str_xIncrement)
      count = count + 1
    endif
 
  ; Get reference position
    pos = strpos(line, 'REF POSITION : ')
    if pos ge 0 then begin
      str_ref_position = strmid(line, 15)
      ref_position = float(str_ref_position)
      count = count + 1
    endif

  ; Get offset to convert integer data to voltage output
    pos = strpos(line, 'OFFSET : ')
    if pos ge 0 then begin
      str_offset = strmid(line, 9)
      offset = float(str_offset)
      count = count + 1
    endif

  ; Get gain to convert integer data to voltage output
    pos = strpos(line, 'GAIN : ')
    if pos ge 0 then begin
      str_gain = strmid(line, 7)
      gain = float(str_gain)
      count = count + 1
    endif
  ENDWHILE
  free_lun, inunit

  if count lt 6 then begin
    result.err = 2
    result.errmsg = 'Critical parameters are missing in info.txt file.'
    return, result
  endif

; Once, I have fetch_length and record_length, I can read the data file.

; Following lines are commented out because I find that fetch_length in info.txt file does not match with actual
; fetch_length sometimes which causes a routine to read data even if EOF is reached.
;  openr, inunit, data_fname, /get_lun
;  int_data = intarr(record_length, fetch_length)
;
;  PRINT, 'Reading the data...', format='(A,$)'
;  readu, inunit, int_data
;  PRINT, 'DONE!'
;  free_lun, inunit
;  data = int_data*gain + offset

; Instead of above lines, I use the following lines so that I do not get into a problem reading a file after EOF.
  openr, inunit, data_fname, /get_lun
  int_data = intarr(record_length, fetch_length)
  int_temp = intarr(record_length)
  count = 0
  PRINT, 'Reading the data...', format='(A,$)'
  WHILE NOT EOF(inunit) DO BEGIN
    readu, inunit, int_temp
    int_data[*, count] = int_temp
    count = count + 1
  ENDWHILE
  PRINT, 'DONE!'
  int_data = int_data[*, 0:count-1]
  data = int_data*gain+offset
  actual_fetch_length = count
  free_lun, inunit

; Create time info
; Get the trigger time step (time between two successive triggers)
  openr, inunit, time_fname, /get_lun
  header = intarr(4)
  readu, inunit, header ;reading the header of time.bin
  trigger_step_array = dblarr(header[2], header[0]) ;header[2] contains the number devices, header[0] contains the fetch_length
  readu, inunit, trigger_step_array
  free_lun, inunit

; Create time axis per record
  taxis_record = (findgen(record_length)-record_length*ref_position/100.0)*xIncrement

; Create time axis per fetch
; I assume that trigger steps among different devices more or less the same.
  taxis_fetch = dblarr(actual_fetch_length)
  for i=1L, actual_fetch_length-1 do begin
    taxis_fetch[i] = taxis_fetch[i-1] + trigger_step_array[0, i-1]
  endfor
  taxis_fetch = taxis_fetch + offset_time

  if KEYWORD_SET(plot) then begin
    title = 'Data records ' + strmid(data_fname, strpos(data_fname, '/', /reverse_search)+1)
    ycshade, data, taxis_record*1e9, taxis_fetch, $
             xtitle = 'Record Time [nsec]', ytitle = 'Fetch Time [sec]', ztitle = 'Output [V]', title=title, $
             description = directory
  endif

  if KEYWORD_SET(avg_plot) then begin
    avg_data = TOTAL(data, 2)/fetch_length
    title = 'Avg. data ' + strmid(data_fname, strpos(data_fname, '/', /reverse_search)+1)
    ycplot, taxis_record*1e9, avg_data, xtitle='Time [nsec]', ytitle = 'Output [V]', title = title, description=directory
  endif

  result = create_struct(result, $
                         'info_fetch_length', fetch_length, $
                         'actual_fetch_length', actual_fetch_length, $
                         'record_length', record_length, $
                         'offset', offset, $
                         'gain', gain, $
                         'xIncrement', xIncrement, $
                         'ref_position', ref_position, $
                         'int_data', int_data, $
                         'data', data, $
                         'taxis_record', taxis_record, $
                         'taxis_fetch', taxis_fetch, $
                         'trigger_step_array', trigger_step_array)

  if actual_fetch_length NE fetch_length then begin
    PRINT, 'WARNING: fetch_length in info.txt file does not match with actually recorded fetch_length in data file!'
    PRINT, 'FETCH_LENGTH in info.txt: ' + string(fetch_length, format='(i0)')
    PRINT, 'Actual FETCH_LENGTH     : ' + string(actual_fetch_length, format='(i0)')
  endif

  return, result

END
