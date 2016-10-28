path='~/spectrum/'
fil='Cu hollow cathode 3mA.spe'
read_spe,path+fil,l,t,d
;dd=total(d,2)
dd=d(*,512)
plot,l,dd,xr=[655,663],xsty=1

end
