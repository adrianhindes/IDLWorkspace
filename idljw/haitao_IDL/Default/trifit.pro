pro trifit,x,y,con1,con2,con3,con4,p1,p2,p3,p4
temp=findgen(40)
rh=findgen(20)*0.01
r=findgen(30)*0.05+1.5
v=-2000+findgen(40)*100  
d=trip(x,y)
pphase=d.pplus
lphase=d.plong
sphase=d.pshort
mphase=d.pmins
pdelay=d.ppha/2/!pi
pmc=tric(pdelay)
ldelay=d.lpha/2/!pi
lmc=tric(ldelay)
sdelay=d.spha/2/!pi
smc=tric(sdelay)
mdelay=d.mpha/2/!pi
mmc=tric(mdelay)
squc=make_array(40,30,20,/float)
squp=make_array(40,30,20,/float)
for i=0,39 do begin
  for j=0,29 do begin
    for l=0,19 do begin
      squc(i,j,l)=(con1-pmc(i,j,l))^2+(con2-lmc(i,j,l))^2+(con3-smc(i,j,l))^2+(con4-mmc(i,j,l))^2
      squp(i,j,l)=(p3-sphase(i,j,l))^2+(p4-mphase(i,j,l))^2+(p1-pphase(i,j,l))^2+(p2-lphase(i,j,l))^2
      endfor
      endfor
      endfor
 msqc=min(squc,index)
 ind=ARRAY_INDICES(squc, index)
 print, temp(ind(0)),r(ind(1)),rh(ind(2))
 dtp=reform(pphase(*,r(ind(1)),rh(ind(2))))
 dtl=reform(lphase(*,r(ind(1)),rh(ind(2))))
 dts=reform(sphase(*,r(ind(1)),rh(ind(2))))
 dtm=reform(mphase(*,r(ind(1)),rh(ind(2))))
;for k=0,39 do begin
  ;squp(k)=(p1-dtp(k))^2;+(p2-dtl(k))^2+(p3-dts(k))^2+(p4-dtm(k))^2
  ;endfor
 msqup=min(squp,index1)
 ;print, v(index1)
 ind1=ARRAY_INDICES(squp, index1)
 print, v(ind1(0)),r(ind(1)),rh(ind(2))








stop
end

