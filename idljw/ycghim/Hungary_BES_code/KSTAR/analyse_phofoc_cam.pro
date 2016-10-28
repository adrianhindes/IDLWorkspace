pro analyse_phofoc_cam, binary=binary
!p.font=2
cd, 'D:\KFKI\Camera comparison'
if not keyword_set(binary) then begin
  light_int=['0','0.12','0.24','0.378','0.501','0.627','0.746','0.87','1.004','1.125','1.250','1.375','1.506','1.627',$
           '1.745', '1.87', '2.01', '2.12', '2.25', '2.37', '2.49']
endif else begin
  light_int=['0.000','0.015','0.029','0.050','0.099','0.147','0.208','0.250','0.305','0.401','0.499','0.601','0.699','0.802',$
            '0.902','1.001','1.098','1.201','1.296','1.401','1.503','1.603','1.709','1.796', '1.883']
endelse
  n_cmos=double(n_elements(light_int))
  n_image=100.
  nx_cmos=1312.
  ny_cmos=1080.
  aver=dblarr(n_cmos)
  temp_disp=dblarr(n_cmos)
  
    for i=0,n_cmos-1 do begin
      print, i/n_cmos*100, '%'
      if not keyword_set(binary) then begin
        files=findfile('Images.pf\'+light_int[i]+'\*.bmp')
        image=lonarr(1312,1082,n_image)
        for j=0,n_image-1 do begin
          print, files[j]
          temp=read_bmp_32(files[j])
          image[*,*,j]=reform(temp[0,*,*])
        endfor
      endif else begin
        files=findfile('Photon.focus.meas\'+light_int[i]+'\*.bin')
        image=intarr(1312,1082,n_image)
        for j=0,n_image-1 do begin
          print, files[j]
          image[*,*,j]=read_photon_focus_image(files[j])
        endfor
      endelse
    aver[i]=mean(image)
    for j=0,n_image-2 do begin
      temp_disp[i]+=total((double(image[*,*,j]-image[*,*,j+1]))^2)
    endfor   
    temp_disp[i]=sqrt(temp_disp[i]/(2*nx_cmos*ny_cmos*(n_image-1)))
    image=0
  endfor
  light_int=double(light_int)
  save, light_int, aver, temp_disp, filename='good_phofoc_meas.sav'
  plot, light_int, aver, psym=-1, thick=2, charsize=2, xtitle='Light intensity [V]', ytitle='Measured intensity [digit]', title='Photonfocus linearity check'
  stop
  erase
  plot, light_int, temp_disp/light_int, psym=-1, thick=2, charsize=2, xtitle='Light intensity [V]', ytitle='Temporal variance [digit]', title='Photonfocus noise check'
  stop
end