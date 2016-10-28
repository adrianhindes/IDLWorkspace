print,'hey'
e0=8.854d-12
echarge=1.6d-19
mi=1.67d-27*40

;B=0.05&ti=1.
;B=0.15&ti=0.2
;B=0.15&ti=1.5
;B=0.018&ti=0.1

B=0.3&ti=0.1

ni=1d18
loglam=20.
;0.2;5;30.
vti=sqrt(2*echarge*ti/mi)
nuii=ni*echarge^4 * loglam / 4 / !pi / e0^2 / mi^2 / vti^3

print,'for parameters mass=',mi/1.67d-27
print,'ion temperature =',ti,'ev'
print,'ion density = ',ni,'m-3'

print,'method 1 nuii=',nuii

nuii=1.4d-7 * ti^(-1.5) * (ni/1d6) * loglam * (mi/1.6d-27)^(-0.5)

print,'method 2 nuii=',nuii
ma=mi * 1000 ; g

fgyro_i = 1.52e3 * (1.6e-27/mi) * (B*10000.)
print,'fgyro_i=',fgyro_i

rgyro_i=vti / (2*!pi*fgyro_i)
print,'ion larmor radius=',rgyro_i,'m'

nuei = 3.2d-9 * ni/1e6 * loglam / ti^1.5 * (1.6d-27/mi)
print,'nuei=',nuei
sigma=100 * (1d-10)^2; foor hydrogen
sigma = 50 * (1d-9)^2
nunew = ni * sigma * vti
print,'nu neutral CX =',nunew

;nu_iz=ni*1e-14
;print,'nu ioniz=',nu_iz

;time=0.1 / vti
;rate=1/time
;print,'loss rate 0.1m',rate
me=9.8d-31
te=12.
vte = sqrt(2*echarge*te/me)
nuee=ni*echarge^4 * loglam / 4 / !pi / e0^2 / me^2 / vte^3
print,'nuee method 1=',nuee
mfpee=vte / nuee
print.'mean fre path for ee coll=',mfpee

fgyro_e = 2.8e6 * (B*10000.)
print,'fgyro_e=',fgyro_e


;kb=1.38e-23
;troom=300.;
;
;vroom=sqrt(2*kb*troom/mi)
;print,'vroom=',vroom

;print,'len_pen=vroom / nu_rate=',vroom / nunew
;










end
