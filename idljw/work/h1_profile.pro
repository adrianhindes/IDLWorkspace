pro h1_profile

  a = getpar(89381,'isat',y=y01,tw=[0.010,0.050])
  a = getpar(89383,'isat',y=y02,tw=[0.010,0.050])
  a = getpar(89384,'isat',y=y03,tw=[0.010,0.050])
  a = getpar(89385,'isat',y=y04,tw=[0.010,0.050])
  a = getpar(89386,'isat',y=y05,tw=[0.010,0.050])
  
;  a = jw_spectrogram(y01.t,y01.v,y01.v,/power_plot)
;  a = jw_spectrogram(y02.t,y02.v,y02.v,/power_plot)
;  a = jw_spectrogram(y03.t,y03.v,y03.v,/power_plot)
;  a = jw_spectrogram(y04.t,y04.v,y04.v,/power_plot)
;  a = jw_spectrogram(y05.t,y05.v,y05.v,/power_plot)
  
  trange = [0.01, 0.02]
  y01 = select_time(y01.t,y01.v,trange)
  y02 = select_time(y02.t,y02.v,trange)
  y03 = select_time(y03.t,y03.v,trange)
  y04 = select_time(y04.t,y04.v,trange)
  y05 = select_time(y05.t,y05.v,trange)
  
  a = getpar(89389,'isatfork',y=y11,tw=[0.010,0.050])
  a = getpar(89388,'isatfork',y=y12,tw=[0.010,0.050])
  a = getpar(89386,'isatfork',y=y13,tw=[0.010,0.050])
  a = getpar(89391,'isatfork',y=y14,tw=[0.010,0.050])
  a = getpar(89390,'isatfork',y=y15,tw=[0.010,0.050])
  
  y11 = select_time(y11.t,y11.v,trange)
  y12 = select_time(y12.t,y12.v,trange)
  y13 = select_time(y13.t,y13.v,trange)
  y14 = select_time(y14.t,y14.v,trange)
  y15 = select_time(y15.t,y15.v,trange)
  
  position_0 = [0., 3., 6., 9., 10.5]
  position_1 = ([24., 26., 28., 29., 30.] - 24)*2.
  
  mean_0 = dblarr(5)
  mean_1 = dblarr(5)
  
  mean_0[0] = mean(y01.yvector)
  mean_0[1] = mean(y02.yvector)
  mean_0[2] = mean(y03.yvector)
  mean_0[3] = mean(y04.yvector)
  mean_0[4] = mean(y05.yvector)

  mean_1[0] = mean(y11.yvector)
  mean_1[1] = mean(y12.yvector)
  mean_1[2] = mean(y13.yvector)
  mean_1[3] = mean(y14.yvector)
  mean_1[4] = mean(y15.yvector)

  
  std_0 = dblarr(5)
  std_0[0] = sqrt(variance(y01.yvector))
  std_0[1] = sqrt(variance(y02.yvector))
  std_0[2] = sqrt(variance(y03.yvector))
  std_0[3] = sqrt(variance(y04.yvector))
  std_0[4] = sqrt(variance(y05.yvector))
  
  std_1 = dblarr(5)
  std_1[0] = sqrt(variance(y11.yvector))
  std_1[1] = sqrt(variance(y12.yvector))
  std_1[2] = sqrt(variance(y13.yvector))
  std_1[3] = sqrt(variance(y14.yvector))
  std_1[4] = sqrt(variance(y15.yvector))
  
  t01 = jw_bandpass(y01.yvector,0.005,1.0)
  t02 = jw_bandpass(y02.yvector,0.005,1.0)
  t03 = jw_bandpass(y03.yvector,0.005,1.0)
  t04 = jw_bandpass(y04.yvector,0.005,1.0)
  t05 = jw_bandpass(y05.yvector,0.005,1.0)
  
  t11 = jw_bandpass(y11.yvector,0.005,1.0)
  t12 = jw_bandpass(y12.yvector,0.005,1.0)
  t13 = jw_bandpass(y13.yvector,0.005,1.0)
  t14 = jw_bandpass(y14.yvector,0.005,1.0)
  t15 = jw_bandpass(y15.yvector,0.005,1.0)

  std_t0 = dblarr(5)
  std_t0[0] = sqrt(variance(t01))
  std_t0[1] = sqrt(variance(t02))
  std_t0[2] = sqrt(variance(t03))
  std_t0[3] = sqrt(variance(t04))
  std_t0[4] = sqrt(variance(t05))
  
  std_t1 = dblarr(5)
  std_t1[0] = sqrt(variance(t11))
  std_t1[1] = sqrt(variance(t12))
  std_t1[2] = sqrt(variance(t13))
  std_t1[3] = sqrt(variance(t14))
  std_t1[4] = sqrt(variance(t15))
  
  
  ycplot, position_0, mean_0, error=std_0, out_base_id = oid
  ycplot, position_1, 3.*mean_1, error=3.*std_1, oplot_id = oid
  
  
  ycplot, position_0, std_t0, out_base_id = oid
  ycplot, position_1, 3.*std_t1, oplot_id = oid
  
  a = jw_spectrum(y01.tvector,y01.yvector,y01.yvector,[0.01,0.02])
  b = jw_spectrum(y02.tvector,y02.yvector,y02.yvector,[0.01,0.02])
  c = jw_spectrum(y03.tvector,y03.yvector,y03.yvector,[0.01,0.02])
  d = jw_spectrum(y04.tvector,y04.yvector,y04.yvector,[0.01,0.02])
  e = jw_spectrum(y05.tvector,y05.yvector,y05.yvector,[0.01,0.02])
  
  ycplot, a.freq, a.power, /ylog,  out_base_id = oid
  ycplot, a.freq, b.power, /ylog, oplot_id = oid
  ycplot, a.freq, c.power, /ylog, oplot_id = oid
  ycplot, a.freq, d.power, /ylog, oplot_id = oid
  ycplot, a.freq, e.power, /ylog, oplot_id = oid
  

  
;  a = jw_spectrum(y11.tvector,y11,yvector,y11.yvector,[0.01,0.02],/power_plot,/ylog)
;  a = jw_spectrum(y12.tvector,y12,yvector,y12.yvector,[0.01,0.02],/power_plot,/ylog)
;  a = jw_spectrum(y13.tvector,y13,yvector,y13.yvector,[0.01,0.02],/power_plot,/ylog)
;  a = jw_spectrum(y14.tvector,y14,yvector,y14.yvector,[0.01,0.02],/power_plot,/ylog)
;  a = jw_spectrum(y15.tvector,y15,yvector,y15.yvector,[0.01,0.02],/power_plot,/ylog)
  
  
  
end