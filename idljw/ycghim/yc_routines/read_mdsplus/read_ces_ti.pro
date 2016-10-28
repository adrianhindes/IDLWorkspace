; Plots the Ti info from CES
; Note that this procedure works for the shots from 2012 (#6471-8355) to 2013 (#8356-9427)

PRO read_ces_ti, shotnumber, result = result

  if (shotnumber GE 6471) AND (shotnumber LE 8355) then $
    campaign_year = 2012 $
  else if (shotnumber GE 8356) AND (shotnumber LE 9427) then $
    campaign_year = 2013 $
  else begin
    print, 'Specified shotnumber is not from 2012 or 2013.'
    return
  endelse

; Set the radial positions
; Note that the radial positions are based on the email from 
; Dr. Wonha Ko received on Sep. 4th. 2013.
  if campaign_year eq 2012 then begin
    r_pos = [1.800, 1.850, 1.900, 1.950, 2.000, 2.050, 2.100, 2.150, 2.170, 2.180, $
             2.190, 2.200, 2.205, 2.210, 2.215, 2.220, 2.225, 2.230, 2.235, 2.240, $
             2.245, 2.250, 2.255, 2.260, 2.265, 2.270, 2.275, 2.280, 2.285, 2.290, $
             2.295, 2.300]*1e2 ;in [cm]
  endif else if campaign_year eq 2013 then begin
    r_pos = [1.795, 1.850, 1.900, 1.950, 2.000, 2.050, 2.100, 2.150, 2.170, 2.180, $
             2.190, 2.200, 2.205, 2.210, 2.215, 2.220, 2.225, 2.230, 2.235, 2.240, $
             2.245, 2.250, 2.255, 2.260, 2.265, 2.270, 2.275, 2.280, 2.285, 2.290, $
             2.295, 2.300]*1e2 ;in [cm]
  endif 

  nch = 32

  print, 'Read CES data for Ch.', format='(A,$)'
  for i = 0, nch - 1 do begin
    print, ' ' + string(i+1, format='(i02)'), format='(A,$)'
    dataname = 'ces_ti'+string(i+1, format='(i02)')
    struc_data = read_kstar_data(shotnumber, dataname)
    if (struc_data.err eq 1) then begin
      print, 'Error occured for reading Ch.' + string(i+1, format='(i02)')
      print, struc_data.errmsg      
      return
    endif
    
    if i eq 0 then begin
      time = struc_data.t
      time_unit = struc_data.t_unit 
      data = fltarr(nch, n_elements(time))
      data_unit = struc_data.d_unit
      error = fltarr(nch, n_elements(time))
    endif
    data[i, *] = struc_data.d
    error[i, *] = struc_data.e
  endfor
  print, 'DONE!'

  ycshade, data, r_pos, time, xtitle = 'R [cm]', ytitle = 'Time ' + time_unit, ztitle = 'Temperature ' + data_unit, $
           title = string(shotnumber, format='(i0)') + ': Ion Temperature from CES'

  result = {d:data, d_unit:data_unit, $ 
            r:r_pos, r_unit:'[cm]', $
            t:time, t_unit:time_unit, $
            e:error}

END
