pro pco_cmos_comparison, pco=pco, comp=comp, cmos=cmos, noise=noise
default, comp, 0
default, pco, 0
default, cmos, 0
default, noise, 0
if pco+comp+noise+cmos ne 1 then begin
    print, 'Only one can be set!'
    return
endif

!p.font=2
  
if keyword_set(comp) then begin
    cd, 'D:\KFKI\Camera comparison'
    restore, 'pco_meas_analysis.sav'
    restore, 'cmos_meas_analysis.sav'
    
    norm_fact=256./4096.
    pco_aver*=norm_fact
    pco_spat_disp*=norm_fact
    pco_temp_disp*=norm_fact
    
    yr_aver=[0.9*min([cmos_aver,pco_aver]),1.1*max([cmos_aver,pco_aver])]
    yr_spat=[0.9*min([cmos_spat_disp,pco_spat_disp]),1.1*max([cmos_spat_disp,pco_spat_disp])]
    yr_temp=[0.9*min([cmos_temp_disp,pco_temp_disp]),1.1*max([cmos_temp_disp,pco_temp_disp])]
    yr_relspat=[0.9*min([cmos_spat_disp/(cmos_aver-cmos_aver[0]),pco_spat_disp/(pco_aver-30)]),1.1*max([cmos_spat_disp/(cmos_aver-cmos_aver[0]),pco_spat_disp/(pco_aver-30)])]
    yr_reltemp=[0.9*min([cmos_temp_disp/cmos_aver,pco_temp_disp/pco_aver]),1.1*max([cmos_temp_disp/cmos_aver,pco_temp_disp/pco_aver])]
    hardon, /color
    device, decomposed=0
    loadct, 5
    ;plot, cmos_exp, cmos_aver, psym=-1, title='Exposure time - Intensity graph', xtitle='Exposure time [us]', $
    ;      ytitle='Intensity [digit]', thick=3, charsize=2, yrange=yr_aver
    ;oplot, pco_exp, pco_aver, psym=-1, thick=3, color=80
    ;erase
    ;plot, cmos_exp, cmos_spat_disp, psym=-1, title='Exposition time - Spatial dispersion', xtitle='Exposition length [us]', $
    ;      ytitle='Spatial dispersion [pixel]', thick=3, charsize=2, yrange=yr_spat, /xlog, /ylog
    ;oplot, pco_exp, pco_spat_disp, psym=-1, thick=3, color=80
    ;erase
    ;plot, cmos_exp, cmos_temp_disp, psym=-1, title='Exposition time - Temporal variance', xtitle='Exposure time [us]', $
    ;      ytitle='Temporal variance [digit]', thick=3, charsize=2, yrange=yr_temp, /xlog, /ylog
    ;oplot, pco_exp, pco_temp_disp, psym=-1, thick=3, color=80
    ;erase
    ;plot, cmos_exp, cmos_spat_disp/cmos_aver, psym=-1, title='Exposition time - Relative spatial dispersion', $
    ;      xtitle='Exposition length [us]', ytitle='Relative spatial dispersion [pixel]', thick=3, charsize=2, yrange=yr_relspat, /xlog, /ylog
    ;oplot, pco_exp, pco_spat_disp/pco_aver, psym=-1, thick=3, color=80
    ;erase
    plot, cmos_exp, cmos_temp_disp/(cmos_aver-cmos_aver[0]), psym=-1, title='Exposure time - Relative temporal variance', $
          xtitle='Exposure time [us]', ytitle='Relative temporal variance [digit]', thick=3, charsize=2, /xlog, /ylog, yrange=[1e-3,1e1]
    oplot, pco_exp, pco_temp_disp/(pco_aver-30.*norm_fact), psym=-1, thick=3, color=80
    ;erase
    ;plot, cmos_aver, cmos_temp_disp/cmos_aver, psym=-1, title='Measured intensity - Relative temporal variance', $
    ;      xtitle='Intensity [digit]', ytitle='Relative temporal variance [digit]', thick=3, charsize=2, yrange=yr_reltemp, /xlog, /ylog
    ;oplot, pco_aver, pco_temp_disp/pco_aver, psym=-1, thick=3, color=80
    ;erase
    ;fitted_pco=(12.86567+0.16369*pco_exp)*norm_fact
    ;fitted_cmos=13.44925+0.00281*cmos_exp
    ;rel_diff_pco=(fitted_pco-pco_aver)/pco_aver
    ;rel_diff_cmos=(fitted_cmos-cmos_aver)/cmos_aver
    ;plot, cmos_exp, rel_diff_cmos, psym=-4, title='Exposure time - relative difference', $
    ;      xtitle='Exposure time [us]', ytitle='Relative difference [digit]', thick=3, charsize=2, /xlog
    ;oplot, pco_exp, rel_diff_pco, psym=-4, color=80, thick=3
    hardfile, 'pco_cmos_comparison.ps'
    
    stop
    
    return
endif

  cmos_exp=long([10,20,50,100,200,500,1e3,2e3,5e3,10e3,15e3,20e3,35e3,50e3,75e3])
  pco_exp=long([1000,2000,3000,4000,5000,6000,7000,8000,9000,10000,15000,20000,25000,35000])
  cd, 'D:\KFKI\Camera comparison'
; calculate pco data
; calculate average and spatial diepersion
if keyword_set(pco) then begin
    cd, 'D:\KFKI\Camera comparison'
    n_pco=double(n_elements(pco_exp))
    aver=dblarr(n_pco)
    spat_disp=dblarr(n_pco)
    temp_disp=dblarr(n_pco)
    nx_pco=640.
    ny_pco=480.
    for i=0,n_pco-1 do begin
    print, i/n_pco*100, '%'
      image=readtiffstack('Images\'+strtrim(pco_exp[i],2)+'us.tif')
      if min(image) eq -1 then return
      aver[i]=mean(image[*,*,0:99])
      n_image=100.
      for j=0,n_image-1 do begin
        for k=0,nx_pco-1 do begin
          for l=0,ny_pco-1 do begin
            spat_disp[i]+=(double(image[k,l,j]-aver[i]))^2
          endfor  
        endfor
      endfor
      spat_disp[i]=sqrt(spat_disp[[i]]/(nx_pco*ny_pco*n_image))
      for j=0,n_image-2 do begin
        for k=0,nx_pco-1 do begin
          for l=0,ny_pco-1 do begin 
              temp_disp[i]+=(double(image[k,l,j]-image[k,l,j+1]))^2
           endfor  
        endfor
      endfor   
      temp_disp[i]=sqrt(temp_disp[i]/(2*nx_pco*ny_pco*n_image))
    endfor
    stop
    plot, pco_exp, aver, title='exposition - intensity', psym=-1
    ;plot, pco_exp, disp, title='exposition - intensity'
    save, pco_exp, pco_aver, pco_temp_disp, cmos_spat_disp, filename='cmos_meas_analysis.sav'
endif
if keyword_set(cmos) then begin
  ;calculate CMOS data
    cd, 'D:\KFKI\Camera comparison'
  n_cmos=double(n_elements(cmos_exp))
  n_image=100.
  nx_cmos=1312.
  ny_cmos=1080.
  aver=dblarr(n_cmos)
  spat_disp=dblarr(n_cmos)
  temp_disp=dblarr(n_cmos)
  for i=0,n_cmos-1 do begin
;    print, i/n_cmos*100, '%'
    files=findfile('Images\'+strtrim(cmos_exp[i],2)+'us\*.bmp')
    image=lonarr(1312,1082,n_image)
    for j=0,n_image-1 do begin
      ;print, files[j]
      temp=read_bmp_32(files[j])
      image[*,*,j]=reform(temp[0,*,*])
    endfor
    if min(image) eq -1 then return
    aver[i]=mean(image[*,*,0:99])
    for j=1,n_image-1 do begin
      spat_disp[i]+=total((double(image[*,*,j]-aver[i]))^2)
    endfor
    spat_disp[i]=sqrt(spat_disp[i]/(nx_cmos*ny_cmos*(n_image-1)))
    for j=1,n_image-2 do begin
      temp_disp[i]+=total((double(image[*,*,j]-image[*,*,j+1]))^2)
    endfor   
    temp_disp[i]=sqrt(temp_disp[i]/(2*nx_cmos*ny_cmos*(n_image-1)))
    PRINT, TEMP_DISP[I]
  endfor
  plot, cmos_exp, aver, title='exposition - intensity', psym=-1
stop
cmos_aver=aver
cmos_temp_disp=temp_disp
cmos_spat_disp=spat_disp
save, cmos_exp, cmos_aver, cmos_temp_disp, cmos_spat_disp, filename='cmos_meas_analysis.sav'
endif

if (keyword_set(noise)) then begin
  cd, 'F:\PCO.phofoc.comparison'
  if not file_test('pco_cmos_snr.sav') then begin
    cmos_exp=long([10,20,50,100,200,500,1e3,2e3,5e3,10e3,15e3,20e3,35e3,50e3,75e3])
    pco_exp=long([10,20,50,100,200,500,1e3,2e3,3.75e3,5e3,7.5e3,10e3,12.5e3,15e3])
    n_image=100.
    nx_cmos=1312.
    ny_cmos=1080.
    nx_pco=640.
    ny_pco=480.
    n_exp_cmos=n_elements(cmos_exp)
    n_exp_pco=n_elements(pco_exp)
    cmos_aver=dblarr(n_exp_cmos)
    cmos_temp_var=dblarr(n_exp_cmos)
    pco_aver=dblarr(n_exp_pco)
    pco_temp_var=dblarr(n_exp_pco)
   
    for i=0,n_exp_cmos-1 do begin
      files_light=findfile('Light\Photon.focus\'+strtrim(cmos_exp[i],2)+'us\'+'*.bin')
      files_dark=findfile('Dark\Photon.focus\'+strtrim(cmos_exp[i],2)+'us\'+'*.bin')
      print, double(i)/n_exp_cmos*100,'%'
      for j=0, n_image-1 do begin
        image=read_photon_focus_image(files_light[j])
        cmos_aver[i]+=1/n_image*mean(image)
      endfor
      for j=0,n_image-2 do begin
        image1=read_photon_focus_image(files_dark[j])
        image2=read_photon_focus_image(files_dark[j+1])
        cmos_temp_var[i]=total((image1-image2)^2)
      endfor    
      cmos_temp_var[i]=sqrt(cmos_temp_var[i]/(2*(n_image-1)*nx_cmos*ny_cmos))
    endfor
    cmos_snr=cmos_aver/cmos_temp_var
  
    for i=0,n_exp_pco-1 do begin
      image_light=readtiffstack('Light\PCO\'+strtrim(pco_exp[i],2)+'us.tif')
      image_dark=readtiffstack('Dark\PCO\'+strtrim(pco_exp[i],2)+'us.tif')
      pco_aver[i]=mean(image_light[0:99])
      pco_temp_var[i]=sqrt(total((double(image_dark[*,*,0:98]-image_dark[*,*,1:99]))^2)/(2*(n_image-1)*nx_pco*ny_pco))
      print, double(i)/n_exp_pco*100,'%'
    endfor
    pco_snr=pco_aver/pco_temp_var
  endif else begin
    restore, 'pco_cmos_snr.sav'
    hardon, /color
    loadct, 5
    cmos_snr=(cmos_aver-cmos_aver[1])/cmos_temp_var
    pco_snr=(pco_aver-pco_aver[0])/pco_temp_var
    norm_fact=0.22*9.9*9.9/(0.5*8*8)
    plot, cmos_exp, cmos_snr*norm_fact, psym=-1, title='Exposure time - Signal to noise ratio', $
          xtitle='Exposure time [us]', ytitle='Signal to noise ratio', thick=3, charsize=2, /xlog, /ylog, yrange=[1,1e4]
    oplot, pco_exp, pco_snr, psym=-1, thick=3, color=80
    hardfile, 'pco_cmos_snr.ps'
    stop
  endelse
endif
stop
end