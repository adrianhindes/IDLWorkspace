FUNCTION read_parafile,name=name,ncol=ncol,shot=shot

;*** This routine reads data that has been stored with "write+parafile"
;*** The first column should contain the shot number!!!
;*** It will return the data stored in the first line where the entry in the
;*** first column is LE shot.
;*** ncol: number of columns

dummy=0l

dpi=fltarr(ncol-1)

openr,source,name,/get_lun,error=err
IF err NE 0 THEN BEGIN
;  print,'File not found:',name
  return,''
ENDIF
WHILE (NOT eof(source) AND (dummy LT shot)) DO BEGIN
  pi=dpi
  readf,source,dummy,dpi
  IF dummy GT shot THEN BEGIN
    close,source
    free_lun,source
    return,pi
  ENDIF
ENDWHILE
close,source
free_lun,source
return,dpi

END ;read_parafile
