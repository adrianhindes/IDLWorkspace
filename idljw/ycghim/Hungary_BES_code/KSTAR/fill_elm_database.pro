pro fill_elm_database, shot, channel
  default,channel, 'BES-4-8'
  default,halphachan,'\TOR_HA09'
  twin=0.005
  twinbes=0.0005
  cd, 'D:\KFKI\Measurements\KSTAR\Measurement'
  restore, 'elmdatabase.sav'
  save, database, filename='elmdatabase.sav.bak'
  ind=where(database.shot eq shot)
  ind=where(database.time gt 3.3 and database.shot eq 6125)
  for i=0,n_elements(ind)-1 do begin 
    print, strtrim(round(double(i)/double(n_elements(ind))*100.),2)+'%'
    show_rawsignal, database[ind[i]].shot, channel, timerange=[database[ind[i]].time-twin,database[ind[i]].time+twin],$
                    int=5, position=[0.1,0.1,0.9,0.5], ystyle=1, title=' '
    show_rawsignal, database[ind[i]].shot, halphachan, timerange=[database[ind[i]].time-twin,database[ind[i]].time+twin],$
                    position=[0.1,0.5,0.9,0.9], xcharsize=0.01, /noerase, ystyle=1
    get_rawsignal, database[ind[i]].shot, channel, t, d, timerange=[database[ind[i]].time-twin,database[ind[i]].time+twin]
    
    if (database[ind[i]].prec_time eq -1) then begin
      print, 'If you want to save, click on the right side of the graph!'
      print, 'Click on the start of the precursor! If there is no precursor, click out of the plot on the left.'
      cursor,tp,y,/down
      if (tp gt database[ind[i]].time+twin) then begin
        save, database, filename='elmdatabase.sav'
        print, 'Database saved!'
        print, 'Click on the start of the precursor! If there is no precursor, click out of the plot on the left!'
        cursor,tp,y,/down
      endif
      if (tp lt database[ind[i]].time-twin) then database[ind[i]].prec_time=-2 else database[ind[i]].prec_time=database[ind[i]].time-tp
    endif
    
    if (database[ind[i]].bes_time eq -1) then begin
      print, 'Click on the maximum of the BES signal, which supposed to be the ELM!'
      cursor,tp,y,/down
      if (tp lt database[ind[i]].time-twin) then begin
        database[ind[i]].bes_time=-2
      endif else begin
        a=max(d[where((t gt tp-twinbes) and (t lt tp+twinbes))],j)
        database[ind[i]].bes_time=(t[where((t gt tp-twinbes) and (t lt tp+twinbes))])[j]
      endelse
    endif
;    save, database, filename='elmdatabase.sav'
  endfor
  save, database, filename='elmdatabase.sav'
  print, 'Database saved!'
  
end