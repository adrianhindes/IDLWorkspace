pro do_120206a

shot = 6123
timerange_1 = [1.2,1.3,1.4,1.5,1.6]
timerange_2 = [1.3,1.4,1.5,1.6,1.7]
for i=0,n_elements(timerange_1)-1 do begin
  show_all_kstar_bes_power,shot,timerange=timerange,$
    savefile=i2str(shot)+'_BES_APS_'+string(timerange[0],format='(F4.2)')+'-'+string(timerange[1],format='(F4.2)'),/autopower
  show_all_kstar_ecei_power,shot,timerange=timerange,$
    savefile=i2str(shot)+'_ECEI_APS_'+string(timerange[0],format='(F4.2)')+'-'+string(timerange[1],format='(F4.2)'),/autopower
  show_all_kstar_ecei_power,shot,timerange=timerange,taurange=[-300,300],/norm,lowcut=20,$
    savefile=i2str(shot)+'_ECEI-BES_CCF_'+string(timerange[0],format='(F4.2)')+'-'+string(timerange[1],format='(F4.2)'),/crosscorr
endfor

end