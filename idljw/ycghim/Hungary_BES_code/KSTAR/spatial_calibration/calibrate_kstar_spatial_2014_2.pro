pro calibrate_kstar_spatial_2014

default, start_shot, 10168
shotrange=[start_shot, 11522]

datapath=local_default('datapath')
restore, 'spatial_coordinate_database_2014.sav' ;spat_database

for i=shotrange[0],shotrange[1] do begin
   filename=dir_f_name(datapath,dir_f_name(strtrim(i,2),strtrim(i,2)+'_CMOS_data_calib.sav'))
   config_filename=dir_f_name(datapath,dir_f_name(strtrim(i,2),strtrim(i,2)+'_config.xml'))
   if file_test(filename) or file_test(config_filename) then begin
      load_config_parameter, i, 'Optics', 'RadialMirrorPosition', output_struct=radpos, errormess=e2
      radpos=radpos.value
      load_config_parameter, i, 'Optics', 'VerticalMirrorposition', output_struct=vertpos, errormess=e2
      vertpos=vertpos.value
      load_config_parameter, i, 'Optics', 'APDCAMrotationposition', output_struct=apdpos, errormess=e2
      apdpos=apdpos.value
      load_config_parameter, i, 'Optics', 'APDCAMfiltertype', output_struct=li_filter, errormess=e2
      if li_filter.value eq 'Deuterium' then li_filter=0 else li_filter=1
      
      ;load_config_parameter, i, 'Optics', 'APDCAMfilter', output_struct=apdpos, errormess=e2
      ;apdpos=apdpos.value
      
      ind=where(spat_database.radpos eq radpos and spat_database.vertpos eq vertpos and spat_database.apdpos eq apdpos and spat_database.li_filter eq li_filter)
      
      if ind[0] ne -1 then begin
        detpos=spat_database[ind].spat_coord
        save, detpos, filename=dir_f_name(datapath,dir_f_name(strtrim(shot,2),strtrim(shot,2)+'.spat.sav'))
        
        filename_cal=dir_f_name(datapath,dir_f_name(strtrim(shot,2),strtrim(shot,2)+'.spat.cal'))
                
        openw,unit_w,filename_cal,/get_lun,error=error
        if (error eq 0) then begin
            channels = strarr(4,8)
          txt = ''
          for i=0,3 do begin
            for j=0,15 do begin
              channels[i,j] = 'BES-'+i2str(i+1)+'-'+i2str(j+1)
              txt = txt+' '+channels[i,j]
            endfor
          endfor
          printf,unit_w,txt
          
          txt_new = i2str(shot)+' R '
          for i=0,3 do begin
            for j=0,15 do begin
              txt_new = txt_new+' '+string(float(detpos[i,j,0]),format='(F12)')
            endfor
          endfor
          printf,unit_w,txt_new
          
          txt_new = i2str(shot)+' Phi '
          for i=0,3 do begin
            for j=0,15 do begin
              txt_new = txt_new+' '+string(float(detpos[i,j,2]),format='(F12)')
            endfor
          endfor
          printf,unit_w,txt_new
          
          txt_new = i2str(shot)+' z '
          for i=0,3 do begin
            for j=0,15 do begin
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
      endif else begin
        print, 'Settings are not in the database!'
      endelse
   endif else begin
      print, 'Shot '+strtrim(i,2)+' is missing!'
   endelse
endfor

end