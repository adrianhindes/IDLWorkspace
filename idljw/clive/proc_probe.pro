pro proc_probe,sh,cap=cap,cc1=cc1,ccap=capc,scap=caps,sres=ress,tavg=tavg,varthres=varthres,filterbw=filterbw,qty=qty,recalc=recalc,doplot=doplot,qavg=qavg,qst=qst,yval=y,rfoff=rfoff,dostop=dostop

;pro probe_charnew,sh,xr=xr,cap=cap,cc1=cc1,ccap=capc,scap=caps,sres=ress,tavg=tavg,varthres=varthres,filterbw=filterbw,qty=qty,recalc=recalc,doplot=doplot,qavg=qavg,qst=qst,yval=y,rfoff=rfoff
default,filterbw,0
default,varthres,5;1e9;15.

default,text,0.01

;sh=85800




mdsopen,'h1data',sh
cur=mdsvalue2('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_5',/nozero)
volt=mdsvalue2('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_1',/nozero)
vfloat=mdsvalue2('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_3',/nozero)

vpl=mdsvalue2('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_2',/nozero)

rf=mdsvalue2('200*(\h1data::top.rf:rf_drive/5)**2',/nozero)
;rf=mdsvalue2('\H1DATA::TOP.RF:P_RF_NET',/nozero)
;rf.v=(rf.t ge 0.01 and rf.t le 0.013)*30
readpatchpr,sh,str

vfloat.v*=str.vflgain/str.ampgain3;250/5;
vpl.v*=str.vplgain/str.ampgain2;50/10
t_ball=(vpl.v-vfloat.v)/3.76

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
iwant=where(rfa gt 0.5)

next=text/(ta(1)-ta(0))
iwantr=[iwant(0)-next,iwant(n_elements(iwant)-1)+next]
iwantr=iwantr>1<(n_elements(ta)-1)
iwant=intspace(iwantr(0),iwantr(1))

if keyword_set(rfoff) then begin
   iwant=where(ta ge tavg(0) and ta le tavg(1))
endif
ta=ta(iwant)

nt2=n_elements(ta)-1

para=fltarr(3,nt2)
spara=para
csa=fltarr(nt2)
sta=fltarr(nt2)
var=fltarr(nt2)
for i=0,nt2-1 do begin

   idx=where(cur.t ge ta(i) and cur.t le ta(i+1))
   v2=volt2.v(idx);-vfloat.v(idx) ;;;zeroing
   c2=cur2.v(idx)

   rng=minmax(vfloat.v(idx))
   var(i)=rng(1)-rng(0)
   if rng(1)-rng(0) gt 10 then begin
;      para(*,i)=!values.f_nan
;      continue
   endif

   tmp=min(abs(c2),imn)
   par=[max(c2),v2(imn),10.]
    if ta(i) ge 0.039 and keyword_set(rfoff) then par(2)=2.
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
 if i mod 100 eq 0  and -2 eq -2 then begin
;   if ta(i) ge 0.043*100 then begin
      plot,v2,c2,psym=4,title=string(i,ta(i),paro)
      oplot,v2,ft,col=2,psym=-5
;      if  i gt 1000 then stop

      oplot,v2,exp_fit2( v2, par0),col=3,psym=-6
      

;      if i eq 2331 then stop
;      if i ge nt2*0.2 then stop
 ;     stop
      wait,0.1
;      STOP
   endif
   if i mod 100 eq 0 then print,i,nt2

endfor
;cond=csa gt max(csa)*0.1 or 
cond=var gt varthres;*2
idx=where(cond)
nidx=where(cond eq 0)
nn=n_elements(idx)
para2=para
if idx(0) eq -1 then goto,nn
for i=0,nn-1 do begin
   j=idx(i)
   tmp=where(nidx lt j) & if tmp(0) ne -1 then k0=nidx(tmp(n_elements(tmp)-1)) else continue
   tmp=where(nidx gt j) & if tmp(0) ne -1 then k1=nidx(tmp(0)) else continue
   para2(*,j)=(para(*,k0) * (j-k0) + para(*,k1) * (k1-j)) / (k1-k0)
;   print,para2(2,j),para(2,k0),para(2,k1),j,k0,k1
endfor
nn:
;plot,ta,para(1,*),yr=minmax(vfloat.v)
;oplot,ta,para2(1,*),col=2
;oplot,vfloat.t,vfloat.v,col=2
;stop
ts=para2(2,*)<60>0;smooth(para2(2,*)<60>0,10)


;save,para2,ta,ts,t_ball,vfloat,vpl,file=fn,/verb


;stop
   str='rm /data/anal/*'+string(sh,format='(I0)')+'*'
   print,str
;   stop
   spawn,str

tree='anal'
mdsedit, tree, sh, status=status, /quiet
if status ne 0  then begin
   mdstcl,'set tree '+tree
   mdstcl,'create pulse '+strtrim(sh,2)
   mdstcl,'edit '+tree+' /shot='+strtrim(sh, 2), status=status,/quiet

endif
putaddnode,'vfloat',vfloat.v,vfloat.t,units='V'
putaddnode,'vpl',vpl.v,vpl.t,units='V'
putaddnode,'tebp',t_ball,vpl.t,units='eV'
putaddnode,'vsw',volt.v,volt.t,units='eV'
putaddnode,'vsw_corr',volt2.v,volt2.t,units='eV'
putaddnode,'isw',vcur/resc,cur.t,units='A'
putaddnode,'isw_corr',cur2.v,cur2.t,units='A'
putaddnode,'chisq',csa,ta,units=''
putaddnode,'status',sta,ta,units=''
putaddnode,'isatsw',para(0,*),ta,units='A'
putaddnode,'vfl_var',var,ta,units='V'

putaddnode,'vflsw',para(1,*),ta,units='V'
putaddnode,'te_sw',para(2,*),ta,units='eV'
putaddnode,'isatsw_f',para2(0,*),ta,units='A'
putaddnode,'vflsw_f',para2(1,*),ta,units='V'
putaddnode,'te_sw_f',para2(2,*),ta,units='eV'


mdswrite, tree, sh


if keyword_set(dostop) then stop
end

pro loopit
sh=0
aa:
mdstcl,'show current h1data',output=output
sh1=long(((strsplit(output,/extract))(0))[3])
if sh1 eq sh then begin
   wait,5
   goto,aa
endif

sh=sh1

proc_probe,sh
goto,aa
end

pro anrange, sh0,sh1
sh=long(intspace(sh0,sh1))
nsh=n_elements(sh)
for i=0,nsh-1 do begin
;stop
   proc_probe,sh(i)
endfor
end
