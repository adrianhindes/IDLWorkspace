pro stepmotor_pos, R=R, pos=pos, adjust=adjust, calc_R=calc_R, noquery=noquery,$
                   error=error

;*****************************************************
;******************* stepmotor_pos *******************
;*****************************************************
;* The routine adjust the mirror stepmotor position  *
;* to the desired major radius.                      *
;*****************************************************
;*INPUTs:
;*         R: Major radius [m or mm]
;*         /adjust: adjust the stepmotor pos to 
;*
default, error, 0
default, noquery, 0
default, adjust, 0
if not keyword_set(calc_R) then begin
  if R lt 3 then R=long(R*1e3)

  if R lt 1890 then begin
     print, 'R=1.89m is the smallest major radius for BES. Returning...'
     pos=-1
     error=1
     return
  endif
  if R gt 2270 then begin
    print, 'R=2.27m is the smallest major radius for BES. Returning...'
    pos=-1
    error=1
    return
 endif

  restore, dir_f_name('cal','all_mirror_pos_7685.sav')
  a=min(abs(mirror_db[0:79].radial_position-R),i)
;  print, mirror_db[i].mirror_position
   mirpos=mirror_db[i].mirror_position
if adjust then begin
   cmd='/home/bes/Software/adj_stepmotor/adj_stepmotor 1 '+strtrim(mirpos,2)
;   if not noquery then begin
;      bl=''
;      read, 'Are you sure to set the stepmotor position to (y/n)'+strtrim(mirpos,2)'? ', bl
;      if bl eq 'y' then begin
;         spawn, cmd
;         print, 'Mirror stepmotor position is set to '+strtrim(mirpos,2)
;      endif else begin
;         print, 'User abort! Returning...'
;      endelse
;   endif else begin
      spawn, cmd
;   endelse
endif
pos=mirpos

endif else begin
  restore, dir_f_name('cal','all_mirror_pos_7685.sav')
  ind=where(mirror_db[0:79].mirror_position eq round(pos/1000)*1000)
  R=fix(mirror_db[ind].radial_position)
;  print,R
endelse

end
