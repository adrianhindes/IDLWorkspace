pro plot_jet_phase, shotnumber,refchannel=refchannel, fmin=fmin,fmax=fmax

default,shotnumber
default,refchannel,'BES-1-2'
default,fmin,960
default,fmax,1040
default,savefile,'tmp\'+i2str(shotnumber)+'_'+refchannel+'_show_all_ky6D_power.sav'


restore, 'tmp\'+i2str(shotnumber)+'_'+refchannel+'_show_all_ky6D_power.sav'

dummy=min(abs(fscale-fmin),find1)
dummy=min(abs(fscale-fmax),find2)
contour, ph_matrix[*,find1:find2], indgen(32)+1,fscale[find1:find2],/fill,nlevels=50

zr_pos = fltarr(2,32)
fibre = intarr(32)
mirror_m=1500
nch=32
chname_arr = strarr(nch)
phase_arr=fltarr(nch)
dev_arr=fltarr(nch)
for i=0,nch-1 do begin
  chname_arr[i]='BES-'+i2str((i)/8+1)+'-'+i2str((i mod 8) + 1)
  fibre[i] = ky6d_fibre_number(shotnumber,chname_arr[i])
  zr_pos[*,i] = ky6_fibre_pos(shotnumber,fibre[i],mirror=mirror_m,time=timerange,relative=relative,z_error=z_error)
  if zr_pos[1,i] EQ 0 then begin
    phase_arr[i]=mean(ph_matrix[i,find1:find2])
    dev_arr[i]=stddev(ph_matrix[i,find1:find2])
  endif
endfor


ind_sort=sort(zr_pos[0,*])
ind_sort=ind_sort[where(zr_pos[1,ind_sort] EQ 0)]
;print,'phase, dev, z_pos'
;print,[transpose(phase_arr[ind_sort]),transpose(dev_arr[ind_sort]),zr_pos[0,ind_sort],zr_pos[1,ind_sort]]
plot, zr_pos[0,ind_sort]/1000,phase_arr[ind_sort],yrange=[-1,1],psym=7,ytitle='Phase[Pi]',xtitle='Hight above midplane[m]'
ERRPLOT,zr_pos[0,ind_sort]/1000,phase_arr[ind_sort]-dev_arr[ind_sort]/2,phase_arr[ind_sort]+dev_arr[ind_sort]/2
  stop

end