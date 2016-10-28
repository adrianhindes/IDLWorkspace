function zoneinte,znn
;0 order spline fucntion, modeling of zone integration
;zn=20
zonedata=make_array(85,5,znn,/dcomplex)
for i=0,znn-1 do begin
zn=i+1
save, zn, filename='zone number.save'
zonedata(*,*,i)=zoneint(1.0,0.0,0.0)
endfor
;save,zonedata, filename='zone integration proifle for 20 zones.save' ; sample points along line is 1000
;save,zonedata, filename='zone integration proifle for 20 zones1.save' ; sample points along line is 5000
;save,zonedata, filename='zone integration proifle for 20 zones2.save' ; sample points along line is 10000
;save,zonedata, filename='zone integration proifle for 20 zones3.save' ; sample points along line is 20000
;save,zonedata, filename='zone integration proifle for 20 zones4.save' ; sample points along line is 50000

;save,zonedata, filename='zone integration proifle for 30 zones.save' ; sample points along line is 1000
;save,zonedata, filename='zone integration proifle for 30 zones1.save' ; sample points along line is 5000
;save,zonedata, filename='zone integration proifle for 30 zones2.save' ; sample points along line is 10000
;save,zonedata, filename='zone integration proifle for 30 zones3.save' ; sample points along line is 20000
;save,zonedata, filename='zone integration proifle for 30 zones4.save' ; sample points along line is 50000

;save,zonedata, filename='zone integration proifle for 40 zones4.save' ; sample points along line is 50000
;save,zonedata, filename='zone integration proifle for 10 zones4.save' ; sample points along line is 50000
return, zonedata
stop


;1 order spline fucntion
kn=11 ;number of knots
bafucp=make_array(85,85,kn-2,/dcomplex)
for i=0,kn-3 do begin
  bn=i
save, bn, filename='the number of first spline basic function.save'
 bafucp(*,*,i)=zoneint(1.0,0.0,0.0)
 endfor
 save,bafucp, filename='basis fuction integration proifle for 11 knots.save'
stop





stop
end
