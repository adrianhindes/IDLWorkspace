PRO compute_ligth_profile, shot=shot

;This program calculate the light profile and its error for the KSTAR CMOS camera measurements

DEFAULT, shot, 10709
DEFAULT,frame,26

restore,'/data/KSTAR/APDCAM/'+i2str(shot)+'/'+i2str(shot)+'_CMOS_data.sav'

pict = reform(meas(frame,*,*)-meas(frame-1,*,*))

stop



END