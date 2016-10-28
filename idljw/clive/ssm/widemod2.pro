;2015 dec: 89024 1st shot, pr+loc
;89025 : zero (all blocked)
;89026 : probe only
;89027 : local only

;Sweeping along a wide range of frequencies : 1kHz sawtooth, 3.75V offset, 7.5Vpp amplitude, no plasma.  Try to loo;k for cavities.
;81303 : probe arm only
;81304 : local arm only
;81302 : both arms
;81309 : all blocked

;; tilted 10-15 deg
;; 89036 probe only
;; 89037 both bad
;; normal incidence
;; 89038 both /ok
;; 89039 probe only

;; tilted 10-15 deg other way

;; 89040 probe only
;; 89041 both

;; qwp out
;; 89042 both
;; 89043 probe only   bad
;; 89044 repeat bad
;; 89045 repat good

;; probe blocked
;; 89046

;; both blocked (ie zero)
;; 89047 bad
;; 89048 



type='qwpinsidet'
;type='old'
;type='new'
if type eq 'new' then begin
   shboth=81302
   shprobe=81303
   shlocal=81304
   shdc=81309
   sub=intspace(620,1619-250)+658
   sub2=sub-190
   sub3=sub+160
   ich_phase=6
   ich_amp=7
endif

if type eq 'qwpinside' then begin
   shboth=89024
   shprobe=89026
   shlocal=89026
   shdc=89025
   sub=intspace(277,2276)
   sub2=intspace(1961,3960)
   sub3=sub2
   ich_phase=8
   ich_amp=8
endif

if type eq 'qwpinsidet' then begin
   shboth=89041
   shprobe=89040
   shlocal=89046
   shdc=89048
   sub=intspace(277,2276)
   sub2=intspace(1961,3960)
   sub3=sub2
   ich_phase=8
   ich_amp=8
endif

if type eq 'qwpinsiden' then begin
   shboth=89038
   shprobe=89039
   shlocal=89046
   shdc=89048
   sub=intspace(277,2276)
   sub2=intspace(1961,3960)
   sub3=sub2
   ich_phase=8
   ich_amp=8
endif


if type eq 'old' then begin
   shboth=81232
   shprobe=81230
   shlocal=81231
   shdc=81309
;   shdc=81057
   sub=intspace(620,1619)
   sub2=sub-80
   sub3=sub+250

   ich_phase=6
   ich_amp=5
endif


loadinterf,shboth,d,ref

if type eq 'old' or type eq 'new' then begin
   fs=1e6
endif else begin
   fs=2e6
endelse
nsub=1000e-6 * fs

dum=max(deriv(ref(0:nsub)),imax) & sub=indgen(nsub) + imax+1


loadinterf,shdc,dz,refdum
d=d-dz

n=n_elements(sub)
win=hanning(n)^(0.25)
dat=d(sub,ich_phase)
dat-=mean(dat)

plot,dat*win
plot,abs(fft(dat*win)),xr=[0,20]
s=fft(dat)
s(n/2:*)=0.
s(0:1)=0
da=fft(s,/inverse)
p=phs_jump(atan2(da))
amp=(abs(da))
freq=deriv(smooth(p,25))
plot,p
ix=intspace(50,n-50)
res=poly_fit(ix,p(ix),2,yfit=yfit)
yfit2=res(0)+res(1)*findgen(n)+res(2)*findgen(n)^2
oplot,ix,yfit,col=2
oplot,yfit2,col=3
stop
plot,amp
res2=poly_fit(ix,amp(ix),2,yfit=afit)
afit2=res2(0)+res2(1)*findgen(n)+res2(2)*findgen(n)^2
oplot,ix,afit,col=2
oplot,afit2,col=3
datt=dat-mean(dat)
stop
plot,yfit2,float(da)/afit2

stop

;win=hanning(n)^(1)

loadinterf,shlocal,d3,ref3

loadinterf,shprobe,d2,ref2


dum=max(deriv(ref2(0:nsub)),imax) & sub2=indgen(nsub) + imax+1

dum=max(deriv(ref3(0:nsub)),imax) & sub3=indgen(nsub) + imax+1




d2=d2-dz
d3=d3-dz

;sub3=sub-190;-80

n=n_elements(sub3)
;win=hanning(n)^(0.25)
dat=d3(sub3,ich_amp)
;dat-=mean(dat)

;goto,nn
plot,dat
amp=dat
ix=indgen(n)
res2=poly_fit(ix,amp(ix),2,yfit=afit)
afit2=res2(0)+res2(1)*findgen(n)+res2(2)*findgen(n)^2
oplot,ix,afit,col=2
afit2(*)=mean(afit2)
oplot,afit2,col=3
;stop
nn:





;loadinterf,81231,d3,ref
;sub3=sub+250


;win=hanning(n)^(1)
win(*)=1.

;stop
erase
mkfig,'~/ssw'+type+'.eps',xsize=28,ysize=18,font_size=7
pos=posarr(12,4,0,msratx=1e3,msraty=5)
for ich=0,20 do begin


dat=d(sub,ich)/afit2
;stop
dat-=mean(dat)
s=fft(dat*win)
s(n/2:*)=0.
s(0)=0
da=fft(s,/inverse)

da2=interpol(da,yfit2,linspace(min(yfit2),max(yfit2),n_elements(yfit2)))


 dat=d2(sub2,ich)/afit2
; stop
 dat-=mean(dat)
 s=fft(dat*win)
 s(n/2:*)=0.
 s(0)=0
 da=fft(s,/inverse)

 da2b=interpol(da,yfit2,linspace(min(yfit2),max(yfit2),n_elements(yfit2)))

;; dat=d3(sub3,ich)
;; dat-=mean(dat)
;; s=fft(dat*win)
;; s(n/2:*)=0.
;; s(0)=0
;; da=fft(s,/inverse)

;; da2c=interpol(da/afit2,yfit2,linspace(min(yfit2),max(yfit2),n_elements(yfit2)))
;pos=posarr(1,2,0)
plot,da2,title=ich,pos=pos,/noer
oplot,da2b,col=2
;oplot,da2c,col=3

;stop
win2=hanning(n_elements(da2));*0+1
s2=fft(da2*win2)
s2b=fft(da2b*win2)
;s2c=fft(da2c)

pos=posarr(/next)
plot,abs(s2),xr=[0,10],title=ich,pos=pos,/noer
oplot,abs(s2b),col=2
;oplot,abs(s2c),col=3
pos=posarr(/next)
;stop
;stop
endfor
endfig,/gs,/jp
end
