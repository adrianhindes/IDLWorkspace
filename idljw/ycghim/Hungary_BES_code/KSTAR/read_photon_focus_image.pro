function read_photon_focus_image, filename
;************************************************
; read_photon_focus_image
;************************************************
; The function reads 12 bit photon focus images 
; from the camera created binary fines and
; returns them as a 2D long type array.
;************************************************
openr, unit, filename, /get_lun
image=assoc(unit, intarr(1312,1082))
image2D=image[0]
free_lun, unit
return, image2D
end