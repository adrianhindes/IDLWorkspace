function filtsig,y, iharm0, iwid, nharm
s=fft(y*hanning(n_elements(y)))
n=n_elements(s)

filt=fltarr(n)
for i=0L,nharm-1 do begin
a=i*iharm0-iwid/2&b=i*iharm0+iwid/2
a=a>0<(n-1)
b=b>0<(n-1)
filt(a:b)=1
endfor
plot,abs(s),/ylog;,xr=n-1-reverse([0,1e4]),xsty=1
plot,filt,col=2,/noer;,xr=!x.crange,xsty=1
s2=s*filt
y2=fft(s2,/inverse)
y2=float(y2)*2

;stop
end




pro getdcac,d,dc,acpp
n=n_elements(d(0,*))
dc=fltarr(n)
acpp=fltarr(n)
for i=0,n-1 do begin
   dd=smooth(d(*,i),25,/edge_truncate)
   mx=max(dd)
   mn=min(dd)
   dc(i)=(mx+mn)/2
   acpp(i)=mx-mn
endfor

end



;sh=81059

;loadinterf, sh, d,ref

;Interferometer test shots
;81053 Before fiddling with something;;

;410mV, offset 3.6V, 5kHz
;81054 Normal
;81055 Probe arm blocked
;81056 Local blocked
;81057 Source switched off, to check the noise of the system
;81058 Normal
loadinterf,81057,d,ref & getdcac,d,doff,acnoise &dnone=d
;doff(*)=0.

loadinterf,81054,d,ref & getdcac,d,dc0,ac0 & dc0-=doff & dc0*=-1&dnet=d
loadinterf,81056,d,ref & getdcac,d,dcprobe,acprobe & dcprobe-=doff&dcprobe*=-1
loadinterf,81055,d,ref & getdcac,d,dclocal,aclocal & dclocal-=doff&dclocal*=-1

mkfig,'~/prloc.eps',xsize=18,ysize=7,font_size=8
plot,dc0,pos=posarr(2,1,0,cny=0.1),title='dc signals',xtitle='ch#'
oplot,dcprobe,col=2
oplot,dclocal,col=3
oplot,dcprobe+dclocal,col=4
legend,['mixed','probe','local','probe+local'],textcol=[1,2,3,4],/right,box=0
plot,ac0,pos=posarr(/next),/noer,title='ac signals [dashed line: noise level]',xtitle='ch#'
accalc=2*sqrt(dcprobe*dclocal)
oplot,accalc,col=4
oplot,acprobe,col=2
oplot,aclocal,col=3
oplot,acnoise,linesty=2
oplot,accalc+acprobe+aclocal,col=5
legend,['measured net pp','measured pp probe only','measured pp local only', 'calc net pp= 2*sqrt(I1*I2)','calc net sum'],textcol=[1,2,3,4,5],/right,box=0

;plot,ac0/(accalc+acprobe+aclocal),pos=posarr(/next),/noer,title='mixing efficiency'
endfig,/gs,/jp

;tmp=filtsig(dnone(*,10),383,30,30)
end
