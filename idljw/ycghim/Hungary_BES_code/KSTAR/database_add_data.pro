pro database_add_data, shot, time, database, ind=ind, $
                       tagname=tagname, data=data, error=error

Compile_Opt defint32

bl=tag_exist(database,tagname)
if (bl) then begin
    tag_ind=where(tag_names(database) eq strupcase(tagname))
endif else begin
    print, 'There is no "'+tagname+'" tagname in the database. Available ones are: '+ tag_names(database)
    error=1
    return
endelse
  
rec_ind=where((database.shot eq shot) and (database.time eq time))
if rec_ind[0] eq -1 then begin
  print, "The record with the given shot and time or index doesn't exist. Now creating the record."
  database_new_rec, shot, time, database
endif
database[rec_ind].(tag_ind)=data

end