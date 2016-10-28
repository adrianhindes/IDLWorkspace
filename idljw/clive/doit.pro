@~/idl/clive/probe_charnew
@~/idl/clive/readpatcharr


pro doit,sh,mode=mode,tr=tr,fmax=fmax,fmin=fmin,ref=ref,this=this,frng=frng,cc1=cc1,coh1=coh1,s1s=s1s,ff=f,dostop=dostop,just=just,mn=mn,st=st,val=val,xr=xr,only1=only1,nsm=nsm,xlog=xlog,tunetime=tunetime
default,ref,'bp'
default,this,''
default,mode,'isat'
tw=[0.03,0.04];+0.01*3
;sh=82204 & mode='vfloat
;sh=82228 & mode='vfloat'
default,tr,[0.03,0.04]
if ref eq 'bp' then dum=getpar(sh,mode,y=y1,tw=[0,1])
if ref eq 'otherfork' then dum=getpar(sh,mode+'otherfork',y=y1,tw=[0,1])


if keyword_set(tunetime) then begin
;spectdata2,isat.v,ps,t,f,dt=5e-3,df=.2e3
;imgplot,alog10(ps),t,f,yr=[0,30e3]

fn=string('/home/cmichael/',sh,'.sav',format='(A,I0,A)')
dum=file_search(fn,count=cnt)
if cnt eq 0 then begin
   isat=y1
   plot,isat.t,isat.v,xr=[10e-3,30e-3] ;,xr=20e-3 + [-1,1]*1e-3
   cursor,dx,dy,/down
   t0=dx
   save,t0,file=fn,/verb
endif else begin
   restore,file=fn,/verb


endelse

;plot,isat.t,isat.v,xr=t0+[-1,1]*1e-3

tr=t0+[-1,1]*1e-3

endif



ix=where(y1.t ge tr(0) and y1.t le tr(1))
default,nsm,10;50

st=stdev(y1.v(ix))
mn=mean(y1.v(ix))
val=y1.v(ix)
nn=n_elements(ix)
win=hanning(nn)
if keyword_set(only1) then return

if this eq 'other' then dum=getpar(sh,mode+'otherfork',y=y2,tw=[0,1]) else dum=getpar(sh,mode+'fork',y=y2,tw=[0,1])

s1=fft(y1.v(ix)*win,/double)
s2=fft(y2.v(ix)*win,/double)
cc=s1 * conj(s2)
ccs=smooth(cc,nsm)
s1s=smooth(abs(s1)^2,nsm)
s2s=smooth(abs(s2)^2,nsm)



f=fft_t_to_f(y1.t(ix))

if n_elements(frng) ne 0 then begin
   iw1=value_locate(f,frng)
   cc1=total(cc(iw1(0):iw1(1)))
   s1s1=total(abs(s1(iw1(0):iw1(1)))^2)
   s2s1=total(abs(s2(iw1(0):iw1(1)))^2)
   coh1=(cc1)/sqrt(s1s1*s2s1)


   isat=y1
   plot,y1.t,y1.v,xr=tr,title=string(abs(coh1),atan2(coh1)*!radeg)

   oplot,y2.t,y2.v,col=2
;   adum='' & read,'',adum

   return
endif
if keyword_set(just) then return

default,xr,[0,500e3]
;mkfig,'~/pcohd3b.eps',xsize=12,ysize=12,font_size=8
plot,f,alog10(s1s),pos=posarr(2,2,0),xr=xr,title=string(sh,mode),yr=minmax(alog10([s1s,s2s])),xlog=xlog

;plot,alog10(f),alog10(s1s),pos=posarr(2,2,0),title=string(sh,mode),yr=minmax(alog10([s1s,s2s]))

;cursor,dx,dy,/down
;cursor,dx2,dy2,/down
;oplot,[dx,dx2],[dy,dy2],col=2

;slope=(dy2-dy)/(dx2-dx)
;print,'slope=',slope
;stop
;plot,f,alog10(s1s),xr=xr,title=string(sh,mode),xtitle='Freq (Hz)',ytitle='Log 10 power',yr=[-14,-8]
;oplot,alog10f,alog10(f^(-2) * 1d3),col=2
oplot,f,alog10(s2s),col=2


legend,['ball','fork'],textcol=[1,2],/right
;endfig,/gs,/jp
;stop
if keyword_set(dostop) then stop
;return
coh=abs(ccs)/sqrt(s1s*s2s)
pcoh=atan2(ccs)
plot,f,coh,yr=[0,1],col=3,/noer,pos=posarr(/next),xr=xr,xlog=xlog
plot,f,pcoh,col=4,/noer,pos=posarr(/next),xr=xr,xlog=xlog
pjcoh=phs_jump(pcoh)
ii=value_locate(f,50e3)
pjcoh=pjcoh-pjcoh(ii)
plot,f,pjcoh,col=4,/noer,pos=posarr(/next),yr=[-2*!pi,2*!pi]*2,xr=xr,xlog=xlog
default,fmax,3e5
default,fmin,0
par=linfit(f,pjcoh,measure_errors=1/(.001+(f ge fmin and f le fmax)),yfit=yfit)
oplot,f,yfit,col=2
print,'slope is',par(1)
endfig,/gs,/jp

;stop
end
