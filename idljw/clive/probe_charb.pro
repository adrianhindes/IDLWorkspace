pro probe_char2,sh,xr=xr,tavg=tavg
; for bpp
default,xr,[0,.05]

mdsopen,'h1data',sh
;cur=mdsvalue2('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_5',/nozero)
;volt=mdsvalue2('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_1',/nozero)
vfloat=mdsvalue2('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_3',/nozero)
vfloat.v*=250/5
vpl=mdsvalue2('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_2',/nozero)
vpl.v*=50/10

ts=(vpl.v-vfloat.v)/3.76
ta=vpl.t
idx=where(ta ge xr(0) and ta le xr(1))
tavg=mean(ts(idx))
oplot,ta,ts,col=2

end



pro exp_fit,v,fit_params,i
i = fit_params(0) * (1-exp( (v-fit_params(1))/fit_params(2)))
end

function exp_fit2,v,fit_params
i = fit_params(0) * (1-exp( (v-fit_params(1))/fit_params(2)))
pder1=(1-exp( (v-fit_params(1))/fit_params(2)))
pder2=exp( (v-fit_params(1))/fit_params(2))*fit_params(0)/fit_params(2)
pder3=exp( (v-fit_params(1))/fit_params(2))*fit_params(0)/fit_params(2)^2 * (v-fit_params(1))
rval=[[i],[pder1],[pder2],[pder3]]
return,rval

end

function exp_fit3,v,fit_params

i = fit_params(0) * (1-exp( (v-0)/fit_params(1)))
pder1=(1-exp( (v-0)/fit_params(1)))
;pder2=exp( (v-0)/fit_params(1))*fit_params(0)/fit_params(1)
pder3=exp( (v-0)/fit_params(1))*fit_params(0)/fit_params(1)^2 * (v-0)
rval=[[i],[pder1],[pder3]]
return,rval

end


pro probe_char,sh,xr=xr,cap=cap,cc1=cc1,ccap=capc,scap=caps,sres=ress,tavg=tavg
default,xr,[0,.05]

mdsopen,'h1data',sh
cur=mdsvalue2('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_5',/nozero)
volt=mdsvalue2('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_1',/nozero)
vfloat=mdsvalue2('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_3',/nozero)
vfloat.v*=250/5;33;50

;rf=mdsvalue2('\H1DATA::TOP.RF:P_RF_NET',/nozero)
rf=mdsvalue2('\H1DATA::TOP.RF:P_FWD_TOP',/nozero)

;cur.v /=25. ;  25 ohms, no gain
vcur=cur.v
dvcurdt=deriv(cur.t,cur.v)
resc=25.
capc= 25e-12
cur.v = vcur / resc + capc * dvcurdt
;stop

volt.v *= 5;2 ; 100 gain and two on top

cur2=cur

volt2=volt

dvdt=deriv(volt.t,volt.v)

rr1 = 10000.
rr2=1e6
default,cc1,30e-12
a_i1 = volt.v / rr1
a_i2 = cc1 * dvdt

volt2.v = volt.v + (a_i1 + a_i2) * rr2

;; volt2tmp=volt2

;; cvs=cur2.v - smooth(cur2.v,1000)

;; integ=total(cvs,/cum)*(cur2.t(1)-cur2.t(0))
;; ;default,caps,1e-6
;; vdrop1=1/caps * integ

;; fcvs=fft(cvs)
;; f=fft_t_to_f(cur2.t,/neg)
;; ;default,ress,1e12
;; impedance = ( (1/(complex(0,1) * 2*!pi* f * caps))^(-1) + ress^(-1) )^(-1)
;; fvdrop = impedance * fcvs
;; idx=where(abs(f) le 1e1)
;; fvdrop(idx)=0.
;; vdrop=float(fft(fvdrop,/inverse))

;; volt2.v = volt2tmp.v + vdrop

;stop

dvdt2=deriv(volt2.t,volt2.v)
default,cap,6.5e-10;1e-9
cur2 = cur & cur2.v=cur.v +dvdt2*cap - volt2.v / 1e6


freq=30e3

;dt2=1/freq

;nbin=(max(cur2.t)-min(cur2.t))/dt2
s=fft(volt2.v) & f=fft_t_to_f(volt2.t)
idx=where(f ge freq*0.8 and f le freq * 1.2)
s2=s*0 & s2(idx)=s(idx)
va=fft(s2,/inverse)
pa=phs_jump(atan2(va))/2/!pi

pb=1+findgen(floor(max(pa)*2-1))*0.5
ta=interpol(volt2.t,pa,pb)
rfa=interpol(rf.v,rf.t,ta)/max(rf.v)
iwant=where(rfa gt 0.5)
ta=ta(iwant)

nt2=n_elements(ta)-1

para=fltarr(3,nt2)
spara=para
csa=fltarr(nt2)
sta=fltarr(nt2)
var=fltarr(nt2)
for i=0,nt2-1 do begin

   idx=where(cur.t ge ta(i) and cur.t le ta(i+1))
   v2=volt2.v(idx)-vfloat.v(idx) ;;;zeroing
   c2=cur2.v(idx)

   rng=minmax(vfloat.v(idx))
   var(i)=rng(1)-rng(0)
   if rng(1)-rng(0) gt 10 then begin
;      para(*,i)=!values.f_nan
;      continue
   endif

   tmp=min(abs(c2),imn)
   par=[max(c2),v2(imn),10.]
 ;  par(1)=0 ;;;zeroing
   par0=par
   
;   ft=curvefit(v2,c2,c2*0+1,par,spar,function_name='exp_fit',/noder,chisq=cs,status=status)
   fita=[1,1,1]
;   fita=[1,0,1] ;;zeroing
   ft=lmfit(v2,c2,par,chisq=cs,sigma=spar,function_name='exp_fit2',convergence=convergence,/double,fita=fita)
   status=convergence ne 1 ; if 1 then cvg so status 0
;   par(1)=mean(vfloat.v(idx));zeroing
;   spar=spar/cs
   paro=par
   if status ne 0 then par(*)=0.
   para(*,i)=par
   spara=spar
   csa(i)=cs
   sta(i)=status
;   stop
;   if cs gt 1e9*0.008 then begin
 if i mod 100 eq 0 then begin
      plot,v2,c2,psym=4,title=string(i,ta(i),paro)
      oplot,v2,ft,col=2,psym=-5
;      if  i gt 1000 then stop

;      if i eq 2331 then stop
;      if i ge nt2*0.2 then stop
;      stop
;      wait,0.1
;      STOP
   endif
   if i mod 100 eq 0 then print,i,nt2

endfor
;cond=csa gt max(csa)*0.1 or 
cond=var gt 15.;*2
idx=where(cond)
nidx=where(cond eq 0)
nn=n_elements(idx)
para2=para
for i=0,nn-1 do begin
   j=idx(i)
   tmp=where(nidx lt j) & if tmp(0) ne -1 then k0=nidx(tmp(n_elements(tmp)-1)) else continue
   tmp=where(nidx gt j) & if tmp(0) ne -1 then k1=nidx(tmp(0)) else continue
   para2(*,j)=para(*,k0) * (j-k0) + para(*,k1) * (k1-j) / (k1-k0)
endfor

;plot,ta,para(1,*),yr=minmax(vfloat.v)
;oplot,ta,para2(1,*),col=2
;oplot,vfloat.t,vfloat.v,col=2
ts=smooth(para2(2,*)<60>0,10)
plot,ta,ts
oplot,ta,para2(2,*),psym=4,col=4
probe_char2,sh
idx=where(ta ge xr(0) and ta le xr(1))
tavg=mean(ts(idx))
 stop




;; ;cur2.v - cur2.v - res * 
;; ;mirn=mdsvalue2('\H1DATA::TOP.MIRNOV.ACQ132_7:INPUT_01',/nozero)
;; plot,cur.t,cur.v,pos=posarr(2,2,0),title='cur #'+string(sh,format='(I0)'),xsty=1,xr=xr,/yno
;; oplot,cur2.t,cur2.v,col=2
;; plot,rf.t,rf.v,/noer,pos=posarr(/next),xr=!x.crange,xsty=1,title='rf'


;; plot,volt.t,volt.v*100,/noer,pos=posarr(/next),title='volt',xr=!x.crange,xsty=1
;; ;oplot,volt2tmp.t,volt2tmp.v,col=2
;; oplot,volt2.t,volt2.v,col=2

;; idx=where(cur.t ge xr(0) and cur.t le xr(1))
;; v1=volt.v(idx)*100
;; v2=volt2.v(idx)
;; c1=cur.v(idx)
;; c2=cur2.v(idx)
;; plot,v1,c1,psym=4,pos=posarr(/next),/noer,xr=minmax([v1,v2])
;; oplot,v1,c2,psym=4,col=2
;; oplot,v2,c2,col=3,psym=4
;; oplot,!x.crange,[0,0]
;; ;stop



;stop
end




pro sw
;window,0
tab=[[46,1.3],$
     [49,1.24],$
     [50,1.33],$
     [53,1.25]]
sh=reform(81700+tab(0,*))
r=reform(tab(1,*))
idx=sort(r)
r=r(idx)
sh=sh(idx)
temp=fltarr(4)
temp2=temp
for i=0,3 do begin
   probe_char,sh(i),xr=[0.03,0.04]-0.01*1,tavg=tmp & temp(i)=tmp
   probe_char2,sh(i),xr=[0.03,0.04]-0.01*1,tavg=tmp & temp2(i)=tmp
endfor
plot,r,temp,psym=-4,yr=minmax([temp,temp2])
oplot,r,temp2,col=2,psym=-4

;window,1
;probe_char,81753,xr=.025+[0,1/30e3],scap=scap,sres=sres;,cap=20e-10,cc1=1e-12 
end


;probe_char,81847;836;81825;812;798
probe_char,sh;82074;82061;836;81825;812;798
;82074;82061;836;81825;812;798

end
