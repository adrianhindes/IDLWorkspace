pro plot_4_paper2, ps=ps, find=find

twin=0.005
channel='BES-4-8'
default, ps, 0
default, find, 0
restore, 'elmdatabase.sav'
  
if (find eq 1) then begin

  for j=4,4 do begin
    ind=where(database.prec_type eq j)
    for i=0,n_elements(ind)-1 do begin
        show_rawsignal, database[ind[i]].shot, channel, timerange=[database[ind[i]].time-twin,database[ind[i]].time+twin],$
                        int=5, ystyle=1, title=' '
        cursor, x, y, /down
        print, j, ind[i]
    endfor
  endfor
endif
pos=[[0.00,0.56,0.44,1.00],$
     [0.56,0.56,1.00,1.00],$
     [0.00,0.00,0.44,0.44],$
     [0.56,0.00,1.00,0.44]]

; good ones R these: 1 - 10, 2 - 269, 3 - 71, 4 - 118
ind=[10,269,71,118]
title=['a) Long, constant precursor',$
       'b) Exponential growth',$
       'c) Multiple ELMs',$
       'd) Frequency change in the oscillation']
       erase
  hardon, /color
  for i=0,3 do begin
    show_rawsignal, database[ind[i]].shot, channel, timerange=[database[ind[i]].time-twin,database[ind[i]].time+twin],$
                    int=5, ystyle=1, title=title[i]+', Shot: '+strtrim(database[ind[i]].shot,2), position=pos[*,i], /noerase,$
                    thick=2, charsize=1.5, /nolegend
  endfor
  hardfile, 'precursor_types.ps'      
end