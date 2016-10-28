pro database_del_rec, shot, time, database=database, ind=ind, error=error

Compile_Opt defint32

if not (defined(ind)) then ind=where((database.shot eq shot) and (database.time eq time))

if (ind[0] eq -1 or ind[0] gt n_elements(database)-1) then begin
  print, 'No ELM event in the database with given shot and time or the given index is too big. Now returning...'
  error=2
  return
endif else begin
  if ((ind[0] eq 0) or (ind[0] eq n_elements(database)-1)) then begin
    if (ind[0] eq n_elements(database)-1) then begin
      database=database[0:n_elements(database)-2]
    endif
    if (ind[0] eq 0) then begin
      database=database[1:n_elements(database)-1]
    endif
  endif else begin
    db1=database[0:ind[0]-1]
    db2=database[ind[0]+1:n_elements(database)-1]
    database=[db1,db2]
  endelse  
endelse

end 