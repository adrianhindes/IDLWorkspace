pro isit,sh,flip,pz
mdsopen,'mse_2014',sh
flip=mdsvalue('.DAQ:FLIPPER',status=status)
pz=mdsvalue('.DAQ:PZ_POSITION',status=status2)
end

;pro loop
sh=intspace(10100,10356)
sh=reverse(sh)
nsh=n_elements(sh)
flip=strarr(nsh)
pz=fltarr(nsh)
for i=0,nsh-1 do begin
    isit,sh(i),d1,d2 & flip(i)=d1 & pz(i)=d2
print,sh(i)
    endfor
    end
