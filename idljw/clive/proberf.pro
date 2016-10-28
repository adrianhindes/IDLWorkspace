@~/idl/clive/fitlsig

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


;pro probe_rf
sh=83999
sh=84001
sh=83993;6;4;6;5;4
sh=85788

sh=85780
sh=85791
sh=85785
;sh=85760
;sh=85816
sh=85841
filterbw=0e3;0 ;0.2e3
tr=0.03+[-1e-3,1e-3]
mdsopen,'h1data',sh
cur=mdsvalue2('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_5',/nozero)
volt=mdsvalue2('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_1',/nozero)
vfloat=mdsvalue2('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_3',/nozero)

vpl=mdsvalue2('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_2',/nozero)

readpatchpr,sh,str


vfloat.v*=str.vflgain/str.ampgain3;250/5;

vpl.v*=str.vplgain/str.ampgain2;50/10

t_ball=(vpl.v-vfloat.v)/3.76


rf=mdsvalue2('200*(\h1data::top.rf:rf_drive/5)**2',/nozero)


vcur=cur.v
dvcurdt=deriv(cur.t,cur.v)
resc=str.iswrm;25.
capc= 25e-12
cur.v = vcur / resc + capc * dvcurdt
;stop

volt.v *= str.ampgain1;2 ; 100 gain and two on top

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


freq=float(str.swfreq)
;freq=6
;dt2=1/freq

;nbin=(max(cur2.t)-min(cur2.t))/dt2
volt20=volt2
if filterbw gt 0 then begin
   dum=volt2.v
   filtsig,dum,bw=filterbw,f0=freq,t=volt2.t & volt2.v=dum
   dum=cur2.v
   filtsig,dum,bw=filterbw,f0=freq,t=cur2.t & cur2.v=dum
endif


s=fft(volt2.v) & f=fft_t_to_f(volt2.t)
idx=where(f ge freq*0.8 and f le freq * 1.2)
s2=s*0 & s2(idx)=s(idx)
va=fft(s2,/inverse)
pa=phs_jump(atan2(va))/2/!pi

pb=1+findgen(floor(max(pa)*2-1))*0.5
ta=interpol(volt2.t,pa,pb)
rfa=interpol(rf.v,rf.t,ta)/max(rf.v)
iwant=where(ta ge tr(0) and ta le tr(1) );where(rfa gt 0.5)
ta=ta(iwant)

nt2=n_elements(ta)-1

para=fltarr(3,nt2)
spara=para
csa=fltarr(nt2)
sta=fltarr(nt2)
var=fltarr(nt2)
for i=0,nt2-1 do begin

   idx=where(cur.t ge ta(i) and cur.t le ta(i+1))
   v2=volt2.v(idx)-1*vfloat.v(idx) ;;;zeroing
   c2=cur2.v(idx)

   rng=minmax(vfloat.v(idx))
   var(i)=rng(1)-rng(0)
   if rng(1)-rng(0) gt 10 then begin
;      para(*,i)=!values.f_nan
;      continue
   endif

   tmp=min(abs(c2),imn)
   par=[max(c2),v2(imn),10.]
   par(2) = 5.
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
 if i mod 1 eq 0  and -2 eq -2 then begin
      plot,v2,c2,psym=4,title=string(i,ta(i),paro)
      oplot,v2,ft,col=2,psym=-5
;      stop
;      if  i gt 100 then stop

;      if i eq 2331 then stop
;      if i ge nt2*0.2 then stop
;      stop
;      wait,0.1
;      STOP
   endif
   if i mod 100 eq 0 then print,i,nt2

endfor
;cond=csa gt max(csa)*0.1 or
ts=para(2,*);<60>0;smooth(para2(2,*)<60>0,10)

   plot,ta,ts,yr=[-2,40]
   oplot,vfloat.t,t_ball,col=2,psym=3
end





