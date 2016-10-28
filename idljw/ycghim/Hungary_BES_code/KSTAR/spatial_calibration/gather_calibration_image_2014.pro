pro gather_calibration_image_2014, start_shot=start_shot
default, start_shot, 10168
shotrange=[start_shot, 11522]

datapath=local_default('datapath')
calibration_filename='calibration.image.database.2014.sav'
if file_test(calibration_filename) then begin
   restore, calibration_filename
endif else begin
   database={radpos:long(0), vertpos:long(0), apdpos:long(0), image:dblarr(1312,1082)}
   database=replicate(database,1)
   save, database, filename=calibration_filename
endelse
for i=shotrange[0],shotrange[1] do begin
   filename=dir_f_name(datapath,dir_f_name(strtrim(i,2),strtrim(i,2)+'_CMOS_data_calib.sav'))
   filename=dir_f_name(datapath,dir_f_name(strtrim(i,2),strtrim(i,2)+'_config.xml'))
   
   if file_test(filename) or file_test(config_filename) then begin
      restore, filename
      load_config_parameter, i, 'Optics', 'RadialMirrorPosition', output_struct=radpos, errormess=e2
      radpos=radpos.value
      load_config_parameter, i, 'Optics', 'VerticalMirrorPosition', output_struct=vertpos, errormess=e2
      vertpos=vertpos.value
      load_config_parameter, i, 'Optics', 'APDCAMrotationPosition', output_struct=apdpos, errormess=e2
      apdpos=apdpos.value
      
      ind=where(database.radpos eq radpos and database.vertpos eq vertpos and database.apdpos eq apdpos)
      n=n_elements(database)
      if ind[0] eq -1 then begin
         
         database_temp=replicate(database[0],n+1)
         database_temp[0:n-1]=database
         database=database_temp

         database[n].radpos=radpos
         database[n].vertpos=vertpos
         database[n].apdpos=apdpos
         database[n].image=reform(meas[0,*,*])
      endif else begin
         if total(meas[0,*,*]) gt total(database[n-1].image) then begin
            database[n-1].image=reform(meas[0,*,*])
         endif
      endelse
      save, database, filename=calibration_filename

   endif else begin
      print, 'Shot '+strtrim(i,2)+' is missing!'
   endelse
endfor
end
