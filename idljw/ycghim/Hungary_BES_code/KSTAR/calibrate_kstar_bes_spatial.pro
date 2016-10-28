pro calibrate_kstar_bes_spatial, shot, all=all, shot_interval=shot_interval,overwrite=overwrite, $
                                 datapath=datapath, calibration_file=calibration_file

;          ONLY FOR SHOTS AFTER 9110
;
;***************************************************
;*            calibrate_kstar_bes_spatial          *
;***************************************************
;* INPUTs:                                         *
;*  shot: shot number                              *
;*  /all: switch to do the calibration in the      *
;*        shot_interval                            *
;*  shot_interval: [shot_start,shot_end] in        *
;*        which the calibration will be done       *
;*  /overwrite: Overwrite the previous calibration *
;*  datapath: path for the APDCAM data             *
;*  calibration_file: The path for the calibration *
;*        file which was produced by               *
;*        calibrate_kstar_cmos.pro                 *
;* OUTPUTs:                                        *
;*  no output, files are generated in the shot     *
;*  directory                                      *
;*  shot.spat.cal file is generated                *
;*  shot.spat.h5  file is generated                *
;*  shot.spat.sav file is generated                *
;***************************************************


default, shot, 9110
default, all, 0 ;Do the calibrateion in the shot_interval range
default, shot_interval, [9110, 9427]
default, overwrite, 0  ;Do you want to overwrite previous calibration data?
default, datapath,local_default('datapath')
default, calibration_file, 'cal/calibration_2013_a9110.sav' ; The calibration file written by calibrate_kstar_cmos.pro
default, lithium, 0
if shot lt 9110 then begin
  print, 'Error: The shotnumber should be over 9110!'
  return
endif
restore, calibration_file

if keyword_set(all) then begin
  for i=shot_interval[0], shot_interval[1] do begin
    calibrate_kstar_bes_spatial, i, overwrite=overwrite, datapath=datapath, calibration_file=calibration_file
  endfor
endif
if file_test(dir_f_name(datapath,strtrim(shot,2))) then begin
  load_config_parameter, shot, 'Optics', 'MirrorPosition',   output_struct=radpos,  errormess=e1
  if e1 eq '' then begin
    radpos=double(radpos.value)
    vertpos=5000
  endif else begin
    load_config_parameter, shot, 'Optics', 'RadialMirrorPosition',   output_struct=radpos,  errormess=e1
    if e1 ne '' then begin
      print, 'No radial position available for shot '+strtrim(shot,2)
      return
    endif
    if double(radpos.value) eq 0 then begin
      print, 'No radial position available for shot '+strtrim(shot,2)
      return
    endif
    radpos=double(radpos.value)
    
    load_config_parameter, shot, 'Optics', 'VerticalMirrorPosition', output_struct=vertpos, errormess=e2
    if e2 ne ''  then begin
      print, 'No vertical position available for shot '+strtrim(shot,2)
      return
    endif
    vertpos=double(vertpos.value)
  endelse
      
  load_config_parameter, shot, 'Optics', 'APDCAMPosition',         output_struct=apdpos,  errormess=e3
  if e3 ne ''  then begin
    print, 'No apd rotation position available for shot '+strtrim(shot,2)
    return
  endif
  if double(apdpos.value) eq 0 then begin
    print, 'No apd rotation position available for shot '+strtrim(shot,2)
    return
  endif
  apdpos=double(apdpos.value)
  
  load_config_parameter, shot, 'Optics', 'APDCAMFilter',           output_struct=filter,  errormess=e4
  if e4 ne '' then begin
    print, 'No filter data was provided. Deuterium filter is assumed!'
    lithium=0
  endif
  if (e4 eq '' and filter.value eq 'Lithium') then lithium=1 else lithium=0
 
endif else begin
  print, 'Error! The shot is missing!'
  return
endelse

;Error handling

if apdpos eq 30000 and     lithium then data=data_li_hori
if apdpos eq 12150 and     lithium then data=data_li_vert
if apdpos eq 30000 and not lithium then data=data_da_hori
if apdpos eq 12150 and not lithium then data=data_da_vert

radpos_ind=where(data.rad_pos eq radpos)
vertpos_ind=where(data.vert_pos eq vertpos)
if radpos_ind eq -1 or vertpos_ind eq -1 then begin
  print, 'The radial position is not in the database!'
  return
endif
detpos=reform(data.spat_cord[vertpos_ind,radpos_ind,*,*,*])
filename_sav=dir_f_name(datapath,strtrim(shot,2)+'.spat.sav')
if file_test(filename_sav) and not overwrite then begin
  print, 'The calibration sav file exists for shot '+strtrim(shot,2)+'! If you want to overwrite use /overwrite switch!'
  return
endif else begin
  save, detpos, filename=dir_f_name(datapath,dir_f_name(strtrim(shot,2),strtrim(shot,2)+'.spat.sav'))
endelse

filename_cal=dir_f_name(datapath,dir_f_name(strtrim(shot,2),strtrim(shot,2)+'.spat.cal'))

 if overwrite then begin
  ;read, 'Do you want to delete and make a new calibration table for shot '+strtrim(shot,2)+'? (0:no,1:yes)',bl
  if (file_test(filename_cal)) then begin
    if (strupcase(!version.os) eq 'WIN32') then cmd = 'del '+filename_cal
    if (strupcase(!version.os) eq 'LINUX') then cmd = 'rm -f '+filename_cal
    spawn,cmd
  endif
endif else begin
  if (file_test(filename_cal)) then begin
    print, 'Calibration file for shot '+strtrim(shot,2)+' exists. If you want to overwrite use /overwrite switch!'
    return
  endif
endelse

openw,unit_w,filename_cal,/get_lun,error=error
if (error eq 0) then begin
    channels = strarr(4,8)
  txt = ''
  for i=0,3 do begin
    for j=0,7 do begin
      channels[i,j] = 'BES-'+i2str(i+1)+'-'+i2str(j+1)
      txt = txt+' '+channels[i,j]
    endfor
  endfor
  printf,unit_w,txt
  
  txt_new = i2str(shot)+' R '
  for i=0,3 do begin
    for j=0,7 do begin
      txt_new = txt_new+' '+string(float(detpos[i,j,0]),format='(F12)')
    endfor
  endfor
  printf,unit_w,txt_new
  
  txt_new = i2str(shot)+' Phi '
  for i=0,3 do begin
    for j=0,7 do begin
      txt_new = txt_new+' '+string(float(detpos[i,j,2]),format='(F12)')
    endfor
  endfor
  printf,unit_w,txt_new
  
  txt_new = i2str(shot)+' z '
  for i=0,3 do begin
    for j=0,7 do begin
      txt_new = txt_new+' '+string(float(detpos[i,j,1]),format='(F12)')
    endfor
  endfor
  printf,unit_w,txt_new
  print, 'Calibration file is written:  '+filename_cal+' !'
  close,unit_w & free_lun,unit_w
endif else begin
  print, 'Error opening file for write!'
  close,unit_w & free_lun,unit_w
endelse

;generating a HDF5 calibration file

fname=dir_f_name(datapath,dir_f_name(strtrim(shot,2),strtrim(shot,2)+'.spat.h5'))
calib_data=dblarr(32,4,8,3)
ch_name=strarr(32)
ch_file_name=strarr(32)

for i=1,4 do begin
  for j=1,8 do begin
    channel='BES-'+strtrim(i,2)+'-'+strtrim(j,2)
    ch_name[(i-1)*3+(j-1)]=channel
    if (i-1)*3+(j-1) lt 10 then begin
      ch_file_name='Channel0'+strtrim((i-1)*3+(j-1),2)+'.dat'
    endif else begin
      ch_file_name='Channel'+strtrim((i-1)*3+(j-1),2)+'.dat'
    endelse
    calib_data[(i-1)*3+(j-1),i-1,j-1,*]=detpos[i-1,j-1,*]
  endfor
endfor

;struct={name:shot,calib_data:calib_data,ch_name:ch_name,ch_file_name:ch_file_name,comment:'Spatial calibration data of the shot'}
;fileid=h5f_create(fname)
;datatypeID=h5t_idl_create(struct)
;dataspaceID=h5s_create_simple(1)
;datasetid=h5d_create(fileid,shot,datatypeid,dataspaceid)
;h5d_write,datasetid,struct
;h5f_close,fileid

print, 'Calibration for '+strtrim(shot,2)+' shot is done!'
end
