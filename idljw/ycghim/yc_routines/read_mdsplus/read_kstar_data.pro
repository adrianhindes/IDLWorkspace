; This function returns the KSTAR data from MDSPlus server
; Return values:
;    result.err: 0 if no error otherwise 1
;    result.errmsg: contains the errmsg if result.err is 1.
;                   contsins the empty string if result.err is 0.
;    result.d: <1D floating array> contains the data.
;    result.d_unit: <string> contains the unit of the result.data
;    result.e: <1D floating array> contains error of the data if exist.
;               If error information is not available, then this array is filled with zeros.
;    result.t: <1D floating array> contains the time info.(corresponds to the first dimension of result.data)
;    result.t_unit: <string> contains the unit of the result.t
;



FUNCTION read_kstar_data, shot_number, dataname

  result = {err:0, errmsg:' '}

  dataname = strupcase(dataname)

; Set the tree and node according to the dataname
  if dataname eq 'IP' then begin
    tree = 'magnetic'
    node = '\rc03'
    error_node = 'none'
    sign = -1.0
    d_unit = '[ampere]'
    t_unit = '[sec]'  
  endif else if strmid(dataname, 0, 6) eq 'CES_TI' then begin
    tree = 'ion'
    node = '\ces_ti' + strmid(dataname, 6, 2)
    error_node = node + ':err_bar'
    sign = 1.0
    d_unit = '[eV]'
    t_unit = '[sec]'
  endif else if strmid(dataname, 0, 6) eq 'CES_VT' then begin
    tree = 'ion'
    node = '\ces_vt' + strmid(dataname, 6, 2)
    error_node = node + ':err_bar'
    sign = 1.0
    d_unit = '[m/s]'
    t_unit = '[sec]'
  endif else if dataname eq 'TEST' then begin
    tree = 'processed'
    node = '\ne_inter02'
    error_node = 'none'
    sign = 1.0
    d_unit = '[??]'
    t_unit = '[sec]'
  endif else begin
    result.err = 1
    result.errmsg = 'Specified dataname is not defined.'
    return, result
  endelse


; Connect to the KSTAR MDSPlus server
  success = connect_kstar_mdsplus()
  if success ne 1 then begin
    result.err = 1
    result.errmsg = 'Connection to the KSTAR MDSPlus server is failed.'
    return, result
  endif 

; Open the MDS tree
  mdsopen, tree, shot_number, /QUIET, status=status
  if bit_ffs(status) NE 1 then begin ;check the lowest bit of status is set to 1
    result.err = 1
    result.errmsg = 'Opening the MDSPlus tree is failed.'
    success = disconnect_kstar_mdsplus()
    return, result
  endif

; Get the data
  data = mdsvalue(node, /QUIET, status=status)
  if bit_ffs(status) NE 1 then begin ;check the lowest bit of status is set to 1
    result.err = 1
    result.errmsg = 'Opening the MDSPlus node is failed.'
    mdsclose, tree, shot_number
    success = disconnect_kstar_mdsplus()
    return, result
  endif
  data = sign*data

; Get the error bar
  if error_node ne 'none' then begin
    err = mdsvalue(error_node, /QUIET, status=status)
    if bit_ffs(status) NE 1 then begin ;check the lowest bit of status is set to 1
    ; No need to return the errors for the data,
    ; so just set err to -.
    err = fltarr(n_elements(data))
    err[*] = 0.0
    endif
  endif else begin
    err = fltarr(n_elements(data))
    err[*] = 0.0
  endelse

; Get the time 
  time = mdsvalue('dim_of('+node+')', /QUIET, status=status)
  if bit_ffs(status) NE 1 then begin ;check the lowest big of status is set to 1
    result.err = 1
    result.errmsg = 'Opening the MDSPlus time info is failed.'
    mdsclose, tree, shot_number
    success = disconnect_kstar_mdsplus()
    return, result
  endif

; Close the opend MDSPlus tree
  mdsclose, tree, shot_number, /QUIET


; Disconnect from the KSTAR MDSPlus server
  success = disconnect_kstar_mdsplus()

  result = create_struct(result, 'd', data, 'd_unit', d_unit, 'e', err, 't', time, 't_unit', t_unit)

  return, result

END  
