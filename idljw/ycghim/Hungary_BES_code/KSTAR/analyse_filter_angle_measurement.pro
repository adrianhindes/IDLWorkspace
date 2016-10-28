pro analyse_filter_angle_measurement
  hardon, /color
  cd, 'D:\KFKI\Measurements\KSTAR\Measurement'
  ;shot=   [7604,7605,7606,7607,7608,7609,7610,7611,7612,7613,7614,7615,7616,7617,7618,7619,7620,7621,7622]
  ;steppos=[0,   200, 400, 600, 600, 800, 1000,1200,1100,900, 900, 700, 700, 500, 300, 100, 500, 700, 1255]
  ;shot=   [7604,7605,7606,7608,7609,7610,7611,7612,7614,7616,7617,7618,7619,7620,7621]
  ;steppos=[0,   200, 400, 600, 800, 1000,1200,1100,900, 700, 500, 300, 100, 500, 700]
  
  shot=   [7604,7605,7606,7608,7609,7610,7611,7612,7614,7616,7617,7618,7619]
  steppos=[0,   200, 400, 600, 800, 1000,1200,1100,900, 700, 500, 300, 100]
  
  n=n_elements(steppos)         
  ;Filter calibration factor calculation
  step=[1255,1000,800,600,400]
  distan=[31,27.6,25.1,22.35,19.6]
  angle=atan((31-distan)/83)
  error=dblarr(5)
  error[*]=0.4
  p=mpfitfun('linear_fit', step, angle, error,double([-25,2000]))
  print, p
  data=dblarr(n)
  for i=0, n-1 do begin
    get_rawsignal, shot[i],'BES-1-1', t, d, /nocalib, timerange=[1,2]
    data[i]=total(d)/n_elements(d)
  endfor
  
  plot, p[0]+steppos*p[1], data, psym=4, xtitle='Filter angle [rad]', ytitle='Intensity [V]', ystyle=1, xstyle=1, $
        yrange=[-0.01,0.15], xrange=[0,0.55]
  hardfile, 'filter_angle_analysis.ps'
  save, angle, data, filename='filter_angle_analysis.sav'
  stop
end