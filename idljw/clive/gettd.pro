pro gettd, sh,td,rawsh=rawsh
lmax=10
look_pll6,sh,[0,2],win=3,ccs=ccs,lmax=lmax,lockavg=l1,filetype='new',gate=gate,rawsh=rawsh
;,f0=23e3,bw=3e3
x=intspace(-lmax,lmax)*2
dum=max(ccs,imax)
td=x(imax)
if max(gate) gt 1 then plot,x,ccs else print,'nono'

;stop

end

