pro power_profile
 
  points_num2 = 41
  radial_probe = ptrarr(points_num2)
  for i = 0, points_num2-1 do begin
    shot_number = i*3+1007
    radial_probe[i] = ptr_new(phys_quantity(shot_number))
    print, 'get_data : ', i
  endfor
  
;  points_num = 36
;  for i = 0, points_num do begin
;    shot_number = i*3+529
;    rotating_probe[i] = ptr_new(phys_quantity(shot_number))
;  endfor
 
  dens_spectrum = dblarr(2,points_num2)
  temp_spectrum = dblarr(2,points_num2)
  vplasma_spectrum = dblarr(2,points_num2)
  
  dens_vplasma_spectrum = dblarr(4,points_num2)
  
  temp_profile = dblarr(points_num2)
  vplasma_profile = dblarr(points_num2)
  vfloat_profile = dblarr(points_num2)
  vplus_profile = dblarr(points_num2)
  dens_profile = dblarr(points_num2)
  dens_profile2 = dblarr(points_num2)
  
  probe_location = dblarr(points_num2)
  
  trange = [0.05, 0.25]
  subwindow_npts = 2048
 
  for i = 0, points_num2-1 do begin
    a = jw_spectrum((*radial_probe[i]).tvector, (*radial_probe[i]).dens, (*radial_probe[i]).dens, $
       trange,subwindow_npts = subwindow_npts)
    dens_spectrum[0,i] = mean(a.power(where(a.freq ge 15e3 and a.freq le 25e3) ))
    dens_spectrum[1,i] = mean(a.power(where(a.freq ge 35e3 and a.freq le 45e3) ))
    a = jw_spectrum((*radial_probe[i]).tvector, (*radial_probe[i]).temp, (*radial_probe[i]).temp, $
       trange,subwindow_npts = subwindow_npts)
    temp_spectrum[0,i] = mean(a.power(where(a.freq ge 15e3 and a.freq le 25e3) ))
    temp_spectrum[1,i] = mean(a.power(where(a.freq ge 35e3 and a.freq le 45e3) ))
    a = jw_spectrum((*radial_probe[i]).tvector, (*radial_probe[i]).vplasma, (*radial_probe[i]).vplasma, $
       trange,subwindow_npts = subwindow_npts)
    vplasma_spectrum[0,i] = mean(a.power(where(a.freq ge 15e3 and a.freq le 25e3) ))
    vplasma_spectrum[1,i] = mean(a.power(where(a.freq ge 35e3 and a.freq le 45e3) ))
    a = jw_spectrum((*radial_probe[i]).tvector, (*radial_probe[i]).dens, (*radial_probe[i]).vplasma, $
       trange,subwindow_npts = subwindow_npts)
    dens_vplasma_spectrum[0,i] = mean(a.power(where(a.freq ge 15e3 and a.freq le 25e3) ))
    dens_vplasma_spectrum[1,i] = mean(a.power(where(a.freq ge 35e3 and a.freq le 45e3) ))
    dens_vplasma_spectrum[2,i] = mean(a.phase(where(a.freq ge 15e3 and a.freq le 25e3) ))
    dens_vplasma_spectrum[3,i] = mean(a.phase(where(a.freq ge 35e3 and a.freq le 45e3) ))
    probe_location[i] = abs((*radial_probe[i]).location-2.0)
    print, 'calculation :', i
  endfor
  
  ycplot, probe_location, dens_spectrum[0,*]
  ycplot, probe_location ,dens_spectrum[1,*]
  
  ycplot, probe_location, temp_spectrum[0,*]
  ycplot, probe_location ,temp_spectrum[1,*]
  
  ycplot, probe_location, vplasma_spectrum[0,*]
  ycplot, probe_location ,vplasma_spectrum[1,*]
  
  ycplot, probe_location, dens_vplasma_spectrum[0,*]
  ycplot, probe_location ,dens_vplasma_spectrum[1,*]

end