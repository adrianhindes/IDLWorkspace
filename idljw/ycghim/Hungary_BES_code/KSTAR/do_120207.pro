pro do_120207

shot = 6057
timerange=[1.7,2]
  show_all_kstar_bes_power,shot,timerange=timerange,$
    savefile=i2str(shot)+'_BES_APS_'+string(timerange[0],format='(F4.2)')+'-'+string(timerange[1],format='(F4.2)'),/autopower
  show_all_kstar_ecei_power,shot,timerange=timerange,$
    savefile=i2str(shot)+'_ECEI_APS_'+string(timerange[0],format='(F4.2)')+'-'+string(timerange[1],format='(F4.2)'),/autopower

end