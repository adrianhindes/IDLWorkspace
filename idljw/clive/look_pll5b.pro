pro look_pll5,sh,twin,fr=fr,ylog=ylog,img=img,win=win,f0=f0,bw=bw,iframe=iframe,ccs=ccs,lmax=lmax,doiframe=doiframe,lockavg=lockavg,dolen=dolen
default,lmax,200
nlags=intspace(-lmax,lmax)
 

default,fr,[1,100]
;dir='D:\MDSPLUS_DATA\PLL2_DATA\'
dir='~/pll2/'
restore,file=dir+'pll'+string(sh,format='(I0)')+'.sav',/verb;mdsopen,'pll',sh

t=data(0,*)
dc=data(1,*)
sq=data(2,*)
gate=data(3,*)
osc=data(4,*)

camera_mon=gate

if n_elements(twin) eq 0 then twin=[0,1.]


if keyword_set(doiframe) then begin


ix1=[0,where(gate gt 1.5)]
dix1=ix1(1:*)-ix1(0:n_elements(ix1)-2)
nthr=0.05*1e6
ix2=where(dix1 gt nthr)
if ix2(0) eq -1 then ix2=[0,n_elements(dix1)-1]
iswitchon=ix1(ix2+1)
iswitchoff=ix1(ix2(1:*))

   ia=iswitchon(iframe)
   ib=iswitchoff(iframe)
   nba=ib-ia+1
   nicenumberinit,n7=1,n5=1
;   nba=(nba/1)*1000
   nba2=nicenumber2(nba,/floor,/show)
   print,nba,nba2
   nba=nba2
   ib2=ia+nba-1
   twin=[t(ia),t(ib2)]
   if keyword_set(dolen) then twin=twin(0)+[0,dolen]
   twin=twin
   print,twin
   print,iframe
;   stop
endif


deltat=t(2)-t(1)
idx=where(t ge twin(0) and t lt twin(1))
if n_elements(nba) ne 0 then idx=idx(0)+lindgen(nba)

camera_mon=camera_mon(idx)
t=t(idx)

;pll-===
n=n_elements(gate)
dgate=gate(1:n-1)-gate(0:n-2)
dgate=[0,dgate]
plla=dgate gt 0.5
pllb=dgate lt -0.2 and gate lt 0

pll=pllb

pll=gate gt 2.5

pll=pll(idx)
gate=gate(idx)
dgate=dgate(idx)
pll0=pll
dpll=pll
pll=pll-mean(pll)
acpll=a_correlate(pll, nlags)


;lock_singal=...
locksignal=osc
locksignal=locksignal(idx)
locksignal2=locksignal

;'/home/cam112/pll2
read_spe,dir+'test'+string(sh,format='(I0)')+'.SPE',l,tt,img


; plot,fft_t_to_f(t),abs(fft(locksignal)),/ylog,xr=[1e3,100e3]
if keyword_set(bw) then filtsig,locksignal2,bw=bw,f0=f0,t=t,nmax=1,/nodc


;oplot,fft_t_to_f(t),abs(fft(locksignal2)),col=2
locksignal=float(locksignal2)
;stop


locksignal0=locksignal
locksignal=locksignal-mean(locksignal)
hlocksignal=float(hilbert(locksignal))

lphs=atan(hlocksignal,locksignal)
aclocksignal=a_correlate(locksignal, nlags)

;cross correlation
ccs=c_correlate(locksignal,pll,nlags)

nt=n_elements(t)
;dpll=pll(1:*)-pll(0:nt-2)
;dpll=pll
ipulse = where(dpll eq 1)

lphs2=lphs(ipulse)*!radeg

default,win,1

lockavg=total(pll0*locksignal0)



if win eq 1 then begin
wset2,0
!p.multi=[0,1,5]
plot, t,locksignal, title='Lock signal'
oplot,t,hlocksignal,col=2
plot,t,lphs*!radeg,title='lock phase';,psym=3
plot, t,pll, title='PLL signal',/noer
plot,t,gate,col=2,xr=!x.crange;,/noer
plot,t(ipulse),lphs2,psym=10
oplot,t(ipulse),lphs2,psym=4
;plot,lphs2(sort(lphs2)),psym=4
nbin=32
hg=histogram(lphs2,min=-180,max=180,nbins=nbin)
hgxe=linspace(-180,180,nbin+1) 
hgx=(hgxe(1:nbin)+hgxe(0:nbin-2))/2.
plot,hgx,hg

!p.multi=0

stop
endif
if win eq 2 then begin
wset2,1
!p.multi=[0,2,3]
plot, nlags,aclocksignal, title='Auto correlation of lock signal'
plot, nlags,acpll, title='Auto correlation of PLL signal'
plot, t,camera_mon,title='camera monitor signal'
plot, nlags,ccs, title='Cross correlation of pll and lock signals'

power=abs(fft(locksignal))^2
powerpll=abs(fft(pll))^2
pn=n_elements(locksignal)
freq=findgen(pn/2.0)/(pn*deltat)

plot, freq/1000.0, power(0:n_elements(freq)-1), title='Power spectrum of lock signal',xtitle='Freq/kHz',ytitle='Power',xrange=fr,/ylog
oplot, freq/1000.0, powerpll(0:n_elements(freq)-1),thick=2
;plot,totaldim(img(*,*,1:*),[1,1,0]),/yno
!p.multi=0
stop
endif

;stop
end

pro loop;
;75 500,76 600, 78 400
larr=fltarr(9)
sh=intspace(32,40)
for i=0,8 do begin
lmax=25
look_pll5,sh(i),win=3,iframe=0,ccs=ccs,lmax=lmax,doiframe=1,lockavg=l1;,f0=23e3,bw=3e3
larr(i)=l1
x=intspace(-lmax,lmax)
if i eq 0 then plot,x,ccs,yr=[-.1,.1]*8,pos=posarr(2,1,0) else oplot,x,ccs,col=i+1
endfor
plot,larr,pos=posarr(/next),/noer
end


;look_pll4,22,[0,.1],win=2,iframe=1,/doiframe
;end
 
