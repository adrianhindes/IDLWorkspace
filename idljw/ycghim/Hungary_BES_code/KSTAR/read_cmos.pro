function read_cmos, filename, bit8=bit8

;******************************************
;**         read_cmos.pro                **
;******************************************
;* This function reads the binary file    *
;* created by the PhotonFocus CMOS camera *
;* and returns it as an [1312,1082] array.*
;******************************************
;* INPUTs:                                *
;*   filename: the path of the file       *
;*   /bit8: if the image is on 8 bit      *
;*     resolution, this needs to be set   *
;* OUTPUT:                                *
;*   returns the image as an [1312,1082]  *
;******************************************

openr,unit,file,/get_lun,error=e
if (e ne 0) then begin
  print,'Error reading file.'
  return,0
endif  
if keyword_set(bit8) then begin
   d=assoc(unit,bytearr(1312,1082))
endif else begin
   d=assoc(unit,intarr(1312,1082))
endelse
im = d[0]
close,unit & free_lun,unit

return,im
end
