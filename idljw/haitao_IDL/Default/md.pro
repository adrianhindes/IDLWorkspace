pro md

fil1='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 05-02-2014\calibration 1 05-2-2014.SPE'
fil2='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 05-02-2014\calibration 2 05-2-2014.SPE'
fil3='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 05-02-2014\calibration 3 05-2-2014.SPE'
fil4='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 05-02-2014\calibration 4 05-2-2014.SPE'
fil5='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 05-02-2014\calibration 5 05-2-2014.SPE'
fil6='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 05-02-2014\calibration 6 05-2-2014.SPE'
fil7='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 05-02-2014\calibration 7 05-2-2014.SPE'
fil8='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 05-02-2014\calibration 8 05-2-2014.SPE'
fil9='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 05-02-2014\calibration 9 05-2-2014.SPE'
fil10='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 05-02-2014\calibration 10 05-2-2014.SPE'
fil11='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 05-02-2014\calibration 11 05-2-2014.SPE'
fil12='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 05-02-2014\calibration 12 05-2-2014.SPE'
fil13='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 05-02-2014\calibration 13 05-2-2014.SPE'
fil14='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 05-02-2014\calibration 14 05-2-2014.SPE'
fil15='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 05-02-2014\calibration 15 05-2-2014.SPE'
fil16='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 05-02-2014\calibration 16 05-2-2014.SPE'
fil17='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 05-02-2014\calibration 17 05-2-2014.SPE'
fil18='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 05-02-2014\calibration 18 05-2-2014.SPE'
fil19='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 05-02-2014\calibration 19 05-2-2014.SPE'
fil20='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 05-02-2014\calibration 20 05-2-2014.SPE'
file=[fil1, fil2,fil3,fil4,fil5,fil6,fil7,fil8,fil9,fil10,fil11,fil12,fil13,fil14,fil15,fil16,fil17,fil18,fil19,fil20]
data=make_array(512,512,20,/float)
for i=0,19 do begin
read_spe, file(i), lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
data(*,*,i)=d
endfor

sc=data(*,*,13)-data(*,*,14)
sc1=data(*,*,15)-data(*,*,16)
han=hanning(512,512)
sc=sc*han
sc1=sc1*han

scf=fft(sc, /center)
scf1=fft(sc1, /center)
stop
car=scf
d=scf
car(findgen(180),*)=0
car(200+findgen(312),*)=0
car(*, findgen(250))=0
car(*,findgen(242)+270)=0
d(findgen(245),*)=0
d(findgen(247)+265,*)=0
d(*,findgen(240))=0
d(*,findgen(252)+260)=0
car=fft(car, /inverse, /center)
dc=fft(d,/inverse, /center)
con=2.0*abs(car)/abs(dc)



car1=scf1
d1=scf1
car1(findgen(180),*)=0
car1(200+findgen(312),*)=0
car1(*, findgen(250))=0
car1(*,findgen(242)+270)=0
d1(findgen(245),*)=0
d1(findgen(247)+265,*)=0
d1(*,findgen(240))=0
d1(*,findgen(252)+260)=0
car1=fft(car1, /inverse, /center)
dc1=fft(d1,/inverse, /center)
con1=2.0*abs(car1)/abs(dc1)


phase=atan(car1/car,/phase)
stop
end