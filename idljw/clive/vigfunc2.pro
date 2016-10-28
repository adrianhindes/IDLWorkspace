function vigfunc2,th,f
tha=1.75
thb=5.
thb*=5.8/5.
tha*=6./5.*3.5/2.
rv=th*0
ia=where(abs(th) lt tha) & if ia(0) ne -1 then rv(ia)=1.
ib=where(abs(th) ge tha and abs(th) le thb) & if ib(0) ne -1 then rv(ib)=1 - (abs(th(ib)) - tha) / (thb-tha)
ic=where(abs(th) gt thb) & if ic(0) ne -1 then rv(ic)=0.
return,rv
end


