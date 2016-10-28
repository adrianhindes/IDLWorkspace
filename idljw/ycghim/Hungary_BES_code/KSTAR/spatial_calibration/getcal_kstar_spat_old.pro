function getcal_kstar_spat_old,shot,errormess=errormess,new=new
shot_calfile=dir_f_name(local_default(cal_path),strtrim(shot,2)+'.spat.cal')
openr,unit,shot_calfile,error=e,/get_lun
txt=''
readf,unit,txt
r=''
readf,unit,r
z=''
readf, unit, z
phi=""
readf, unit, phi
close, unit
free_lun, unit
print, r, phi, z
r= strsplit(R,' ',/extract)
print, r
stop
r=r[2:n_elements(r)-1]
z= strsplit(z,' ',/extract)
z=z[2:n_elements(r)-1]
phi= strsplit(phi,' ',/extract)
phi=phi[2:n_elements(r)-1]
print, r, phi, z
help, r, phi, z
r=double(r)
z=double(z)
phi=double(phi)

end