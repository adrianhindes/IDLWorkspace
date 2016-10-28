pro getharm2, da, rf1, rf2, ihw1, ihw2, harm, t1, t2, bw, epc,cal=cal,nohat=nohat,sideopt=sideopt
default,sideopt,replicate(0,n_elements(ihw1))
hat= not keyword_set(nohat)
nh=n_elements(ihw1)
nt2=n_elements(t2)
harm=complexarr(nt2,nh)
epc=complexarr(nh)
dt=t1(1)-t1(0)
for j=0,nh-1 do begin
    ha=da*conj(rf1)^ihw1(j) * conj(rf2)^ihw2(j)
    hb=filtg(ha,0,(2*bw)*dt,hat=hat,sideopt=sideopt(j)) ; 2 to convert 1/2 wid to full wid for hat
;    hb=smooth(ha,1/ bw/dt)
    harm(*,j)=interpol(hb,t1,t2)
    
    if keyword_set(cal) then sb=total(absc(hb)) else sb=total(hb)
    epc(j)=sb
;    if j eq 2 then begin
;    endif
print,j,nh
endfor

end

