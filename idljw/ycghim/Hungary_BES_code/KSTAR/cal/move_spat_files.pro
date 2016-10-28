pro move_spat_files

  restore, 'calib_database.sav'
  datapath=local_default('datapath')
  n=n_elements(database.shot)
  for k=0,n-1 do begin
    shot=database[k].shot
    detpos=database[k].position
    if n_elements(detpos[*,0,0]) eq 8 then begin
      detpos=[[[transpose(reform(detpos[*,*,0]))]],[[transpose(reform(detpos[*,*,1]))]],[[transpose(reform(detpos[*,*,2]))]]]
    endif
if file_test(dir_f_name(datapath,strtrim(shot,2))) then begin
    save, detpos, filename=dir_f_name(datapath,dir_f_name(strtrim(shot,2),strtrim(shot,2)+'.spat.sav'))
    filename_cal=dir_f_name(datapath,dir_f_name(strtrim(shot,2),strtrim(shot,2)+'.spat.cal'))
    
    if (file_test(filename_cal)) then begin
      if (strupcase(!version.os) eq 'WIN32') then cmd = 'del '+filename_cal
      if (strupcase(!version.os) eq 'LINUX') then cmd = 'rm -f '+filename_cal
      spawn,cmd
    endif
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
    endif else begin
      print, strtrim(shot,2)+' is not present!'
    endelse        
  endfor

end
