pro bes_ecei_compare, postscript=postscript
  cd, 'C:\Users\lampee\KFKI\Measurements\KSTAR\Measurement'
  if not (file_test('elmdatabase.sav')) then begin
    
    shot=6123
    timevec=[2.408, 2.454, 2.468, 2.495, 2.509, 2.528, 2.567, 2.578, $
             2.598, 2.564, 2.665, 2.746, 2.852, 2.903, 3.001, 3.018, $
             3.052, 3.086, 3.178, 3.200, 3.301, 3.342, 3.373, 3.411, $
             3.435, 3.472, 3.538, 3.572, 3.624, 3.646, 3.647, 3.682, $
             3.713]
    struct={shot:shot,time:double(0),type:long(3)}
    struct=replicate(struct,n_elements(timevec))
    for i=0,n_elements(timevec)-1 do begin
      show_rawsignal, 6123, timerange=[timevec[i]-0.01,timevec[i]+0.01],'BES-4-8'
      cursor,x,y,/down
      struct[i].time=x
      struct[i].shot=shot
      struct[i].type=3
    endfor
    database=struct
    restore, 'elmdatabase.sav'
    for i=0,n_elements(database)-1 do begin
      show_rawsignal, database[i].shot, timerange=[database[i].time-0.005,database[i].time+0.003],'BES-4-8'
      cursor,x,y,/down
      if database[i].time-x lt 0 then database[i].prec_time=-1 else database[i].prec_time=database[i].time-x
    endfor
    save, database, filename='elmdatabase.sav'
  endif
  restore, 'elmdatabase.sav'
  hardon, /color
  set_plot_style, 'foile_eps_kg'
  for i=0,n_elements(database)-1 do begin
    plot_2d_radial_dist,6123,4,timerange=[database[i].time-0.001,database[i].time+0.0005], $
                        /bgsub, trange_bg=[0.89285708,0.98809517], colortable=0, int=2, $
                        nlev=40, charsize=2, thick=3
    erase
  endfor
  hardfile, '6123_rad_dist.ps'
  for i=0,n_elements(database)-1 do begin
    show_all_kstar_bes_power, 6123, timerange=[database[i].time-database[i].prec_time,database[i]-0.001.time-database[i].prec_time],$
                             /noerror, /plot_spectra
  endfor
  
  
end