print,'hey'
e0=8.854d-12
echarge=1.6d-19
mi=1.67d-27
ni=1d18
loglam=20.
ti=30.
vti=sqrt(2*echarge*ti/mi)
nuii=ni*echarge^4 * loglam / 4 / !pi / e0^2 / mi^2 / vti^3
print,'method 1 nuii=',nuii

nuii=1.4d-7 * ti^(-1.5) * (ni/1d6) * loglam * (mi/1.6d-27)^(-0.5)

print,'method 2 nuii=',nuii
ma=mi * 1000 ; g
mb=mi * 12 * 1000 ; g
nue = 1.8d-19 * (ma*mb)^(0.5) * ni/1d6 * loglam / (ma * ti + mb * ti)^1.5
print,nue

nuei = 3.2d-9 * ni/1e6 * loglam / ti^1.5
print,'nuei=',nuei
sigma=100 * (1d-10)^2
nunew = ni * sigma * vti
print,'nu neutral =',nunew


time=0.1 / vti
rate=1/time
print,'loss rate 0.1m',rate
end
