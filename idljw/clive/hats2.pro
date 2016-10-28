function hats2, th0, thw, ang,set=set,doplot=doplot
if set.type eq 'hat' then rval1= ang gt th0-thw/2 and ang lt th0+thw/2
; exclusion filterrs
a=0.1086+.003
b=0.1778+.003
c=0.0686
w1=0.01
w2=0.01
w3=0.01

excl1 = abs(ang-th0 - a) le w1
excl1b= abs(ang-th0 + a) le w1

excl2 = abs(ang-th0 - b) le w2
excl2b= abs(ang-th0 + b) le w2

excl3 = abs(ang-th0 - c) le w3
excl3b= abs(ang-th0 + c) le w3

excl = not( excl1 or excl1b or excl2 or excl2b or excl3 or excl3b)

rval2=rval1 and excl



if keyword_set(doplot) then begin
    plot,ang,rval2
    stop
endif
return,rval2
end
