pro database_del_tag, database, tagname, error=error

;*************************************************************
;*                     database_del_tag                      *
;*************************************************************
;* Deletes a tag from a structure based database, which was  *
;* restored from a .sav file.                                *
;*************************************************************
;*INPUTs:                                                    *
;*       database: structure, which needs a new tag          *
;*       tagname: name of the deleted tag in a string        *
;*OUTPUT:                                                    *
;*       database: the modified database                     *
;*************************************************************

Compile_Opt defint32

db_tagnames=tag_names(database)
ind=where(db_tagnames eq strupcase(tagname))
if (ind[0] eq -1) then begin
  print, 'There is no tagname in the database: '+tagname+' Returning...'
  error=1
  return
endif
indn=where(db_tagnames ne strupcase(tagname))

for i=0, n_elements(indn)-1 do begin
  if i eq 0 then temp=create_struct(db_tagnames[indn[i]], database[0].(indn[i])) else $
    temp=create_struct(temp, db_tagnames[indn[i]], database[0].(indn[i]))
endfor
temp=replicate(temp,n_elements(database))
for i=0, n_elements(indn)-1 do begin
  temp.(i)=database.(indn[i])
endfor
database=temp

end
