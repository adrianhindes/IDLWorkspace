pro plot_elms, shot, timerange, prectype
default, shot, 6123
default, timerange, [2,4]
default,channel, 'BES-4-8'
default,halphachan,'\TOR_HA09'
default,elmtype,-1
  twin=0.005
  twinbes=0.0005
  cd, 'd:\KFKI\Measurements\KSTAR\Measurement'
  restore, 'elmdatabase.sav'
  save, database, filename='elmdatabase.sav.bak'
  ;ind=where(database.shot eq shot and (database.time gt timerange[0] and database.time lt timerange[1]))
  if type eq -1 then begin
    ind=findgen(n_elements(database))
  endif else begin
    ind=where(database.shot eq shot and database.prec_type eq prectype)
  endelse 
  for i=0,n_elements(ind)-1 do begin 
    print, strtrim(round(double(i)/double(n_elements(ind))*100.),2)+'%'
    show_rawsignal, database[ind[i]].shot, channel, timerange=[database[ind[i]].time-twin,database[ind[i]].time+twin],$
                    int=5, position=[0.1,0.1,0.9,0.5], ystyle=1, title=' '
    show_rawsignal, database[ind[i]].shot, halphachan, timerange=[database[ind[i]].time-twin,database[ind[i]].time+twin],$
                    position=[0.1,0.5,0.9,0.9], xcharsize=0.01, /noerase, ystyle=1
    ;cursor, x, y, /down
    if database[ind[i]].prec_type eq -1 then begin
      read, 'Precursor type? (0:No prec, 1:long const, 2:short exp, 3:multielm, 4:freq change, 100: save database)',pt
      database[ind[i]].prec_type=pt
      if (pt eq 100) then begin
        save, database, filename='elmdatabase.sav'
        print, 'Database saved!'
        read, 'Precursor type? (0:No prec, 1:long const, 2:short exp, 3:multielm, 4:freq change, 100: save database)',pt
        database[ind[i]].prec_type=pt
      endif
    endif
  endfor
  print, 'Database saved! Returning...'
  save, database, filename='elmdatabase.sav'
end