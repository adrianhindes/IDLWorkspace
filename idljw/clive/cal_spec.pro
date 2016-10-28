read_spe,'~/share/greg/ipad_1000ms_717nm.spe',l,t,d
wset2,0
imgplot,(d(*,*,23))
wset2,1
read_spe,'~/share/greg/rel_cal_1200g_717nm_100ms_50micronslit.spe',l,t,d
imgplot,d(*,*,0),/cb
end
