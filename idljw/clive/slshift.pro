@filt_common

x0=658.3
x=linspace(-3,3,300)*0.04 + x0
temp=20.
vth_ms=sqrt(2*1.6e-19*temp/12/1.67e-27)
vth = vth_ms / 3e8 * 660.
y=exp(-((x-x0)^2 / vth^2))

scalld,x1,f1,l0=filt_cent,fwhm=2,opt='a3'
f=interpol(f1,x1,x)


plot,x1,f1,pos=posarr(1,2,0);,/ylog
oplot,x,f,col=2

plot,x,y,pos=posarr(/next),/noer
oplot,x,f,col=2
yf=y*f
yf/=max(yf)
oplot,x,yf,col=3
c0=total(y*x)/total(y)
print,'no effect c0=',c0
c1=total(yf*x)/total(yf)
print,'shift effect c1=',c1
dc=c1-c0
print,'diff=',dc
vel=dc / vth
print,'diff as fraction of mach # is',vel

veltrue=vth_ms * vel
print,'shift in vel is',veltrue,'m/s'

print,'shift in vel direcly is in m/s',dc /660. * 3e8
end
