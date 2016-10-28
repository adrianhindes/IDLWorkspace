pro tdcorr, sh, tw, frng, tlag,maxcc,dist=dist,velocity=velocity,doplot=doplot,lmax=lmax,corr=cor,method=method,wintype=wintype,mn=mn, tunetime=tunetime
default,dist, 0.1

dum=getpar(sh,'isat',y=isat,tw=[0,.01])
dum=getpar(sh,'isatfork',y=isatfork,tw=[0,.01])

if keyword_set(tunetime) then begin
;spectdata2,isat.v,ps,t,f,dt=5e-3,df=.2e3
;imgplot,alog10(ps),t,f,yr=[0,30e3]

fn=string('/home/cmichael/b',sh,'.sav',format='(A,I0,A)')
dum=file_search(fn,count=cnt) ;& cnt=0
if cnt eq 0 then begin
   plot,isat.t,isat.v,xr=[10e-3,30e-3] ;,xr=20e-3 + [-1,1]*1e-3
   cursor,dx,dy,/down
   t0=dx
   save,t0,file=fn,/verb
endif else begin
   restore,file=fn,/verb
endelse

;plot,isat.t,isat.v,xr=t0+[-1,1]*1e-3

tw=t0+[-1,1]*1e-3

endif

;stop
;bad-87868 87881
idx=where(isat.t ge tw(0) and isat.t lt tw(1))
t=isat.t(idx)
s1=isat.v(idx)
s2=isatfork.v(idx)

default,wintype,'hanning'
if wintype eq 'hanning' then win=hanning(n_elements(s1)) else win=replicate(1,n_elements(s1))

mn=mean(s2)
if frng(0) ne -1 then filtsig,s1,f0=(frng(0)+frng(1))/(2),bw=abs(frng(1)-frng(0)),t=t,nmax=1,ytype='hat',/nodc
if frng(0) ne -1 then filtsig,s2,f0=(frng(0)+frng(1))/(2),bw=abs(frng(1)-frng(0)),t=t,nmax=1,ytype='hat',/nodc
s2=float(s2)
s1=float(s1)

default,lmax,300
lag=intspace(-lmax,lmax)
cor=c_correlate(s1*win,s2*win,lag)

default,method,'std'
if method eq 'new' then begin
   ac0=c_correlate(s2*win,s2*win,0,/covariance)
   cor = cor * sqrt(ac0(0))
   cor=cor+mn
   plot,s2/max(s2),col=2,title=sh
   oplot,s1/max(s1)
   oplot,cor/max(cor),col=4,thick=2
   adum='' 
;& read,'',adum
   if adum eq 'n' then begin
      cor(*)=!values.f_nan
   endif
;   stop
endif

if keyword_set(doplot) then plot,lag,cor,psym=-4;,xr=[-50,50]
maxcc=max(cor,imax)

ilag=lag(imax)
tlag=ilag * 1e-6
velocity=dist/tlag
;stop
end
pro testtdcorr
sh=88533&tw=[.03,.04]&frng=[1e3,10e3];100e3]

;sh=86418&tw=[.02,.03]&frng=[1e3,200e3];100e3,200e3]

;sh=86418&tw=[.019,.021]&frng=[1e3,200e3];100e3,200e3]

;frng=[50e3,100e3]


tdcorr,sh,tw,frng,tlag,velocity=velocity,/doplot

print,tlag,velocity
end
