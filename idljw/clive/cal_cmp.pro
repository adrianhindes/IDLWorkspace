dir='~/share/greg/'



f0='ipad_500ms_portwin_wed.spe'

f1='tshot  6.spe'

f2='tshot  30.spe';after realign, for to adjust f/#

read_spe,dir+f0,l,t,d0,str=str0
read_spe,dir+f1,l,t,d1,str=str1
read_spe,dir+f2,l,t,d2,str=str2

it0=60
it1=5
it2=5
nx=n_elements(l)
f0=reform(d0(nx/2,*,it0))
f0p=congrid(f0,20)*0.5
f1=reform(d1(nx/2,*,it1))
f2=reform(d2(nx/2,*,it2))
plot,f0p,yr=[0,20000]
oplot,f1,col=2
oplot,f2,col=3

end

