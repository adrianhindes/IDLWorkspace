pro do_120220


shot = 6057
timerange = [2.2,2.5]
refs = ['BES-1-2','BES-1-3','BES-1-4','BES-1-5','BES-1-6']
for i=0,n_elements(refs)-1 do begin
  ref = refs[i]
  show_all_kstar_bes_power,shot,/crosscorr,timerange=timerange,taurange=[-300,300],/norm,ref=ref,lowcut=20,taures=1.5,$
    savefile=i2str(shot)+'_BES_CCF_'+ref+'_'+string(timerange[0],format='(F4.2)')+'-'+string(timerange[1],format='(F4.2)')+'.sav'
  show_all_kstar_ecei_power,shot,/crosscorr,timerange=timerange,taurange=[-300,300],/norm,ref=ref,lowcut=20,$
    savefile=i2str(shot)+'_ECEI-BES_CCF_'+ref+'_'+string(timerange[0],format='(F4.2)')+'-'+string(timerange[1],format='(F4.2)')+'.sav'
endfor


end