pro locateeps, epc, iharm,epsfinal,nsharm=nsharm
nh=n_elements(iharm)
eps=atan2(epc)
epa=abs(epc)
i1=(where(iharm eq 1))(0)
ins=(where(iharm eq nsharm))(0)
if epa(i1) lt epa(ins)*3 then rng=[-10,80]*!dtor else begin
    rng=eps(i1)+[-!pi/4,!pi/4]
;    modm = eps(i1) + !pi * intspace(-5,5)
;    idx=where((modm ge -!pi/2) and (modm lt !pi/2))
;    if modm(idx) gt 0 then rng=[0,!pi/2] else rng =[-!pi/2,0]
endelse


i2=(where(iharm eq 2))(0)
eps2t=eps(i2)/2. + !pi/2 * intspace(-5,5)
idx=where((eps2t ge rng(0)) and (eps2t le rng(1)))
epsfinal=(eps2t(idx))(0)
end

pro compeps, iharm, harm, eps,doplot=doplot
nh=n_elements(iharm)

if keyword_set(doplot) then !p.multi=[0,ceil(sqrt(nh)),ceil(sqrt(nh))]
for i=0,nh-1 do begin
    harm(*,i)=harm(*,i)*exp(-complex(0,1)*eps*iharm(i))
if keyword_set(doplot) then plot, float(harm(*,i)),imaginary(harm(*,i)),psym=3,xr=max(abs(harm(*,i)))*[-1,1],yr=max(abs(harm(*,i)))*[-1,1]

endfor
if keyword_set(doplot) then !p.multi=0
end







pro getharm, da, rf, ihw, harm, t1, t2, bw, epc
nh=n_elements(ihw)
nt2=n_elements(t2)
harm=complexarr(nt2,nh)
epc=complexarr(nh)
dt=t1(1)-t1(0)
for j=0,nh-1 do begin
    ha=da*conj(rf)^ihw(j)
    hb=filtg(ha,0,bw*dt)
    if ihw(j) mod 2 eq 1 then hb=hb * complex(0,-1)
    harm(*,j)=interpol(hb,t1,t2)
    sb=total(absc(hb))
;    epi(j)=atan2(sb)
;    epa(j)=abs(sb)
    epc(j)=sb
;    print, j, epa(j), epi(j)/j*!radeg + 180. / j * [-2,-1,0,1,2]
endfor

end


;goto,a

;xms_shot=-77 & xmp_shot=-111 & chw=15 ; with window, filterscope installed
;xms_shot=-75 & xmp_shot=-109 & chw=15 ; no window, filterscope installed
;xms_shot = -81 & xmp_shot=-115 &chw=5; set drive to 0.25 lambda
;xms_shot = -80 & xmp_shot=-114 &chw=5; set drive to 1 lambda

;xms_shot = -83 & xmp_shot=-117 &chw=5; pem2 off [23kHz one]; pem1=0.402 lam
;xms_shot = -84 & xmp_shot=-118 &chw=5; both pems off
xms_shot=-79 & xmp_shot=-113 &chw=5; window

;xms_shot=-60 & xmp_shot=-94 &chw=5;  no window

;xms_shot=1 & xmp_shot=1 &chw=5; test shot 1

skip=2
n=1000000/skip
dchan=string('xms_ch',chw,format='(A,I2.2)')
d=read_datac(xms_shot,dchan,dt=dtd,n=n,skip=skip,/sm)
r1=read_datac(xmp_shot,"xmp_ref20",dt=dtr1,n=n,skip=skip,/sm)
r2=read_datac(xmp_shot,"xmp_ref23",dt=dtr2,n=n,skip=skip,/sm)

;cz=read_datac(xmp_shot,'xmp_calib_zero',dt=dtcz,n=n,skip=skip)
;ci=read_datac(xmp_shot,'xmp_calib_index',dt=dtci,n=n,skip=skip)

a:
dt=dtd
r1f=filtg(r1,20e3*dt,1e3*dt,/cplx)
r2f=filtg(r2,23e3*dt,1e3*dt,/cplx)
;r2f=filtg(r2,0.001, 1.e3 * dt,/anal)
da=anals(d)

bw=1e3
t1=findgen(n)*dt
t2=linspace(0,max(t1),max(t1)*bw)
nt2=n_elements(t2)

f=findgen(n)/n /dt
r1f=r1f/max(abs(r1f))
r2f=r2f/max(abs(r2f))

ihw=[1,2,3,4,5,6,10]
window,0
getharm, da, r1f, ihw, harm1, t1, t2, bw, epc1
locateeps, epc1, ihw,eps1, nsharm=10
compeps, ihw, harm1, eps1;,/doplot

getp1,harm1(*,0),harm1(*,1),harm1(*,2),harm1(*,3),harm1(*,4),harm1(*,5),dum,p1,/noplot
;stop
window,1
getharm, da, r2f, ihw, harm2, t1, t2, bw, epc2
locateeps, epc2, ihw,eps2, nsharm=10
compeps, ihw, harm2, eps2;,/doplot
getp1,harm2(*,0),harm2(*,1),harm2(*,2),harm2(*,3),harm2(*,4),harm2(*,5),dum,p2,/noplot

ih0=[0]
getharm, d, r1f, ih0, harm0, t1, t2, bw, dum
;p1=2.5;5;2*!pi
;p2=2.66;2*!pi
s1 = harm2(*,1) / beselj(p2,2)
s2 = -harm1(*,1) / beselj(p1,2)
s3 = -harm1(*,0) / beselj(p1,1)
s0 =  (harm0(*,0) + s2*beselj(p1,0) - s1*beselj(p2,0))/sqrt(2)
stop



;    ep=median(atan2(h2f*complex(0,-1)))
;    h2f=h2f * exp(-complex(0,1)*ep)
;plot,imaginary(h2f)
;oplot,abs(float(h2f)),col=2
;endfor
;!p.multi=0
;stop
;plot,f,abs((fft(,0,1e3*dt)),xr=[0,100e3],/ylog
;plot,f,abs(fft(da)),xr=[0,100e3],/ylog
;oplot,f,abs(filtg(fft(r1f^2),0.,1e3*dt)),col=2

end
