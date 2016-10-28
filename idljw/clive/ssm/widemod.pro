
;Sweeping along a wide range of frequencies : 1kHz sawtooth, 3.75V offset, 7.5Vpp amplitude, no plasma.  Try to loo;k for cavities.
;81230 : probe arm only
;81231 : local arm only
;81232 : both arms
loadinterf,81232,d,ref
ich=14;6
sub=intspace(620,1619)
n=n_elements(sub)
win=hanning(n)^(0.25)
dat=d(sub,ich)
dat-=mean(dat)

plot,dat*win
plot,abs(fft(dat*win)),xr=[0,20],title=ich
s=fft(dat)
s(n/2:*)=0.
s(0:2)=0
da=fft(s,/inverse)
p=phs_jump(atan2(da))
amp=(abs(da))
freq=deriv(smooth(p,25))
plot,p
ix=intspace(100,900)
res=poly_fit(ix,p(ix),2,yfit=yfit)
yfit2=res(0)+res(1)*findgen(n)+res(2)*findgen(n)^2
oplot,ix,yfit,col=2
oplot,yfit2,col=3

plot,amp
res2=poly_fit(ix,amp(ix),2,yfit=afit)
afit2=res2(0)+res2(1)*findgen(n)+res2(2)*findgen(n)^2
oplot,ix,afit,col=2
oplot,afit2,col=3
datt=dat-mean(dat)
plot,yfit2,float(da)/afit2


win=hanning(n)^(1)


loadinterf,81230,d2,ref
sub2=sub-80

loadinterf,81231,d3,ref
sub3=sub+250

;stop
erase
mkfig,'~/ssw.eps',xsize=28,ysize=18,font_size=7
pos=posarr(12,4,0,msratx=1e3,msraty=5)
for ich=0,20 do begin


dat=d(sub,ich)
dat-=mean(dat)
s=fft(dat*win)
s(n/2:*)=0.
s(0)=0
da=fft(s,/inverse)

da2=interpol(da/afit2,yfit2,linspace(min(yfit2),max(yfit2),n_elements(yfit2)))


dat=d2(sub2,ich)
dat-=mean(dat)
s=fft(dat*win)
s(n/2:*)=0.
s(0)=0
da=fft(s,/inverse)

da2b=interpol(da/afit2,yfit2,linspace(min(yfit2),max(yfit2),n_elements(yfit2)))

dat=d3(sub3,ich)
dat-=mean(dat)
s=fft(dat*win)
s(n/2:*)=0.
s(0)=0
da=fft(s,/inverse)

da2c=interpol(da/afit2,yfit2,linspace(min(yfit2),max(yfit2),n_elements(yfit2)))

plot,da2,title=ich,pos=pos,/noer
oplot,da2b,col=2
oplot,da2c,col=3

;stop
s2=fft(da2)
s2b=fft(da2b)
s2c=fft(da2c)

pos=posarr(/next)
plot,abs(s2),xr=[0,20],title=ich,pos=pos,/noer
oplot,abs(s2b),col=2
oplot,abs(s2c),col=3
pos=posarr(/next)

;stop
endfor
endfig,/gs,/jp
end
