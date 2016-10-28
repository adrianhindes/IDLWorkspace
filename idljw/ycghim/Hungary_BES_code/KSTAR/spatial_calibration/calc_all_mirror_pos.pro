pro calc_all_mirror_pos

cd, 'D:\KFKI\Measurements\KSTAR\Measurement'
n=80
mirpos=lindgen(n)*1000
database={name:'mirror_position',apd_pos:30000, mirror_position:long(0), spatcor:dblarr(4,8,3), radial_position:double(0)}
database=replicate(database,n*2)
restore, dir_f_name('cal','mirror_calibration_db_7685.sav') ;Read the calibration file from the sav file from calibrate_pco_image.pro
apd_pos=[30000,12150]
for k=0,1 do begin
  for j=0,n-1 do begin
    
    database[k*80+j].apd_pos=apd_pos[k]
    database[k*80+j].mirror_position=mirror_db[k].mirror_position[j]
    database[k*80+j].spatcor=reform(mirror_db[k].spatcor_d[j,*,*,*])
    database[k*80+j].radial_position=mirror_db[k].radial_position[j]
  endfor
endfor
mirror_db=database
save, mirror_db,filename=dir_f_name('cal','all_mirror_pos_7685.sav')

end