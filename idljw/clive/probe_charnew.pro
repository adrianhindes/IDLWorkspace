@~/idl/clive/fitlsig


pro probe_charnew,sh,xr=xr,cap=cap,cc1=cc1,ccap=capc,scap=caps,sres=ress,tavg=tavg,varthres=varthres,filterbw=filterbw,qty=qty,recalc=recalc,doplot=doplot,qavg=qavg,qst=qst,yval=y,rfoff=rfoff
fn='/tmp/tsweep_'+string(sh,format='(I0)')+'.sav'
dum=file_search(fn,count=cnt)
if cnt ne 0 and not keyword_set(recalc) then begin
   restore,file=fn,/verb
   goto,docalc
endif


default,xr,[0,.05]

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
; if i mod 100 eq 0  and -2 eq -2 then begin
   if ta(i) ge 0.043*100 then begin
      plot,v2,c2,psym=4,title=string(i,ta(i),paro)
      oplot,v2,ft,col=2,psym=-5
;      if  i gt 1000 then stop

      oplot,v2,exp_fit2( v2, par0),col=3,psym=-6
      

;      if i eq 2331 then stop
;      if i ge nt2*0.2 then stop
      stop
      wait,0.1
;      STOP
   endif
   if i mod 100 eq 0 then print,i,nt2

endfor
;cond=csa gt max(csa)*0.1 or 
default,varthres,15.
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
   para2(*,j)=para(*,k0) * (j-k0) + para(*,k1) * (k1-j) / (k1-k0)
endfor
nn:
;plot,ta,para(1,*),yr=minmax(vfloat.v)
;oplot,ta,para2(1,*),col=2
;oplot,vfloat.t,vfloat.v,col=2
;stop
ts=para2(2,*)<60>0;smooth(para2(2,*)<60>0,10)


save,para2,ta,ts,t_ball,vfloat,vpl,file=fn,/verb
docalc:

if keyword_set(doplot) then begin

   plot,ta,ts,pos=posarr(2,2,0)
;oplot,ta,para2(2,*),psym=4,col=4
   oplot,vfloat.t,t_ball,col=2,psym=3
   oplot,ta,ts


plot,vfloat.t,vfloat.v,title='vfloat',pos=posarr(/next),/noer
oplot,vpl.t,vpl.v,col=2
plot,ta,para2(0,*),title='isat',pos=posarr(/next),/noer

endif

if qty eq 'tesw' then begin
   y={t:ta,v:ts}
endif
if qty eq 'isatsw' then begin
   y={t:ta,v:para2(0,*)}
endif

if qty eq 'cur2' then begin
   y=cur2
endif

if qty eq 'tebp' then begin
   y={t:vfloat.t,v:t_ball}
endif

if qty eq 'vfloatsw' then begin
   y=vfloat
endif
idx=where(y.t ge tavg(0) and y.t le tavg(1))
qavg=mean(y.v(idx))
qst=stdev(y.v(idx))
   


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





