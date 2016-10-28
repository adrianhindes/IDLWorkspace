function cxrs_ss_temperature, shot

  result = {erc:0, errmsg:''}

; Get the CXRS data
  CXRS_data = getdata('act_ss_temperature', shot)
  if CXRS_data.erc ne 0 then begin
    result.erc = CXRS_data.erc
    result.errmsg = CXRS_data.errmsg
    return, result
  endif

  CXRS_temp = CXRS_data.data
  CXRS_temp_err = CXRS_data.edata
  CXRS_R = CXRS_data.x
  CXRS_time = CXRS_data.time

  result = CREATE_STRUCT(result, 'temperature', CXRS_temp, 'error', CXRS_temp_err, 'tvector', cxrs_time, 'rvector', cxrs_r)

  return, result

end