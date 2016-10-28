pro analyse_mirnov_coil, shot, ps=ps
default, shot, 6123
cd, 'd:\KFKI\Measurements\KSTAR\Measurement'
restore, 'elmdatabase.sav'
twin=0.00035
ind=where(database.shot eq shot and database.prec_type gt 0)

mirnov_names=['\MC1T01', '\MC1T02', '\MC1T03', '\MC1T04', '\MC1T05', '\MC1T06', '\MC1T07', '\MC1T08', '\MC1T09', $
                   '\MC1T11', '\MC1T12', '\MC1T13', '\MC1T14', '\MC1T15', '\MC1T16', '\MC1T17', '\MC1T18', '\MC1T19', $
                   '\MC1T20', '\MC1P01', '\MC1P02', '\MC1P03', '\MC1P04', '\MC1P05', '\MC1P06', '\MC1P07', '\MC1P08',$
                   '\MC1P09', '\MC1P10', '\MC1P11', '\MC1P12', '\MC1P13', '\MC1P14', '\MC1P15', '\MC1P16', '\MC1P17',$
                   '\MC1P18', '\MC1P19', '\MC1P20', '\MC1P21', '\MC1P22']
bes_chan='BES-4-8'
hardon, /color
posvec=plot_position(7,6, xgap=0.05)
;for i=0, n_elements(ind)-1 do begin
for i=0, 4 do begin
  for j=0,n_elements(mirnov_names)-1 do begin
    fluc_correlation, shot, timerange=[database[i].time-twin,database[i].time+twin], refchan=bes_chan, plotchan=mirnov_names[j], $
                      /noplot, outtime=outtime, outcorr=outcorr, /plot_spectra, outphase=outpower, inttime=5
    plot, outtime, outpower, position=posvec[j,*], /noerase, xcharsize=0.01, ycharsize=0.5
  endfor
  xyouts, 0.90, 0.96, strtrim(shot,2)+' ['+strtrim(database[i].time-twin)+','+strtrim(database[i].time+twin,2)+']'
  erase
endfor
hardfile, 'mirnov.ps'

end