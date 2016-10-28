dir='/home/cmichael/share/greg/'
fil='abscal  4.spe'
read_spe,dir+fil,l,t,d & d=d*1. & d0=total(d,3)/ 5. ; 5 frames so take avg

; this is for 0.5 sec integration time. with 1x gain

integ_time = 0.5

fil='abscal  1.spe'
read_spe,dir+fil,l,t,d & d=d*1. & d1=total(d,3)
spawn,'mv ~/footer.xml ~/footer_abscal.xml'
dcal=d1-d0
fil='clive_register_  4.spe'


read_spe,dir+fil,l,t,d & dr=d*1.
imgplot,dr,/cb
;write_png,'~/idl/clive/nleonw/aview/cr4.png',d
;write_png,'~/cr4.png',d
;stop

dir='/home/cmichael/share/greg/';dir='/home/cam112/share/greg/'
;fil='656_halpha_measurement_white_exponefifth.spe'
;fil='656_halpha_measurement.spe'
;fil='2014 September 02 11_41_49.spe'
;fil='2014 September 02 11_42_19.spe'
fil='2014 September 02 11_49_31.spe'
read_spe,dir+fil,l,t,d & d*=1.
ich=10 
it=100 & it0=0
db=d(*,ich,it) * 5. - d(*,ich,it0) * 5.

fil='656_halpha_measurement.spe'
read_spe,dir+fil,l,t,d & d*=1.
l=reverse(l)
ich=10
it=49 & it0=0
dd=d(*,ich,it)*1. - d(*,ich,it0)*1.

db=smooth(db,3*20)
dd=smooth(dd,3*20)

s=myrest2('~/ipad_radiance.sav')
s.rad=smooth(s.rad, 10)
;restore,file='~/ipad_radiance.sav',/verb;save,l,rad

fresp=dd/db


;plot,l,db
;oplot,l,dd,col=2
plot,l,fresp,yr=[0,1]
emissiv=interpol(s.rad,s.l,l)
plot,l,emissiv
emissiv2=emissiv*fresp
oplot,l,emissiv2,col=2
deel=abs(l(1)-l(0))

radinteg=total(emissiv2) * deel * integ_time
print,'radinteg=',radinteg,'ph/m^2/str'

radpercount = radinteg / dcal
;imgplot,radpercount/1e10,zr=[0,5],/cb

sz=size(radpercount,/dim) & nx=sz(0) & ny=sz(1)
print, 'radpercount in centre = ',radpercount(nx/2,ny/2),'ph/cnt /m^2 / str'

;plot,
;plot,totaldim(d,[1,1,0])

print,'estimate is ' ,1 / (12e-6^2 * !pi * 0.25^2 ) * 2.5 ;40% qe 1e conv gain


dir='/home/cmichael/share/greg/';/data/kstar/halpha/'
fil='shaun_84081.spe'
;fil='shaun_83982.spe'
read_spe,dir+fil,l,t,d,str=str & d=d*1. ; 5ms exposure time gain 1

integ_time = 0.005
d = d * radpercount ; ph/m^2 / str
d = d / integ_time ; ph/s/m^2/str
;assume path length of 1m -> emissiv is about 1e17 ph/s/m^3/str
;time 4pi -> 1e18 ph/s/m^3

;sxb order of 10 -> 1e19 /s/m^3
; flux is 0.5 * r * S
; which for r=0.1 makes 1e18 /s /m^2
;above 10eV sxbdoesn't changemuch from 10



imgplot,d/1e17,zr=[0,3],/cb

save,d,file='~/hcal.sav',/verb


end

