pro mten, sh, t_e, v_plas, rloc
;sh=312;50
;sh=412
;sh=450
 freq=30e3
;sh=451 & freq=17e3
isat=magpie_data('probe_isat',sh)
v1=magpie_data('probe_vfloat',sh)
v2=magpie_data('probe_vplus',sh)
i=isat.vvector
v=(v1.vvector-v2.vvector) / 5. * 333.
t=isat.tvector
;t=t(0:149999)
;i=i(0:149999)
;v=v(0:149999)

vplas=(v1.vvector+v2.vvector) / 5. * 333.

tw=.04+[0,5/30e3]
tw=.108+[0,5/30e3]
idx=where(t ge tw(0) and t le tw(1))
;plot,t(idx),v(idx)

vplas = vplas - mean(vplas(idx))
;plot,t(idx),i(idx),col=2,/noer

vc=v-mean(v)

vc=2*float(filtg(vc,freq/1e6, 3e3/1e6))
vh=float(hilbert(vc))
;plot,t(idx),vc(idx)
;oplot,t(idx),vh(idx),col=2
;plot,t(idx),i(idx),col=3,/noer

x=transpose([[vc(idx)],[vh(idx)]])
y=i(idx)
res=regress(x,y,yfit=yfit,const=const)

;oplot,t(idx),yfit,col=4

ioffset = res(0) * vc + res(1) * vh+const

;oplot,t(idx),ioffset(idx),col=5

i2=i-ioffset



tw=.04+[0,1000/30e3]
idx=where(t ge tw(0) and t le tw(1))

;plot,t(idx),v(idx),xr=tw(0)+[0,3/30e3],xsty=1
;plot,t(idx),i2(idx),col=2,/noer,xr=tw(0)+[0,3/30e3],xsty=1
;plot,t(idx),i(idx),col=3,/noer,xr=tw(0)+[0,3/30e3],xsty=1


;stop
ns=2
;te=10.
;isat=.05
;oplot, v(idx),isat * tanh(v(idx) / 2 / te),col=5
par=[.05,10]
xx=shift(v(idx),ns)
yy=i2(idx)

   ft=lmfit(xx,yy,par,chisq=cs,sigma=spar,function_name='dp_fit2',convergence=convergence,/double,fita=fita)

plot,v(idx),i2(idx),psym=4,col=2,title=string(sh,par(1))
oplot,xx,yy,psym=4,col=3
oplot,xx,ft,psym=4,col=5
print,'par=',par
t_e=par(1)
v_plas=mean(vplas(idx))
;stop


;oplot,v(idx),i(idx),psym=4,col=3

;tmp=i2(idx)
;tmpfit=tanh( vc(idx)/te)
;s=fft(tmp) & s/=max(abs(s))
;sfit=fft(tmpfit) & sfit/=max(abs(sfit))
;plot,abs(s),psym=4,xr=[0,1000]
;oplot,abs(sfit),col=2,psym=5
rloc=isat.location(0)
;stop
end


ns=41
sh=310+3*findgen(ns)
te=fltarr(ns)
vp=fltarr(ns)
rloc=fltarr(ns)

for i=0,ns-1 do begin
   mten, sh(i), te1, vp1, rloc1
   te(i)=te1
   vp(i)=vp1
   rloc(i)=rloc1
endfor


;print,t_e, rloc

end
