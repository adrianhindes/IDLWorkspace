; This function reads the NI data from all 5 channels

FUNCTION read_ts_raw_ni, plot = plot, offset_time = offset_time, digital=digital, $
                         subtract_offset = subtract_offset, avg_fetch = avg_fetch, invert=invert

  result = {err:0, errmsg:''}

  default, offset_time, -10 ;First trigger from the KSTAR TS system to NI digitizer comes typically at -10 sec. 
  default, digital, 0 ; if digital is set, then plot digital data rather than voltage data
  default, subtract_offset, 0 ;if subtract_offset is set, then remove the offset of the signal
  default, avg_fetch, 1  ;[integer number]: boxcar averaging width
  default, invert, 0     ;inverting the signal (from negative voltage to the positive voltage value)

; Ask a user to select a directory which contains the data files
  directory = DIALOG_PICKFILE(/directory, path='/home/ycghim/Research/KSTAR/Thomson/data/NI_digitizer/')

  if directory eq '' then begin
    result.err = 1
    result.errmsg = 'Directory is not selected.'
    return, result
  endif

  PRINT, 'Selected Directoy: ' + directory

; time and info files
  time_fname = directory + 'Time.bin'
  info_fname = directory + 'info.txt'

; data files
; NOTE: 
; 1) On the 12th of November 2014, we have changed the digitizer from NI PXIe-5162 to NI PXIe-5160.
;    NI PXIe-5162 were rented by NI, and we have bought NI PXIe-5160 which was deliever on this date.
;    --> NI PXIe-5160 modules were used starting from 20141112_154235 files.
; 2) As we have bought four NI PXIe-5160 modules, we have 5160-1, 5160-2, 5160-3 and 5160-4.
;    However, from 20141112_154235 to 20141112_170217 files contain only 5160-1 and 5160-2 files.
;    Thus, we have to be careful read data from these files.
;    String from 20141112_171245, we have data from all four modules.
; 3) Once we starting taking data using NI PXIe-5160 modules, we wanted to use the full sampling rate of the modules
;    which were 2.5GS/s. To do so, we had to use only ch0 and ch2 on the modules.
; More detailed description can be found on Research Note (Ref# 2013-002) p.54 and 55.
; 4) noise test data: 2015.Jan.15th.
; 5) Rayleigh calibration date for 2015 campaign: 2015.June 4th and 5th.
; 6) 2015 campaign started on the 3rd of August, and we started to collect the data on the 6th of August.
; 7) From the 11th of August 2015, we have total eight 5160 devices.
;    --> Info.txt format has been changed.
;    --> We choose voltage peak-to-peak value and offset value separately for difference channels on 5160 devices.

  dir_date_time = STRSPLIT(directory, '/', /extract)
  dir_date_time = dir_date_time(N_ELEMENTS(dir_date_time)-1)
  dir_date_time = STRSPLIT(dir_date_time, '_', /extract)
  long_dir_date = LONG(dir_date_time[0])
  long_dir_time = LONG(dir_date_time[1])

  PXIe_5160_start_date = LONG(20141112)
  PXIe_5160_start_time = LONG(154235)
  PXIe_5160_four_module_start_time = LONG(171245)
;  PXIe_5160_noise_test_date = LONG(20150115)
  Rayleigh_calibration_2015_start_date = LONG(20150604)
  Rayleigh_calibration_2015_end_date = LONG(20150710)
  Campaign_2015_start_date = LONG(20150806)
  Campaign_2015_eight_5160_start_date = LONG(20150811)

  device_5162 = 'PXIe-5162'
  device_5160_four_modules = 'PXIe-5160_four_modules'
  device_5160_two_modules = 'PXIe-5160_two_modules'
  device_Rayleigh_2015_data = 'Rayleigh_2015_data'
  device_campaign_2015 = 'Campaign_2015'
  device_campaign_eight_5160 = 'Campaign_2015_eight_5160'

  if long_dir_date GE Campaign_2015_eight_5160_start_date then $
    device = device_campaign_eight_5160 $
  else if long_dir_date GE Campaign_2015_start_date then $
    device = device_campaign_2015 $
  else if (long_dir_date GE Rayleigh_calibration_2015_start_date) AND (long_dir_date LE Rayleigh_calibration_2015_end_date) then $
    device = device_Rayleigh_2015_data $
  else if long_dir_date LT PXIe_5160_start_date then $
    device = device_5162 $
  else if long_dir_date GT PXIe_5160_start_date then $
    device = device_5160_four_modules $
  else begin
  ;for the case of long_dir_date == PXIe_5160_start_date
    if long_dir_time LT PXIe_5160_start_time then $
      device = device_5162 $
    else if long_dir_time LT PXIe_5160_four_module_start_time then $
      device = device_5160_two_modules $
    else $
      device = device_5160_four_modules  
  endelse 

  if device EQ device_campaign_eight_5160 then begin
    data_fname = directory + $
                 ['5160-1_ch0_data.bin', $ ;Polychromator Edge #2-Ch1
                  '5160-1_ch1_data.bin', $ ;Polychromator Edge #2-Ch2
                  '5160-1_ch2_data.bin', $ ;Polychromator Edge #2-Ch3
                  '5160-1_ch3_data.bin', $ ;Polychromator Edge #2-Ch4
                  '5160-2_ch0_data.bin', $ ;Polychromator Edge #3-Ch1
                  '5160-2_ch1_data.bin', $ ;Polychromator Edge #3-Ch2
                  '5160-2_ch2_data.bin', $ ;Polychromator Edge #3-Ch3
                  '5160-2_ch3_data.bin', $ ;Polychromator Edge #3-Ch4
                  '5160-3_ch0_data.bin', $ ;Polychromator Edge #7-Ch1
                  '5160-3_ch1_data.bin', $ ;Polychromator Edge #7-Ch2
                  '5160-3_ch2_data.bin', $ ;Polychromator Edge #7-Ch3
                  '5160-3_ch3_data.bin', $ ;Polychromator Edge #7-Ch4
                  '5160-4_ch0_data.bin', $ ;Polychromator Edge #2-Ch5 (Laser line)
                  '5160-4_ch1_data.bin', $ ;Polychromator Edge #3-Ch5 (Laser line)
                  '5160-4_ch2_data.bin', $ ;Polychromator Edge #7-Ch5 (Laser line)
                  '5160-5_ch0_data.bin', $ ;Polychromator Core #3-Ch1
                  '5160-5_ch1_data.bin', $ ;Polychromator Core #3-Ch2
                  '5160-5_ch2_data.bin', $ ;Polychromator Core #3-Ch3
                  '5160-5_ch3_data.bin', $ ;Polychromator Core #3-Ch4
                  '5160-6_ch0_data.bin', $ ;Polychromator Core #8-Ch1
                  '5160-6_ch1_data.bin', $ ;Polychromator Core #8-Ch2
                  '5160-6_ch2_data.bin', $ ;Polychromator Core #8-Ch3
                  '5160-6_ch3_data.bin', $ ;Polychromator Core #8-Ch4
                  '5160-7_ch0_data.bin', $ ;Polychromator Core #12-Ch1
                  '5160-7_ch1_data.bin', $ ;Polychromator Core #12-Ch2
                  '5160-7_ch2_data.bin', $ ;Polychromator Core #12-Ch3
                  '5160-7_ch3_data.bin', $ ;Polychromator Core #12-Ch4
                  '5160-8_ch0_data.bin', $ ;Polychromator Core #3-Ch5 (Laser line)
                  '5160-8_ch1_data.bin', $ ;Polychromator Core #8-Ch5 (Laser line)
                  '5160-8_ch2_data.bin']   ;Polychromator Core #12-Ch5 (Laser line)
    plot_title = ['Edge #2-Ch1', 'Edge #2-Ch2', 'Edge #2-Ch3', 'Edge #2-Ch4', $
                  'Edge #3-Ch1', 'Edge #3-Ch2', 'Edge #3-Ch3', 'Edge #3-Ch4', $
                  'Edge #8-Ch1', 'Edge #8-Ch2', 'Edge #8-Ch3', 'Edge #8-Ch4', $
                  'Edge #2-Ch5', 'Edge #3-Ch5', 'Edge #8-Ch5', $
                  'Core #3-Ch1', 'Core #3-Ch2', 'Core #3-Ch3', 'Core #3-Ch4', $
                  'Core #8-Ch1', 'Core #8-Ch2', 'Core #8-Ch3', 'Core #8-Ch4', $
                  'Core #12-Ch1', 'Core #12-Ch2', 'Core #12-Ch3', 'Core #12-Ch4', $
                  'Core #3-Ch5', 'Core #8-Ch5', 'Core #12-Ch5']
  endif else if device EQ device_campaign_2015 then begin  
    data_fname = directory + $
                 ['5160-1_ch0_data.bin', $ ;Polychromator Edge #2-Ch1
                  '5160-1_ch1_data.bin', $ ;Polychromator Edge #2-Ch2
                  '5160-1_ch2_data.bin', $ ;Polychromator Edge #2-Ch3 
                  '5160-1_ch3_data.bin', $ ;Polychromator Edge #2-Ch4
                  '5160-2_ch0_data.bin', $ ;Polychromator Edge #3-Ch1
                  '5160-2_ch1_data.bin', $ ;Polychromator Edge #3-Ch2 
                  '5160-2_ch2_data.bin', $ ;Polychromator Edge #3-Ch3
                  '5160-2_ch3_data.bin', $ ;Polychromator Edge #3-Ch4
                  '5160-3_ch0_data.bin', $ ;dummy (noise)
                  '5160-4_ch0_data.bin', $ ;Polychromator Edge #2-Ch5 (Laser line)
                  '5160-4_ch1_data.bin']   ;Polychromator Edge #3-Ch5 (Laser line)
  endif else if device EQ device_Rayleigh_2015_data then begin
    data_fname = directory + $
                 ['5160-1_ch0_data.bin', $
                  '5160-1_ch2_data.bin', $
                  '5160-2_ch0_data.bin', $
                  '5160-3_ch0_data.bin', $
                  '5160-4_ch0_data.bin', $
                  '5160-4_ch2_data.bin']
  endif else if device EQ device_5162 then begin
    data_fname = directory + $
                 ['5162-1_ch0_data.bin', $
                  '5162-1_ch1_data.bin', $
                  '5162-1_ch2_data.bin', $
                  '5162-1_ch3_data.bin', $
                  '5162-2_ch0_data.bin', $
                  '5162-2_ch1_data.bin']
  endif else if device EQ device_5160_two_modules then begin
    data_fname = directory + $
                 ['5160-1_ch0_data.bin', $
                  '5160-1_ch2_data.bin', $
                  '5160-2_ch0_data.bin']
  endif else begin
    data_fname = directory + $
                 ['5160-1_ch0_data.bin', $
                  '5160-1_ch2_data.bin', $
                  '5160-2_ch0_data.bin', $
                  '5160-3_ch0_data.bin', $
                  '5160-4_ch0_data.bin']
  endelse
  ch_num = N_ELEMENTS(data_fname)   

; Read the info.txt file, first
  if device EQ device_campaign_eight_5160 then begin
    offset = fltarr(ch_num)
    gain = fltarr(ch_num)
    device_name = ['5160-1/0', '5160-1/1', '5160-1/2', '5160-1/3', $
                   '5160-2/0', '5160-2/1', '5160-2/2', '5160-2/3', $
                   '5160-3/0', '5160-3/1', '5160-3/2', '5160-3/3', $
                   '5160-4/0', '5160-4/1', '5160-4/2', $
                   '5160-5/0', '5160-5/1', '5160-5/2', '5160-5/3', $
                   '5160-6/0', '5160-6/1', '5160-6/2', '5160-6/3', $
                   '5160-7/0', '5160-7/1', '5160-7/2', '5160-7/3', $
                   '5160-8/0', '5160-8/1', '5160-8/2']
  endif
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

  ; Get offset and gain to convert integer data to voltage output
    if device EQ device_campaign_eight_5160 then begin
      for inx_device = 0, ch_num - 1 do begin
        pos = strpos(line, device_name[inx_device])     
        if pos ge 0 then begin
          readf, inunit, line ;read vertical peak-to-peak voltage range
          readf, inunit, line ;read offset
          offset[inx_device] = float(strmid(line, 9))
          readf, inunit, line ;read gain
          gain[inx_device] = float(strmid(line, 7))
          count = count + 1    
        endif
      endfor
    endif else begin
      pos = strpos(line, 'OFFSET : ')
      if pos ge 0 then begin
        str_offset = strmid(line, 9)
        offset = float(str_offset)
        count = count + 1
      endif

      pos = strpos(line, 'GAIN : ')
      if pos ge 0 then begin
        str_gain = strmid(line, 7)
        gain = float(str_gain)
        count = count + 1
      endif
    endelse
  ENDWHILE
  free_lun, inunit

  if device EQ device_campaign_eight_5160 then begin
    if count lt 34 then begin
      result.err = 2
      result.errmsg = 'Critical parameters are missing in info.txt file.'
      return, result
    endif
  endif else begin
    if count lt 6 then begin
      result.err = 2
      result.errmsg = 'Critical parameters are missing in info.txt file.'
      return, result
    endif
  endelse

; Once, I have fetch_length and record_length, I can read the data file.
  int_data = intarr(record_length, fetch_length, ch_num)
  int_temp = intarr(record_length)
  PRINT, 'Reading the data...', format='(A,$)'
  for i=0, ch_num - 1 do begin
    count = 0
    PRINT, 'Ch.'+string(i+1, format='(i0)') + '...', format='(A,$)'
    openr, inunit, data_fname[i], /get_lun
    WHILE (NOT EOF(inunit) AND (count LT fetch_length))   DO BEGIN
      readu, inunit, int_temp
      int_data[*, count, i] = int_temp
      count = count + 1
    ENDWHILE
    free_lun, inunit
  endfor
  PRINT, 'DONE!'
  int_data = int_data[*, 0:count-1, *]
  if device EQ device_campaign_eight_5160 then begin
    dim_int_data = size(int_data, /dim)   
    data = fltarr(dim_int_data[0], dim_int_data[1], dim_int_data[2]) 
    for inx_device = 0, ch_num - 1 do begin
      data[*, *, inx_device] = int_data[*, *, inx_device] * gain[inx_device] + offset[inx_device]
    endfor
  endif else begin
    data = int_data*gain+offset
  endelse
  actual_fetch_length = count

; Create time info
; Get the trigger time step (time between two successive triggers)
  openr, inunit, time_fname, /get_lun
  if device EQ device_campaign_eight_5160 then begin
    header = dblarr(1)
    readu, inunit, header ;first line contains the number of data points
    ; but, do not use header to construct the trigger_step_array. Use the 'actual_fetch_length-1'.
    ; this header does not contain correct number of data points.
    trigger_step_array = dblarr(1, actual_fetch_length-1)

    readu, inunit, trigger_step_array
  endif else begin
    header = intarr(4)
    readu, inunit, header ;reading the header of time.bin

    trigger_step_array = dblarr(header[2], header[0]) ;header[2] contains the number devices, header[0] contains the fetch_length 
  ;  trigger_step_array = dblarr(2, actual_fetch_length-1) ;use this for files taken from 20140924_161528 to 20140925_******

    readu, inunit, trigger_step_array
  endelse
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

; if subtract_offset it set, then removed the offset from the signal
; As the trigger signal is obtained at taxis_record=0.0, I estimate the offset signal using taxis_record < 0.0.
  if subtract_offset eq 1 then begin
    PRINT, 'Subtracting signal offset...', format='(A,$)'
    inx_sig_offset = WHERE( taxis_record LE 0.0, num_inx_sig_offset )
    sig_offset = TOTAL(data[inx_sig_offset, *, *], 1)/num_inx_sig_offset
    size_data = size(data, /dim)
    for i=0L, size_data[1]-1 do begin ;looping for every fecth
      for j=0L, size_data[2]-1 do begin ;looping for every channel
        data[*, i, j] = data[*, i, j] - sig_offset[i, j]
      endfor
    endfor
    PRINT, 'Done!'
  endif

; Apply boxcar averaging
; Note: boxcar averagin is performed using the SMOOTH function, and if the avg_fetch (width of boxcar) is 1, then
;       SMOOTH function ignores command.
  data = SMOOTH(data, [1, avg_fetch, 1], /NAN)

  if invert eq 1 then data = -1.0*data

  if KEYWORD_SET(plot) then begin
    if digital eq 1 then begin
      plot_data = int_data
      ztitle = 'Digitized value [integer]'
    endif else begin
      plot_data = data
      ztitle = 'Output [V]'
    endelse
    for i=0, ch_num - 1 do begin
      if device EQ device_campaign_eight_5160 then begin
        title = plot_title[i] + ': Data records ' + strmid(data_fname[i], strpos(data_fname[i], '/', /reverse_search)+1)
      endif else begin
        title = 'CH.'+string(i+1, format='(i0)')+': Data records ' + strmid(data_fname[i], strpos(data_fname[i], '/', /reverse_search)+1)
      endelse    
      ycshade, reform(plot_data[*, *, i]), taxis_record*1e9, taxis_fetch, $
               xtitle = 'Record Time [nsec]', ytitle = 'Fetch Time [sec]', ztitle = ztitle, title=title, $
               description = directory
    endfor
  endif

  max_voltage = MAX(data, /absolute, dim=1, /nan)
  avg_max_voltage = TOTAL(max_voltage, 1, /nan)/actual_fetch_length
  stddev_max_voltage = STDDEV(max_voltage, dim=1, /nan)

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
                         'max_voltage', max_voltage, $
                         'avg_max_voltage', avg_max_voltage, $
                         'stddev_max_voltage', stddev_max_voltage, $
                         'trigger_step_array', trigger_step_array, $
                         'device', device)

  if actual_fetch_length NE fetch_length then begin
    PRINT, 'WARNING: fetch_length in info.txt file does not match with actually recorded fetch_length in data file!'
    PRINT, 'FETCH_LENGTH in info.txt: ' + string(fetch_length, format='(i0)')
    PRINT, 'Actual FETCH_LENGTH     : ' + string(actual_fetch_length, format='(i0)')
  endif

  return, result





END
