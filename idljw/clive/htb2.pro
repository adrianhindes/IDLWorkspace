pth0='~/spectrum/'
filarr=file_search(pth0,'*.spe',count=cnt)
;print,fil


for ii=0,cnt-1 do begin





;path='~/spectrum/'
;fil='Cu hollow cathode 3mA.spe'

read_spe,filarr(ii),l,t,d
help,l,t,d


d0=d

d=float(d)

if size(d,/n_dim) eq 1 then continue
da=(total(d(*,400:450),2))
da/=max(da)
la=l
;

path='~/spectrum/'
;fil='2013 August 08 13_25_58.spe'
;fil='2013 August 08 13_28_41.spe'
fil='658 filter.spe'
read_spe,path+fil,l,t,d
help,l,t,d
lb=l
db=d/max(d)

da=interpol(da,la,lb) & la=lb
plot,la,da,title=filarr(ii)
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

cursor,dx,dy,/down
endfor

end
