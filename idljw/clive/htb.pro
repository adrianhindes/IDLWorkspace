path='~/carbon lines/'
;fil='2013 August 08 13_25_58.spe'
fil='2013 August 08 13_28_41.spe'
;fil='2013 August 08 13_29_21.spe'
read_spe,path+fil,l,t,d
d0=d
;help,l,t,d
d=float(d)

l-=0.6
da=(d(*,*,5)-d(*,*,9))/max(d(*,*,5))
la=l
plot,la,da

path='~/spectrum/'
;fil='2013 August 08 13_25_58.spe'
;fil='2013 August 08 13_28_41.spe'
fil='514 filter.spe'
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
datmp=da & ;idx=where(la ge 655.5 and la le 656.5) & datmp(idx)*=1.1
cwl2=total(la*datmp*dba)/total(datmp*dba)
print, cwl2
oplot,la,datmp*dba,col=4
print,cwl2-cwl1
print, 1000. / 3e8 * 658.


end
