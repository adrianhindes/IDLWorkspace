function mast_bes_read_data, shot, ch, zshot = zshot

  default, zshot, 0

; define the return variable structure
  result = {erc:0l, $			;error number.  This is 0, if no error occured.
            errmsg:''}			;string of error message if erc is not 0.

; read the experimental or synthetic BES data

; Define the NETCDF filename to read APD camera settings
  suff = '.nc'
  str1 = strtrim(string(shot, format='(i0)'), 2)

  if zshot eq 1 then begin
    pre = '/net/fuslsa/data/MAST_zSHOT/xbt'
    str2 = 'z00000'
  endif else begin
    pre = '$MAST_DATA/' + str1 + '/LATEST/xbt'
    str2 = '000000'
  endelse
  strput, str2, str1, 6-strlen(str1)
  filename = 'NETCDF::' + pre + str2 + suff

  str1 = strtrim(string(ch, format='(i0)'), 2)
  str2 = '00'
  strput, str2, str1, 2 - strlen(str1)
  str_dev_loc = 'xbt/channel' + str2

; read the BES data
  PRINT, 'Reading BES data: ' + STRING(str_dev_loc) + '...', format = '(A,$)'
  ds = getdata(str_dev_loc, filename)
  PRINT, 'DONE!'
  if ds.erc ne 0 then begin
    result.erc = ds.erc
    result.errmsg = ds.errmsg
    return, result
  endif

  time = ds.time
  i0 = 0l
  i1 = where(time lt 0.0) & i1 = i1[n_elements(i1)-1]

; remove the offset on the data
  if zshot eq 0 then begin
    offset_val = total(ds.data[i0:i1]) / (i1 - i0 + 1)
    data = ds.data - offset_val
  endif else begin
    restore, '~yckim/yc_idl_routines/no_led_offset_val.sav'
    data = ds.data - offset_val[ch-1]
  endelse

  result = create_struct(result, 'time', time, 'data', data)

  return, result

end
