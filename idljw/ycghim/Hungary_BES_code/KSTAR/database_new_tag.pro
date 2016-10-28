pro database_new_tag, database, tagname, type=type, error=error

;*************************************************************
;*                     database_new_tag                      *
;*************************************************************
;* Puts a new tag into a structure based database, which was *
;* restored from a .sav file.                                *
;*************************************************************
;*INPUTs:                                                    *
;*       database: structure, which needs a new tag          *
;*       tagname: name of the new tag in a string            *
;*       type: type of the new tag eg.: type=dblarr(8,4,1)   *
;*             or type=long(-1). All the database will be    *
;*             filled up with values of this                 *
;*************************************************************


;type is a certain number which represents integer (et. -1),
;float(eg. float(-1)), double (eq. double(-1)) or any type o variable
default, type, -1
ind=where(tag_names(database) eq strupcase(tagname))
if (ind[0] ne -1) then begin
  print, 'There is a tag named '+tagname+' already in the database! Returning...'
  error=4
  return
endif
newline=create_struct(database[0], tagname, type)
nelm=n_elements(database[*])
ntag=n_tags(database[0])
newdb=replicate(newline,nelm)

for i=0,nelm-1 do begin
  for j=0,ntag-1 do begin
    newdb[i].(j)=database[i].(j)
  endfor
endfor
database=newdb
end
