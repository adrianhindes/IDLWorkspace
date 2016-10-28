Pro nebula_kexthomson,shot,t_e,n_e,rpsi,zpsi,tpsi,psi,qprof,qtime,qrad

g=readg(getenv('HOME')+'/idl/g007485.002500')    
print,'done 74852500'
;g=readg(getenv('HOME')+'/idl/g005594.02150')    
;g=readg(getenv('HOME')+'/g005955.02000')    

;g=myreadg(7427,3000)
rpsi=g.r
zpsi=g.z
psi1=(g.psirz-g.ssimag)/(g.ssibry-g.ssimag)

tpsi=[-1,10.]
nt=2
sz=size(psi1,/dim)

; density profile postulate::
nrho=100
rho=linspace(0,1,nrho)
psirho=rho^2
neprof=(1+(1-rho)*0.2)*1e19
neprof(nrho-1)=0.
teprof=1000* (1-rho) & teprof(*)=1000.

teprof(nrho-1)=0.

psi=fltarr(sz(0),sz(1),nt)
t_e=fltarr(sz(0),sz(1),nt)
n_e=fltarr(sz(0),sz(1),nt)

for i=0,nt-1 do psi(*,*,i)=psi1

n_e=interpol(neprof,psirho,psi<1)>1e9
t_e=interpol(teprof,psirho,psi<1)>1.
; no q data
;stop
end
