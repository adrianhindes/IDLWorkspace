pro calibrate_kstar_spatial, shot, ow=ow, all=all, user=user, focus=focus

;*******************************************************************************************
;*                                                                                         *
;* calibrate_kstar_bes.pro              M. Lampert and S. Zoletnik  12.01.2012             *
;*                                                                                         *
;* Do spatial calibration of the BES channels by calculating                               *
;* its spatial positions from the EDICAM images. The                                       *    
;*                                                                                         *
;* INPUT:                                                                                  *
;*   shot: The calibration shot                                                            *
;*   ow:   Overwrite the older data and create new ones for some shots (OPTIONAL)          *
;*******************************************************************************************

default, user, 'lampee'
default, shot, 6076
default, ow, 0
if user eq 'lampee' then cd, 'D:\KFKI\Measurements\KSTAR\Measurement'
errormess = ''
if (keyword_set(all)) then begin
  restore, dir_f_name('cal','calib_database.sav')
  for i=0,n_elements(database)-1 do calibrate_kstar_spatial, database[i].shot, ow=ow, focus=database[i].focus
endif

;These lines put the data into txt file for further use in other languages
cal_table_file = dir_f_name('cal',strtrim(shot,2)+'.spat.cal')
if ow eq 1 then begin
  ;read, 'Do you want to delete and make a new calibration table for shot '+strtrim(shot,2)+'? (0:no,1:yes)',bl
  if (file_test(cal_table_file)) then begin
    if (strupcase(!version.os) eq 'WIN32') then cmd = 'del '+cal_table_file
    if (strupcase(!version.os) eq 'LINUX') then cmd = 'rm -f '+cal_table_file
    spawn,cmd
  endif
endif else begin
  if (file_test(cal_table_file)) then begin
    print, 'Calibration file for shot '+strtrim(shot,2)+' exists. Returning...'
    return
  endif
endelse

;These few lines write the calibration data into a standard IDL sav file for further use in IDL
if shot lt 7000 then begin
  apd_calib,shot=shot,pixarea=pixarea,detpos=detpos,detcorncord=detcorncord,/silent, focal_length=focus
  restore, dir_f_name('cal','calib_database.sav')
  ind=where(database.shot eq shot)
  database[ind].area=pixarea
  database[ind].position=detpos
  database[ind].det_corner_pos=detcorncord
endif else begin
    
    filename=dir_f_name('cal','calib_database.sav')
  restore, filename
  save, database, filename=filename+'.bak'
  ind=where(database.shot eq shot)
  if ind ne -1 then begin
    print, 'Database already has the spatial calibration for shot #'+strtrim(shot,2)+' ! Returning...'
    return
  endif
  n=n_elements(database)
  database_new=replicate(database[0],n+1)
  database_new[0:n-1]=database[*]
  database=database_new
  spatcor_cur=dblarr(4,8,3) ;vert,hori,[R,z] 
  restore, dir_f_name('cal','mirror_calibration_db.sav')
  restore, dir_f_name('cal','mirror_database.sav')
  
  cur_mir_pos=mir_pos[where(mir_pos[*,0] eq shot),1]
  cur_mir_pos=cur_mir_pos[0]
  mir_pos_5k=cur_mir_pos/5000*5000
  ind2=where(mirror_position eq mir_pos_5k[0])
  rad_pos_5k=oa_position[ind2,0]
  vert_pos_5k=oa_position[ind2,1]
  ;small extrapolation
  pos_add=reform((double(cur_mir_pos-mir_pos_5k)/double(5000))*(oa_position[ind2,*]-oa_position[ind2-1,*]))
  ;The toroidal angle is just an approximation, but the angle between two neighbouring pixels are small
  
  for i=0,2 do begin
    spatcor_cur[*,*,i]=spatcor_d[ind2,*,*,i]+pos_add[i]
  endfor
  
  detpos=spatcor_cur
  
  database[n].shot=shot
  database[n].fourcord[*,*]=-1
  database[n].direction=cur_mir_pos
  database[n].position=detpos
  database[n].area[*,*]=-1
  database[n].det_corner_pos[*,*,*,*]=-1
  database[n].focus=-1
  
  save, database, filename=filename
    
endelse
save, database, filename=dir_f_name('cal','calib_database.sav')

openr,unit_w,cal_table_file,/get_lun,error=error
if (error ne 0) then begin
  openw,unit_w,cal_table_file,/get_lun,error=error
  channels = strarr(32)
  txt = ''
  for i=0,31 do begin
    channels[i] = 'BES-'+i2str(fix(i/8)+1)+'-'+i2str(i mod 8 + 1)
    txt = txt+' '+channels[i]
  endfor
  printf,unit_w,txt
  
  txt_new = i2str(shot)+' R '
  for i=0,3 do begin
    for j=0,7 do begin
      txt_new = txt_new+' '+string(float(detpos[j,i,0]),format='(F12)')
    endfor
  endfor
  printf,unit_w,txt_new
  
  txt_new = i2str(shot)+' Phi '
  for i=0,3 do begin
    for j=0,7 do begin
      txt_new = txt_new+' '+string(float(detpos[j,i,2]),format='(F12)')
    endfor
  endfor
  printf,unit_w,txt_new
  
  txt_new = i2str(shot)+' z '
  for i=0,3 do begin
    for j=0,7 do begin
      txt_new = txt_new+' '+string(float(detpos[j,i,1]),format='(F12)')
    endfor
  endfor
  printf,unit_w,txt_new
  
  txt_new = i2str(shot)+' Area '
  for i=0,3 do begin
    for j=0,7 do begin
      txt_new = txt_new+' '+string(float(pixarea[j,i]),format='(F12)')
    endfor
  endfor
  printf,unit_w,txt_new
  print, 'Calibration file is written:  '+cal_table_file+' !'
  close,unit_w & free_lun,unit_w
endif else begin
  print, 'Error opening file for write!'
  close,unit_w & free_lun,unit_w
endelse
return

end