path='~/carbon lines/'
;fil='2013 August 08 13_25_58.spe'
;fil='2013 August 08 13_28_41.spe'
fil='2013 August 08 13_29_21.spe'
read_spe,path+fil,l,t,d
d0=d
;help,l,t,d
d=float(d)
ff=1.1
l=l*ff + 656*(1-ff) - 0.6
da=(d(*,*,5)-d(*,*,9))/max(d(*,*,5))
la=l
plot,la,da,/ylog,yr=[1e-4,1]

path='~/spectrum/'
;fil='2013 August 08 13_25_58.spe'
;fil='2013 August 08 13_28_41.spe'
fil='658 filter.spe'
read_spe,path+fil,l,t,d
help,l,t,d
lb=l
db=d/max(d)
dba=interpol(db,lb,la)
oplot,la,dba,col=2

d3=[$
[656.1,  0.0129353 ],$
[657.805,0.649874 ],$
[658.288,0.337191] ]

for i=0,2 do oplot,d3(0,i)*[1,1],10^!y.crange

;scalld,ltmp,dtmp,l0=658,fwhm=1,opt='a3'
scalld,ltmp,dtmp,l0=658,fwhm=2,opt='a3'
oplot,ltmp,dtmp,col=4

filtstr={nref:2.05,cwl:658}
thetax = 4e-3/55e-3 & thetay=0
thetao=sqrt(thetax^2+thetay^2)
dlol=1-sqrt(filtstr.nref^2-sin(thetao)^2)/filtstr.nref
tshifted=filtstr.cwl*dlol       ;lam0c=lam0*(1-dlol)

oplot,la-tshifted,dba,col=2,linesty=2

oplot,ltmp-tshifted,dtmp,col=4,linesty=2


stop

scalld,ltmp,dtmp,l0=658,fwhm=2,opt='a3' &dtmp/=max(dtmp)
plot,ltmp-658,dtmp,/ylog,xr=[0,3]
oplot,la-658,dba/max(dba),col=3
print,'ah'
stop

oplot,la+0.02 * 10,dba,col=2,linesty=1
oplot,la+0.02 * 20,dba,col=2,linesty=2

oplot,la+0.02 * 40,dba,col=2,linesty=3


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
retall
cum=total(da*dba,/cum)
cum/=max(cum)
plot,la,cum
cursor,dx,dy,/down
cum1=cum(value_locate(la,dx))

cursor,dx,dy,/down
cum2=cum(value_locate(la,dx))
print, cum1, cum2-cum1,1-cum2

;  0.0129353     0.649874     0.337191


end
