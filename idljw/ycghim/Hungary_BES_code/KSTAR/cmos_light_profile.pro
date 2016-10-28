PRO cmos_light_profile,shot=shot

DEFAULT,shot,9078
DEFAULT,frame,7
DEFAULT,smooth_factor,5

RESTORE,'/home/bes/Data/'+i2str(shot)+'/'+i2str(shot)+'_CMOS_data.sav'

; Make the image
im=reform(abs(meas(frame,*,*)-meas(frame-1,*,*)))>0
nx = (size(im))[1]
ny = (size(im))[2]
im_mean = mean(im)

; Calculate the rotation of the image
FOR ind_rot=0,nx-1 DO BEGIN
  IF (WHERE(smooth(im(ind_rot,*),smooth_factor) GT im_mean*5) GT 0) THEN BEGIN
  
  ENDIF ELSE BEGIN
  
  ENDELSE
  
ENDFOR    
    


stop


END
