read_spe,'~/share/greg/rel_cal_1200g_717nm_100ms_50micronslit.spe',l,t,d
s=d(*,5,5) 
l=reverse(l)
plot,l,s

dat=read_ascii('~/rel_cal_data.csv',delim=',')
dat=dat.(0)
l0=dat(0,*)
d0=dat(1,*)

s2=interpol(d0,l0,l)
oplot,l,s2/max(s2)*max(s),col=2
sens=s/s2
plot,l,s/s2,/noer,col=4

ix=value_locate(l,[728,706])

print,sens(ix(0))/sens(ix(1))
end
