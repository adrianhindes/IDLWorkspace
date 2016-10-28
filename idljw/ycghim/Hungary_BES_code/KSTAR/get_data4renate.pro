pro get_data4renate, shot, bgsub=bgsub, user=user, bgtime=bgtime, datatime=datatime, ray_div=ray_div

;******************************************************
;*                  get_data4renate                   *
;******************************************************
;* Creates a file in working directory which contains *
;* data for the renate simulation.                    *
;******************************************************
;* INPUTs:                                            *
;*          shot: the shot number                     *
;*          /bgsub: do the background subtraction     *
;*                  (OPTIONAL, default:1)             *
;* OUTPUTs:                                           *
;*          none, creates a file called:              *
;*          RENATE_(shotnumber)_data.sav              *
;******************************************************

  default, user, 'lampee'
  default, shot, 6123
  default, bgsub, 1
  default, bgtime, [1.762,1.777]
  default, datatime, [1.74,1.76]
  
  if user eq 'lampee' then cd, 'D:\KFKI\Measurements\KSTAR\Measurement'
  if (keyword_set(bgsub)) then begin
    if (defined(bgtime)) then begin
      t1=bgtime[0]
      t2=bgtime[1]
    endif else begin
      show_rawsignal, shot, 'BES-1-1'
      print, 'Click on the timerange for the background subtraction!'
      cursor,t1,x,/down
      cursor,t2,x,/down
    endelse
    bgsub_relcal=dblarr(4,8)
    for i=0,3 do begin
      for j=0,7 do begin
        get_rawsignal,shot,'BES-'+strtrim(i+1,2)+'-'+strtrim(j+1,2),t,d,timerange=[t1,t2], nocalibrate=0
        bgsub_relcal[i,j]=mean(d)
      endfor
    endfor
    
    bgsub_norelcal=dblarr(4,8)
    for i=0,3 do begin
      for j=0,7 do begin
        get_rawsignal,shot,'BES-'+strtrim(i+1,2)+'-'+strtrim(j+1,2),t,d,timerange=[t1,t2], nocalibrate=1
        bgsub_norelcal[i,j]=mean(d)
      endfor
    endfor    
    
    bgtime=[t1,t2]
  endif else bgtime=[-1,-1]
  if (defined(datatime)) then begin
    t1=datatime[0]
    t2=datatime[1]
  endif else begin
    print, 'Click on a prefered time for RENATE!'
    cursor, t1,x,/down
    show_rawsignal, shot, 'BES-1-1', timerange=[t1-0.1,t1+0.1]
    print, 'Click on the timerange for RENATE!'
    cursor,t1,x,/down
    cursor,t2,x,/down
  endelse
  
  ;Get the calibrated data
  abs_cal_fac=calc_abs_cal_fac(shot)
  data_relcal=dblarr(4,8)
  for i=0,3 do begin
    for j=0,7 do begin
      get_rawsignal,shot,'BES-'+strtrim(i+1,2)+'-'+strtrim(j+1,2),t,d,timerange=[t1,t2], nocalibrate=0
      if (keyword_set(bgsub)) then begin
        data_relcal[i,j]=(mean(d)-bgsub_relcal[i,j])*abs_cal_fac
      endif else begin
        data_relcal[i,j]=mean(d)*abs_cal_fac
      endelse
    endfor
  endfor
  
  ;Get the data without any calibration
  data_norelcal=dblarr(4,8)
  for i=0,3 do begin
    for j=0,7 do begin
      get_rawsignal,shot,'BES-'+strtrim(i+1,2)+'-'+strtrim(j+1,2),t,d,timerange=[t1,t2], nocalibrate=1
      if (keyword_set(bgsub)) then begin
        data_norelcal[i,j]=(mean(d)-bgsub_norelcal[i,j])*abs_cal_fac
      endif else begin
        data_norelcal[i,j]=mean(d)*abs_cal_fac
      endelse
    endfor
  endfor
  
  bgsub_norelcal*=abs_cal_fac
  bgsub_relcal*=abs_cal_fac
  
  rel_cal_fac=dblarr(4,8)
  c=getcal_kstar(shot)
  for i=0,3 do rel_cal_fac[i,*]=c[i*8:i*8+7]
  
  signal_relcal=data_relcal
  signal_norelcal=data_norelcal
  position=getcal_kstar_spat(shot)
  area=getcal_kstar_spat(shot, /area)
  corner=getcal_kstar_spat(shot, /detcorn)
  kstar_density, 6123, dens_relc, reff, rbes, timerange_on=datatime, timerange_off=bgtime, /relcal
  kstar_density, 6123, dens_filt, reff, rbes, timerange_on=datatime, timerange_off=bgtime
  timerange=[t1,t2]
  n=6
  data_renate=dblarr(n,4,8)
  trans=dblarr(n,4,8)
  divergence=dblarr(n)
  for i=0,n-1 do begin
    divergence[i]=i
    get_rawsignal, shot, 'E_NBI', t, d, /store
    ebeam=max(d)*1e-3
    kstar_filter_transmission, shot, transmission=trans_temp, ebeam=ebeam, ray_divergence=divergence[i]
    trans[i,*,*]=trans_temp
    trans=trans/100.
    ;data_renate[i,*,*]=(signal_norelcal+bgsub_norelcal)/trans[i,*,*] ;according to David, it is the correct method, but RENATE only calculates light coming from the beam
    data_renate[i,*,*]=(signal_norelcal)/trans[i,*,*]
  endfor
  
  comment={shot:'The shot number',$
           timerange:'The range for the signal averaging [s]',$
           bgtime:'The timerange of the background subtraction [s]',$
           signal_relcal:'The BES signal with relative and absolute calibration',$
           bgsub_relcal:'Background data with relative and absolulte calibration',$
           signal_norelcal:'The BES signal without relative and with absolute calibration',$
           bgsub_norelcal:'Background data without relative, with absolute calibration',$
           density_relcal:'The density profile [m^-3] from relatively calculated BES data',$
           density_filter:'The density profile [m^-3] from BES data calculated with the filter characteristic',$
           position:'The position of BES channels, [R[mm],z[mm],phi[rad, 0 is the mirror center]]',$
           area:'The area of the BES channels [R[mm],z[mm]]',$
           corner:'Corner is [4,8,4,*], where the 3rd index goes anticlockwise from the bottom left corner [mm]',$
           reff:'The effective small radius for the density profile [m]',$
           rbes:'The BES small radius for the density profile [m]',$
           filter_transmission:'The filter transmission for each channel',$
           rel_cal_fac:'The relative calibration factor for each channel',$
           abs_cal_fac:'The absolute calibration factor for the shot',$
           data_renate:'The data necessary for RENATE, equals (signal_norelcal+bgsub_norelcal)/trans',$
           ray_divergence:'The divergence of the light ray at the filter'}
           
  data={shot:shot,$
        timerange:timerange,$
        bgtime:bgtime,$
        signal_relcal:signal_relcal,$
        bgsub_relcal:bgsub_relcal,$
        signal_norelcal:signal_norelcal,$
        bgsub_norelcal:bgsub_norelcal,$
        density_relcal:dens_relc,$
        density_filter:dens_filt,$    
        position:position,$
        area:area,$
        corner:corner,$
        reff:reff,$
        rbes:rbes-1.8,$
        filter_transmission:trans,$
        rel_cal_fac:rel_cal_fac,$
        abs_cal_fac:abs_cal_fac,$
        data_renate:data_renate,$
        divergence:divergence}
  erase
  plot, position[0,*,0], signal_relcal[0,*], /noerase
  oplot, position[1,*,0], signal_relcal[1,*], linestyle=1
  oplot, position[2,*,0], signal_relcal[2,*], linestyle=2
  oplot, position[3,*,0], signal_relcal[3,*], linestyle=3
  print, 'If everything seems to be OK, then write .continue (or .con) and data will be Saved!'
  stop
  filename = 'RENATE_'+strtrim(shot,2)+'_data_.sav'
  bl=file_test(filename)
  i=0
  while bl do begin
    filename='RENATE_'+strtrim(shot,2)+'_data_'+strtrim(i,2)+'.sav'
    bl=file_test(filename)
    i+=1
  endwhile
  save, data, comment, filename=filename
  print, 'Saved!'
end