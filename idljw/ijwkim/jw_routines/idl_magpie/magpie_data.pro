function magpie_data, diag, shot_number
; ex: d = magpie_data('single_pmt',13)

result = {err:0, errmsg:''}
path='/h1magpie'
single_pmt_file = path+'/single_pmt/'+string(shot_number, format='(i05)') + '.bin'
probe1_file = path+'/probe_isat/'+string(shot_number, format='(i05)') + '.bin'
probe2_file = path+'/probe_vfloat/'+string(shot_number, format='(i05)') + '.bin'
probe3_file = path+'/probe_vplus/'+string(shot_number, format='(i05)') + '.bin'
probe4_file = path+'/probe_isat_rot/'+string(shot_number, format='(i05)') + '.bin'
probe5_file = path+'/probe_vfloat_rot/'+string(shot_number, format='(i05)') + '.bin'

if STRLOWCASE(diag) eq strlowcase('probe_isat') then begin
  if file_test(probe1_file) then begin
    file_path = probe1_file
    openr, lun, file_path, /get_lun
        data_size=read_binary(lun, data_type=3, data_dims=2)
        location=read_binary(lun, data_type=5, data_dims=1)
        trigger_time=read_binary(lun, data_type=5, data_dims=1)
        vvector=read_binary(lun, data_type=5, data_dims=data_size[0])
        tvector=read_binary(lun, data_type=5, data_dims=data_size[0])
    close, lun
    
    result = CREATE_STRUCT(result, 'tvector', tvector, 'vvector', vvector, 'trigger_time', trigger_time, $
                               'location', location)
  endif else begin
    PRINT, 'There is no file.'
    stop
    result.err = 1
    result.errmsg = 'There is no file'
    return, result  
  endelse
endif else if STRLOWCASE(diag) eq strlowcase('probe_vfloat') $
   or STRLOWCASE(diag) eq strlowcase('probe_vplus') $
   or STRLOWCASE(diag) eq strlowcase('probe_isat_rot') $
   or STRLOWCASE(diag) eq strlowcase('probe_vfloat_rot') then begin
  if strlowcase(diag) eq strlowcase('probe_vfloat') then begin
   file_path = probe2_file
  endif
  if strlowcase(diag) eq strlowcase('probe_vplus') then begin
   file_path = probe3_file
  endif
  if strlowcase(diag) eq strlowcase('probe_isat_rot') then begin
   file_path = probe4_file
  endif
  if strlowcase(diag) eq strlowcase('probe_vfloat_rot') then begin
   file_path = probe5_file
  endif

  if file_test(file_path) then begin
    openr, lun, file_path, /get_lun
        data_size=read_binary(lun, data_type=3, data_dims=2)
        location=read_binary(lun, data_type=5, data_dims=1)
        trigger_time=read_binary(lun, data_type=5, data_dims=1)
        vvector=read_binary(lun, data_type=5, data_dims=data_size[0])
        tvector=read_binary(lun, data_type=5, data_dims=data_size[0])
    close, lun
    
    result = CREATE_STRUCT(result, 'tvector', tvector, 'vvector', vvector, 'trigger_time', trigger_time, $
                               'location', location)
  endif else begin
    PRINT, 'There is no file.'
    result.err = 1
    result.errmsg = 'There is no file'
    return, result  
  endelse
endif else if STRLOWCASE(diag) eq strlowcase('single_pmt')  then begin
  if file_test(single_pmt_file) then begin
    file_path = single_pmt_file
    openr, lun, file_path, /get_lun
        data_size=read_binary(lun, data_type=3, data_dims=2)
        High_voltage=read_binary(lun, data_type=3, data_dims=1)
        trigger_time=read_binary(lun, data_type=5, data_dims=1)
        vvector=read_binary(lun, data_type=5, data_dims=data_size[0])
        tvector=read_binary(lun, data_type=5, data_dims=data_size[0])
    close, lun
    
    result = CREATE_STRUCT(result, 'tvector', tvector, 'vvector', vvector, 'trigger_time', trigger_time, $
                            'high_voltage', High_voltage)
  endif else begin
    PRINT, 'There is no file.'
    result.err = 1
    result.errmsg = 'There is no file'
    return, result  
  endelse  
endif else begin
  PRINT, 'Calling diagnostic is wrong'
  PRINT, 'used right diag like probe or single_pmt'
  result.err = 1
  result.errmsg = 'Calling diagnostic is wrong'
  return, result
endelse

free_lun, lun
return, result
end
