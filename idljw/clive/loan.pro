x=100000.

r=0.04

expense=(2000+1000+600)/52.
pay=430 - expense

nmax=1000.
t=findgen(nmax)
loan=fltarr(nmax)
inter=loan
for i=0,nmax-1 do begin
   loan(i) = x
   interest = x * r  /52.
   inter(i)=interest
   x = x + interest - pay
   if x lt 0 then break
endfor
t=t(0:i-1)
load=loan(0:i-1)
inter=inter(0:i-1)
tyr=t/52.
plot,tyr,inter,psym=-4



end
