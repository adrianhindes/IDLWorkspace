pro trifitiv, x,y, t, v, r,rh

temp=findgen(40)
rhr=findgen(20)*0.01
rr=findgen(30)*0.05+1.5
vr=-2000+findgen(40)*100

d1=min((temp-t)^2, indext)
d2=min((v-vr)^2, indexv)
d3=min((r-rr)^2, indexr)
d4=min((rh-rhr)^2, indexrh)

d=trip(x,y)
pdelay=d.ppha/2/!pi
pmc=tric(pdelay)
pcon=pmc(indext,indexr,indexrh)
ldelay=d.lpha/2/!pi
lmc=tric(ldelay)
lcon=lmc(indext,indexr,indexrh)
sdelay=d.spha/2/!pi
smc=tric(sdelay)
scon=smc(indext,indexr,indexrh)
mdelay=d.mpha/2/!pi
mmc=tric(mdelay)
mcon=mmc(indext,indexr,indexrh)
con=[pcon,lcon,scon,mcon]

pphase=d.pplus
lphase=d.plong
sphase=d.pshort
mphase=d.pmins
phase=[pphase(indexv,indexr,indexrh),lphase(indexv,indexr,indexrh),sphase(indexv,indexr,indexrh),mphase(indexv,indexr,indexrh)]
print, con
print, phase

stop
end

