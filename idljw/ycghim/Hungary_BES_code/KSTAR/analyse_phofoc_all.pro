pro analyse_phofoc_all
cd, 'F:\Photon.focus'
!p.font=2
if not file_test('full_photon_focus_meas.sav') then begin 
  cd, 'F:\Photon.focus'
  cmos_exp=long([10,20,50,100,200,500,1e3,2e3,5e3,10e3,15e3,20e3,35e3,50e3,75e3, 100e3])
  cmos_int=['0.001','0.101','0.201','0.303','0.395','0.501','0.602','0.702','0.800','0.900','1.000',$
            '1.102','1.206','1.305','1.402','1.500','1.600','1.700','1.800','1.900','2.000']
  n_light=double(n_elements(cmos_int))
  n_exp=double(n_elements(cmos_exp))
  n_image=100.
  nx_cmos=1312.
  ny_cmos=1080.
  aver=dblarr(n_light,n_exp)
  temp_var=dblarr(n_light,n_exp)
  for i=0,n_light-1 do begin
    for j=0,n_exp-1 do begin
      files=findfile(cmos_int[i]+'\'+strtrim(cmos_exp[j],2)+'us\'+'*.bin')
      if n_elements(files) ge 100 then begin
      print, cmos_int[i], ', '+strtrim(cmos_exp[j],2)+'us'
        for k=0,n_image-2 do begin
          if k eq 0 then image1=read_photon_focus_image(files[0]) else image1=image2
          image2=read_photon_focus_image(files[k+1])
          aver[i,j]+=mean(image1)
          temp_var[i,j]+=total((image1-image2)^2)
        endfor
        aver[i,j]+=mean(image2)
        aver[i,j]/=n_image
        temp_var[i,j]=sqrt(temp_var[i,j]/(2*(n_image-1)*nx_cmos*ny_cmos))
      endif else begin
        print, cmos_int[i], ', '+strtrim(cmos_exp[j],2)+'us' ;+' FILES NOT FOUND!'
        aver[i,j]=aver[i,j-1]
        temp_var[i,j]=temp_var[i,j-1]
      endelse
    endfor
  endfor
  stop
  cmos_int=double(cmos_int)
  save, cmos_exp, cmos_int, aver, temp_var, filename='full_photon_focus_meas.sav'
endif else begin
  restore, 'full_photon_focus_meas.sav'
  n_light=n_elements(cmos_int)
  n_exp=n_elements(cmos_exp)
  explight=dblarr(n_exp*n_light)
  signal=dblarr(n_exp*n_light)
  for i=0, n_light-1 do begin
    for j=0, n_exp-1 do begin
      explight[i*n_exp+j]=cmos_int[i]*cmos_exp[j]
      signal[i*n_exp+j]=aver[i,j]
    endfor
  endfor
  erase
  hardon, /color
  device, decomposed=0
  plot, explight, signal, psym=4, thick=1, charsize=2,$
        xtitle='Exposure time * light intensity [us*V]', ytitle='Measured intensity [digit]', $
        xrange=[1, 1e2], yrange=[100, 500]
  loadct, 1
  oplot, explight, signal,  psym=4, thick=1, color=128
  explight=dblarr(n_exp*n_light)
  signal=dblarr(n_exp*n_light)
  for i=1, n_light-1 do begin
    for j=1, n_exp-1 do begin
      explight[i*n_exp+j]=cmos_int[i]*cmos_exp[j]
      signal[i*n_exp+j]=aver[i,j]
    endfor
  endfor
  loadct, 0
  oplot, explight, signal,  psym=4, thick=1
  
  hardfile, 'multi.meas.ps'
  stop
endelse          
end