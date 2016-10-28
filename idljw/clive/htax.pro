path='~/spectrum/'
fil='Cs lamp.spe'
read_spe,path+fil,l,t,d

fil='514 filter.spe'
read_spe,path+fil,l,t,d

help,l,t,d
lb=l
da=total(d(*,000:450),2)
;da/=max(da)

la=l
plot,la,da,xr=658+[-3,3]*2,yr=[0,65535*10]
spawn,'mv ~/footer.xml ~/footer_cs.xml'
path='~/spectrum/'
fil='H lamp.spe'
read_spe,path+fil,l,t,d
help,l,t,d
lb=l
da=total(d(*,000:450),2) * 5. * 4./3.
;da/=max(da)

spawn,'mv ~/footer.xml ~/footer_h.xml'

la=l
oplot,la,da,col=2

stop
path='~/spectrum/'
;fil='2013 August 08 13_25_58.spe'
;fil='2013 August 08 13_28_41.spe'
;fil='658 filter.spe'
fil='658 filter.spe'
read_spe,path+fil,l,t,d
help,l,t,d
lb=l
db=d/max(d)
dba=interpol(db,lb,la)
oplot,la,dba,col=2
oplot,la,da*dba,col=3

print, total(la*da)/total(da)
cwl1=total(la*da*dba)/total(da*dba)
print, cwl1
datmp=da & idx=where(la ge 655.5 and la le 656.5) & datmp(idx)*=1.1
cwl2=total(la*datmp*dba)/total(datmp*dba)
print, cwl2
oplot,la,datmp*dba,col=4
print,cwl2-cwl1
print, 1000. / 3e8 * 658.


end
