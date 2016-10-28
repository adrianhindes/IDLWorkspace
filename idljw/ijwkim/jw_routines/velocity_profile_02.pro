pro velocity_profile_02
  
;  position = dblarr(4)
;  position[0] = 210
;  position[1] = 220
;  position[2] = 230
;  position[3] = 240

;  shot = [82793, 83834]
  shot = [87842, 87846]
  
  trange = [0.02, 0.04]
  frng=[50e3,200e3]
;  mode = 'vfloat'
  mode = 'vplasma'
  
  ;  86418, 86427, 86428, 86429
  
;  eb = potential_profile(mode = mode,trange=trange)
  
  cctd_result = ptrarr(2)
  spectrum_result = ptrarr(2)
  
  
  xbpp=250
  rbpp=1112+xbpp-45
  zbpp = 0
  plots, rbpp, zbpp, psym=4
  
  ;sh=intspace(87837,87886)
  loaddata
  sh=long(shot)

  nsh=n_elements(sh)
  coh=complexarr(nsh)
  frng=[100e3,200e3]  
  rad=fltarr(nsh)
  th=fltarr(nsh)  
  for i=0,nsh-1 do begin
     mdsopen,'h1data',sh(i)
     rad(i)=mdsvalue('\H1DATA::TOP.FLUCTUATIONS.FORK_PROBE:STEPPERXPOS')
     th(i)=mdsvalue('\H1DATA::TOP.FLUCTUATIONS.FORK_PROBE:STEPPERYPOS')
  endfor
  r=fltarr(nsh)
  z=fltarr(nsh)
  for i=0,nsh-1 do begin
     fppos3,rad(i)-10,th(i),rdum,zdum
     r(i)=rdum & z(i)=zdum
  endfor
  
  distance_bpp_fp = sqrt((r-rbpp)^2.0+(z-zbpp)^2.0)
  mb_cart2flux_cl,r*1e-3,z*1e-3,rhop,thp,phi=7.2*!dtor
  rho_mean = mean(rhop)
  th_zero = 0
  mb_flux2cart_cl,rho_mean,th_zero,r_zero,z_zero,phi=7.2*!dtor
  distance_fp_zero = sqrt((r_zero-r)^2.0+(z_zero-z)^2.0)
  distance_use = distance_bpp_fp
;  distance_use = distance_fp_zero
  stop
  
  shot_number = shot[0]
  a = getpar(shot_number,'isat',y=y1,tw=trange)
  b = getpar(shot_number,'isatfork',y=y2,tw=trange)
  cctd_result[0] = ptr_new(cctd(y1.t, ch1_array=y1.v, ch2_array=y2.v,trange=trange, freq_filter = frng, distance = distance_use[0]))
  d1 = select_time(y1.t,y1.v,trange)
  d2 = select_time(y2.t,y2.v,trange)
  spectrum_result[0] = ptr_new(jw_spectrogram(d1.tvector, d1.yvector, d2.yvector, subwindow_npts = 1024, num_subwindow_avg = 8, /phase_plot))
  
  shot_number = shot[1]
;  trange = [0.02, 0.04]
  a = getpar(shot_number,'isat',y=y1,tw=trange)
  b = getpar(shot_number,'isatfork',y=y2,tw=trange)
  cctd_result[1] = ptr_new(cctd(y1.t, ch1_array=y1.v, ch2_array=y2.v,trange=trange, freq_filter = frng, distance = distance_use[1]))
  d1 = select_time(y1.t,y1.v,trange)
  d2 = select_time(y2.t,y2.v,trange)
  spectrum_result[1] = ptr_new(jw_spectrogram(d1.tvector, d1.yvector, d2.yvector,subwindow_npts = 1024,num_subwindow_avg = 8, /phase_plot))
  
;  t = 2
  numofshot = 2
  cctd_vel = dblarr(numofshot,n_elements((*cctd_result[0]).tvector))
  envel_delay = dblarr(numofshot,n_elements((*cctd_result[0]).tvector))
  for ti=0L, n_elements((*cctd_result[0]).tvector)-1 do begin
    for i = 0L, numofshot-1 do begin
      cctd_vel[i,ti] = (*cctd_result[i]).velocity[ti]
      envel_delay[i,ti] = (*cctd_result[i]).envel_delay[ti]
    endfor
  endfor
  
  for ti=0L, n_elements((*cctd_result[0]).tvector)-1 do begin
    ycplot, distance_use, envel_delay[*,ti]
  endfor
  
  velocity_between = (distance_use[1]-distance_use[0])*0.001/(envel_delay[1,*]-envel_delay[0,*])
  
  ycplot, (*cctd_result[0]).tvector, cctd_vel[0,*], out_base_id = oid
  ycplot, (*cctd_result[0]).tvector, cctd_vel[1,*], oplot_id = oid
  ycplot, (*cctd_result[0]).tvector, velocity_between, oplot_id = oid
  
;  cctd_corr = dblarr(4)
;  for i = 0L, 4-1 do begin
;     cctd_corr[i] = (*cctd_result[i]).max_envel[t]
;  endfor
;  
  phase_vel = dblarr(numofshot,n_elements((*cctd_result[0]).tvector))
  get_phase = ptrarr(numofshot,n_elements((*cctd_result[0]).tvector))
  select_freq = 100.0*10.0^3.0 ;[hz]
;  distance = distance_use[1]*0.001 ;[m]
  
  for ti=0L, n_elements((*cctd_result[0]).tvector)-1 do begin
    for i = 0L, numofshot-1 do begin
       get_phase[i,ti] = ptr_new(phase_align((*spectrum_result[i]).freq, (*spectrum_result[i]).phase[ti,*]))
       phase_vel[i,ti] = 2*!pi*select_freq/(*get_phase[i,ti]).phase_value*(distance_use[i]*0.001)
    endfor
  endfor
  
  phase_between = dblarr(n_elements((*cctd_result[0]).tvector))
  
  for ti=0L, n_elements((*cctd_result[0]).tvector)-1 do begin
    print, 'phase_value 0 : ', (*get_phase[0,ti]).phase_value
    print, 'phase_value 1 : ', (*get_phase[1,ti]).phase_value
    phase_between[ti] = (*get_phase[1,ti]).phase_value-(*get_phase[0,ti]).phase_value
    print, phase_between
  endfor
  
  distance_between = (distance_use[1]-distance_use[0])*0.001
  phase_velocity_between = 2*!pi*select_freq/phase_between*distance_between
  
  
  ycplot, (*cctd_result[0]).tvector, phase_vel[0,*], out_base_id = oid
  ycplot, (*cctd_result[0]).tvector, phase_vel[1,*], oplot_id = oid
  ycplot, (*cctd_result[0]).tvector, phase_velocity_between, oplot_id = oid
  
  
  for i = 0L, 4-1 do begin

  endfor

;  ycplot, position, cctd_vel, title = strjoin([string((*cctd_result[0]).tvector[t],format='(d0.6)') , ' sec']), out_base_id = oid
  
;  ycplot, position, phase_vel, oplot_id = oid
  
;  ycplot, eb.position[*,t], eb.velocity[*,t], oplot_id = oid; , title = strjoin([string(eb.time_vector[t],format='(d0.6)') , ' sec'])
  
;  ycplot, position, cctd_corr

end