pro getcoh,ch,res,res2

sh=85989
mdsopen,'h1data',sh
m=mdsvalue2('\H1DATA::TOP.MIRNOV.ACQ132_7:INPUT_01',/nozero);mirnov
y=mdsvalue2('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_4',/nozero);isat
y=mdsvalue2('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_3',/nozero);vpl



r1=read_datam(sh,ch,t0=t0,dt=dt) & t=findgen(n_elements(r1))*dt + t0
r2=read_datam(sh,21,t0=t0,dt=dt) 

res=read_datam(sh,ch,/anal) 


idx=where(t ge 0.03 and t lt 0.035)
r1=r1(idx)
r2=r2(idx)
res=res(idx)

t=t(idx)

rm=interpol(m.v,m.t,t)

t0=t(0)

nupshift=25 & fbase=80e3

dtd=1/(fbase*nupshift)

bw=fbase/4;1e3


dt  = dtd
;r1f = filtg(r1,fbase*dt,1e3*dt,/cplx)
r2f = filtg(r2,fbase*dt,1e3*dt,/cplx)


r2f=r2f/mean(abs(r2f))

r1s = r1 * conj(r2f);^2


;r1s = res


f=fft_t_to_f(t,/neg,isrt=isrt)

plot,f(isrt),(abs(fft(r1s)))(isrt),/ylog,xr=[-200e3,200e3]
oplot,f(isrt),(abs(fft(rm)))(isrt),col=2
nsm=50

s1s=smooth(abs(fft(r1s))^2,nsm)
s2s=smooth(abs(fft(rm))^2,nsm)
cs=smooth(fft(r1s) * conj(fft(rm)),nsm)

coh=abs(cs)/sqrt(s1s*s2s)

defcirc,/fill
plot,f(isrt),coh(isrt),col=3,/noer,xr=!x.crange,title=ch
fwant=12696.239
fwant=9e3
fwant=64043
iwant=value_locate(f(0:n_elements(f)/2),fwant)
print,f(iwant)
plots,f(iwant),coh(iwant),psym=8,col=3,symsize=5
res=coh(iwant)
res2=abs(cs(iwant))
wait,0.1
;stop

end

nch=20
res=findgen(nch)
res2=res

for i=0,nch-1 do begin
   getcoh,i,dum1,dum2
   res(i)=dum1
   res2(i)=dum2
endfor

end

