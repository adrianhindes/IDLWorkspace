pro help_pro, r_name, head=head, source=source

;**********************************************************
;*                          help_pro                      *
;**********************************************************
;* This routine writes the comment lines at the beginning * 
;* of the name routine.                                   *
;**********************************************************
;*Inputs:                                                 *
;*        name: [STRING], name of the routine             *
;*        /head: returns the header of the file           *
;*        /source: writes the source of the routine       *
;*Output:                                                 *
;*        Prints the header of file                       *
;**********************************************************
if (strupcase(!version.os) eq 'WIN32') then string_vec=strsplit(!path,';',/extract)
if (strupcase(!version.os) eq 'linux') then string_vec=strsplit(!path,':',/extract)

for i=0,n_elements(string_vec)-1 do begin
  fname=dir_f_name(string_vec[i],r_name+'.pro')
  bl=file_test(fname)
  if (bl eq 1) then break
endfor
if (bl eq 0) then begin
  fname=dir_f_name('.',r_name+'.pro')
  if not (file_test(fname)) then begin
    print,"The procedure couldn't be found. Returning..."
    return
  endif
endif
openr,unit,fname,error=e,/get_lun 

if (keyword_set(source)) then begin
  print, fname
  return
endif
c = 0l
  while not (EOF(unit)) do begin
    str = ''
    readf, unit, str
    c_last=c
    s=strpos(str,';')
    if ((s gt -1 and s lt 5) or c eq 0) then begin
      str=strjoin(strsplit(str,';',/extract),'')
      if (s gt -1 and s lt 5) then begin
        if keyword_set(head) then begin
          close,unit & free_lun,unit
          return
        endif
        c=c+1
      endif
      print, str
    endif
    if (c_last eq c and c_last ne 0) then begin
      break
    endif
 endwhile
 close,unit & free_lun,unit  
end