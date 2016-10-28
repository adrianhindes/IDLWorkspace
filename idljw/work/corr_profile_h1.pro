pro corr_profile_h1
  

;  sh=[61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,101,102,103,104]+89500
;  [54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,
;  sh = [54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104]+89500 ;54 ;0.8, c2   
;  sh = [20,21,22,23,24,25,26,27,28,29,30,31,32]+89500 
;  sh = [4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,33,34,35,36,37,38,39]+89500 ;0.8, c1
;  sh = [51, 52, 53, 54, 55, 56, 57, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78] + 89400  ;0.6, c1

;sh = [32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66]+89600 ;0.5, c1 29,30,31,
;sh = [25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41] + 89700 ; not good
;sh = [42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70] + 89700 ; 0.85, c1
;sh = [4,5,6,7,8,9]+89500
;  sh = [67,68,69,70,71,72]+89600
;sh = [73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90] +89600 ;0.7, c1

;sh = [77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98, 100,101,102,103]+89700 ;0.85, c1, 200degree 
;sh = [5,6,7,8,9,10,11,12,13,14,15,16] + 89800; 0.5, c1, 200degree

;sh = [44,45,46] + 89800
;sh = [58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81] + 89800 ;0.6, c1, 200degree

;sh = [7,8,9,10,11,12,13,14,15] + 89900

;sh = [43]+89900 ;BPP at 105mm nonlinear interaction

;sh = [44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69] + 89900 ; 0.9 100mm nonlinear interaction
;sh = [72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95]+89900 ; 0.7 nonlinear interaction
sh = [99,100,101,102,103,104,105,106,107,108,109,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134] + 89900; 0.5 nonlinear interaction 110,111,112,113,  

;  rad = float([254, 264, 274,$
;     245, 255, 265,$
;     228, 240, 252,$
;     193, 212, 231,$
;     171, 192, 213,$
;     213, 176, 157,$
;     128, 149, 169, 188,$
;     119, 126, 136, 154])
;  th = float([0, 0, 0,$
;    2, 2, 2,$
;    4, 4, 4,$
;    6, 6, 6,$
;    7, 7, 7,$
;    4, 6, 7,$
;    8, 8, 8, 8,$
;    9, 9, 9, 9])
  
  sh_num = n_elements(sh)
  
  rad = dblarr(sh_num)
  th = dblarr(sh_num)
  corr_array = ptrarr(sh_num)
  envel_value = dblarr(sh_num)
  xcorr_value = dblarr(sh_num)
  
  isatfork_mean = dblarr(sh_num)
  vfloatfork_mean = dblarr(sh_num)
  trange = [0.005, 0.015]
  for i = 0,sh_num-1 do begin
    mdsopen,'h1data',sh(i)
      rad[i]=mdsvalue('\H1DATA::TOP.FLUCTUATIONS.FORK_PROBE:STEPPERXPOS')
      th[i]=mdsvalue('\H1DATA::TOP.FLUCTUATIONS.FORK_PROBE:STEPPERYPOS')
    a = getpar(sh[i],'isat',y=y1,tw=[0.010,0.050])
    a = getpar(sh[i],'isatfork',y=y2,tw=[0.010,0.050])
    a = getpar(sh[i],'vfloatfork',y=y3,tw=[0.010,0.050])
    corr_array[i] = ptr_new(corr_time(y1.t,y1.v,y2.v,trange=trange,freq_filter = [50e3, 500e3],fast=8.0))
    envel_value[i] = mean((*corr_array[i]).envel_mean)
    xcorr_value[i] = mean((*corr_array[i]).xcorr_mean)
    
    y2_cut = jw_select_time(y2.t,y2.v,trange)
    y3_cut = jw_select_time(y3.t,y3.v,trange)
    isatfork_mean[i] = mean(y2_cut.yvector)
    vfloatfork_mean[i] = mean(y3_cut.yvector)
    
;    if i lt 5 then begin
;      b = jw_spectrum(y1.t,y1.v,y1.v,trange)
;      c = jw_spectrum(y2.t,y2.v,y2.v,trange)
;      d = jw_spectrum(y1.t,y1.v,y2.v,trange)
;      c = jw_spectrum(y3.t,y3.v,y3.v,[0.040,0.050])
;      ycplot, b.freq, b.power, /ylog, out_base_id = spec_graph
;      ycplot, c.freq, c.power, /ylog, oplot_id = spec_graph
;      ycplot, d.freq, d.coherency
;    endif
    
;    b = jw_spectrum(y2.t,y2.v,y2.v,trange)
;    if i eq 0 then begin
;      ycplot, b.freq, b.power, /ylog, out_base_id = spec_graph
;    endif else begin
;      ycplot, b.freq, b.power, /ylog, oplot_id = spec_graph
;    endelse
  endfor

  
  r=dblarr(sh_num)
  z=dblarr(sh_num)
  n=n_elements(rad)
  
  for i=0,sh_num-1 do begin
   fppos3,rad(i)-10,th(i),rdum,zdum
   r(i)=rdum & z(i)=zdum
  endfor
  
  stop
  
  loaddata
  
  mb_cart2flux, r*1e-3,z*1e-3,rho,eta,phi=7.2*!dtor & rho=sqrt(rho)
  
  window, 1
  contourn2, envel_value, r, z, /irr, /dots,pal=-2, pos=posarr(2,1,0),/cb
  contourn2, xcorr_value, r, z, /irr, /dots,pal=-2, pos=posarr(/next),/noer,/cb
  
  window, 2
  contourn2, isatfork_mean, r, z, /irr, /dots,pal=-2, pos=posarr(2,1,0),/cb
  contourn2, vfloatfork_mean, r, z, /irr, /dots,pal=-2, pos=posarr(/next),/noer,/cb
  
  window, 3
  contourn2, envel_value, rho, eta, /irr, /dots,pal=-2, pos=posarr(2,1,0),/cb
  contourn2, xcorr_value, rho, eta, /irr, /dots,pal=-2, pos=posarr(/next),/noer,/cb
  
  window, 4
  contourn2, isatfork_mean, rho, eta, /irr, /dots,pal=-2, pos=posarr(2,1,0),/cb
  contourn2, vfloatfork_mean, rho, eta, /irr, /dots,pal=-2, pos=posarr(/next),/noer,/cb
  
  ycplot, rho[0:2], isatfork_mean[0:2]
  
;  for i = 0, sh_num-1 do begin
;    ycplot, (*corr_array[i]).lag, (*corr_array[i]).xcorr[0,*], out_base_id = oid
;    ycplot, (*corr_array[i]).lag, (*corr_array[i]).envel[0,*], oplot_id = oid
;  endfor
;  
;  for i = 0, sh_num-1 do begin
;    ycplot, (*corr_array[i]).lag, (*corr_array[i]).xcorr[1,*], out_base_id = oid
;    ycplot, (*corr_array[i]).lag, (*corr_array[i]).envel[1,*], oplot_id = oid
;  endfor
  
  ycplot, envel_value
  ycplot, xcorr_value
  stop
end