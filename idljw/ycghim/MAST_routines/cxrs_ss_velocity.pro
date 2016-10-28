function cxrs_ss_velocity, shot

  result = {erc:0, errmsg:''}

; Get the CXRS data
  CXRS_data = getdata('act_ss_velocity', shot)
  if CXRS_data.erc ne 0 then begin
    result.erc = CXRS_data.erc
    result.errmsg = CXRS_data.errmsg
    return, result
  endif

  CXRS_vel = CXRS_data.data
  CXRS_vel_err = CXRS_data.edata
  CXRS_R = CXRS_data.x
  CXRS_time = CXRS_data.time

  result = CREATE_STRUCT(result, 'velocity', cxrs_vel, 'error', cxrs_vel_err, 'tvector', cxrs_time, 'rvector', cxrs_r)

  return, result

end