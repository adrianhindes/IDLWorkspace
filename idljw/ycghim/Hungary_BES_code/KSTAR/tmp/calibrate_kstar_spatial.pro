pro calibrate_kstar_spatial, shot, mirrorpos=mirrorpos, apdpos=apdpos, ow=ow

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
shot=shot[0]
default,datapath,local_default('datapath')  
if (datapath eq '') then datapath = 'data'  
errormess = ''
if not file_test(dir_f_name(datapath, strtrim(shot,2))) then begin
   print, 'Shot does not exist. Returning...'
   return
endif
;These lines put the data into txt file for further use in other languages
cal_table_file = dir_f_name('cal',strtrim(shot,2)+'.spat.cal')

if not keyword_set(ow) then begin
   if (file_test(cal_table_file)) then begin
      print, 'Calibration file for shot '+strtrim(shot,2)+' exists. Returning...'
      return
   endif
endif
;These few lines write the calibration data into a standard IDL sav file for further use in IDL
filename=dir_f_name('cal','calib_database.sav')
restore, filename
ind=where(database.shot eq shot)
if ind ne -1 then begin
   
   restore, dir_f_name('cal','all_mirror_pos_7685.sav')
   if not keyword_set(apdpos) then begin
      load_Config_parameter,shot,'Optics','APDCAMPosition',datapath=datapath,output_struct=d_apd,errormess=errormess
      apdpos=long(d_apd.value)
   endif
   
   ind2=where(mirror_db.mirror_position eq database[ind].direction and mirror_db.apd_pos eq apdpos)
 
   if ind2[0] eq -1 then begin
      print, 'There is no such mirpos and apdpos in the database. Returning...'
      return
   endif

   detcorn=dblarr(8,4,3)
   for i=0,3 do begin
      for j=0,7 do begin
         detcorn[j,i,*]=mirror_db[ind2].spatcor[i,j,*]
      endfor
   endfor
   database[ind].position=detcorn
endif else begin  
   if not keyword_set(mirrorpos) then begin
      load_Config_parameter,shot,'Optics','MirrorPosition',datapath=datapath,output_struct=d_mirror,errormess=errormess
      mirrorpos=long(d_mirror.value)
   endif
   if not keyword_set(apdpos) then begin
      load_Config_parameter,shot,'Optics','APDCAMPosition',datapath=datapath,output_struct=d_apd,errormess=errormess
      apdpos=long(d_apd.value)
   endif
      save, database, filename=filename+'.bak'
   if mirrorpos ge 80000 then begin
      print, 'Maximum mirror position for calibration is 80000. Returning...'
      return
   endif
   if apdpos ne 12150 and apdpos ne 30000 then begin
      print, 'APDPOS 12150 and 30000 are the only allowed values. Returning...'
      return
   endif
   n=n_elements(database)
   database_new=replicate(database[0],n+1)
   database_new[0:n-1]=database[*]
   database=database_new
   
   restore, dir_f_name('cal','all_mirror_pos_7685.sav')
   ind=where(mirror_db.apd_pos eq apdpos and mirror_db.mirror_position eq round(mirrorpos/1000)*1000.)
   if ind[0] eq -1 then begin
      print, 'There is no such mirpos and apdpos in the database. Returning...'
      return
   endif
   detcorn=dblarr(8,4,3)
   for i=0,3 do begin
      for j=0,7 do begin
         detcorn[j,i,*]=mirror_db[ind].spatcor[i,j,*]
      endfor
   endfor
   database[n].shot=shot
   database[n].fourcord[*,*]=-1
   database[n].direction=mirror_db[ind].mirror_position
   database[n].position=detcorn
   database[n].area[*,*]=-1
   database[n].det_corner_pos[*,*,*,*]=-1
   database[n].focus=-1
   
   save, database, filename=filename
endelse
save, database, filename=dir_f_name('cal','calib_database.sav')
print, 'Database saved!'

ind=where(database.shot eq shot[0])
;Write spatial calibration txt file for the requested shot
openr,unit_w,cal_table_file,/get_lun,error=error
if (error ne 0) then begin
  detpos=database[ind].position
  pixarea=database[ind].area

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
  
  txt_new = i2str(shot)+' z '
  for i=0,3 do begin
    for j=0,7 do begin
      txt_new = txt_new+' '+string(float(detpos[j,i,1]),format='(F12)')
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
  
  print, 'Calibration file is written:  '+cal_table_file+' !'
  close,unit_w & free_lun,unit_w
endif else begin
  print, 'Error opening file for write!'
  close,unit_w & free_lun,unit_w
endelse

if (strupcase(!version.os) eq 'WIN32') then begin
  cmd='copy '+cal_table_file+' '+datapath+'\'+strtrim(shot,2)
endif
if (strupcase(!version.os) eq 'LINUX') then begin
  cmd='cp '+cal_table_file+' '+datapath+'/'+strtrim(shot,2)
endif
spawn, cmd
end
