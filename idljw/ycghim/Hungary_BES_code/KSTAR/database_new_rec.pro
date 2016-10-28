pro database_new_rec, shot, time, database, error=error

;*************************************************************
;*                     database_new_rec                      *
;*************************************************************
;* Puts a new record into a structure based database, which  *
;* was restored from a .sav file.                            *
;*************************************************************
;*INPUTs:                                                    *
;*       shot: the shot number of the shot                   *
;*       time: the time of the ELM event                     *
;*       database: structure, which needs a new tag          *
;*OUTPUT:                                                    *
;*       database: the modified database                     *
;*************************************************************

Compile_Opt defint32

rec_ind=where((database[*].shot eq shot) and (database[*].time eq time))

if (rec_ind eq -1) then begin
   newentry=replicate(database[0],1)
   n=n_tags(newentry)
   newentry.(0)=long(shot)
   newentry.(1)=time
   print, 'New entry: Shot: #'+strtrim(newentry.(0),2)+' Time: '+ strtrim(newentry.(1),2)+'s'
   for i=2,n-1 do newentry.(i)[*]=-1
   database=[database,newentry]
   rec_ind=n_elements(database)-1
endif else begin
  print, 'Record exists. Returning...'
  error=3
  return
endelse

end
