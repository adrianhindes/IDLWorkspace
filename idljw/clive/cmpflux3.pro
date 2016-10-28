
pro cmpflux3,items,want=want,yr=yr,dostop=dostop,xr=xr,gs=gs,nameleg=nameleg
nostop= keyword_set(dostop) eq 0
txt1=items(0)
if n_elements(items) gt 1 then txt2=items(1)
if n_elements(items) gt 2 then txt3=items(2)

if items(0) eq 'eccd_cocntr' then begin
   txt1='11003'
   txt2='11004'
endif

if items(0) eq 'ech_cocntr' then begin
   txt1='11433a'
   txt2='11434a'
endif
if items(0) eq 'ech_eccd' then begin
   txt1='11433a'
   txt2='11433c'
endif
if items(0) eq 'eccd_freq' then begin
   txt1='9323'
   txt2='9326'
endif

if items(0) eq 'respos1' then begin
   txt1='9323'
   txt2='11003'
endif
if items(0) eq 'respos1a' then begin
   txt2='9323'
   txt1='11003'
endif

if items(0) eq 'respos2' then begin
   txt1='11003'
   txt2='10997b'
endif

if items(0) eq 'respos3' then begin
   txt1='10997b'
   txt2='10997c'
endif





default,want,'jmid'
default,xr,[-220,-165]
if want eq want then default,yr,[0,.04]

;want='imid'

dirmod=''
dirbase='/home/cam112/ikstarcp/my2'

sh=long(strmid(txt1,0,5))
if sh eq 11434 then sh=11433
if sh eq 11004 then sh=11003
if sh eq 10997 then sh=11003
if sh eq 9324 then sh=9323

if sh eq 11003 then dirmod=''
if sh eq 11433 then dirmod='5' ; no mse constrained is #4

dir=dirbase+'/EXP'+string(sh,format='(I6.6)')+'_k'+dirmod
if sh eq 11433 then tw=5.345
if sh eq 11003 then tw=3.45
if sh eq 9323 then tw=4.6
twr=((round(tw*1000/5)*5)) / 1000.
fspec=string(sh,twr*1000,format='(I6.6,".",I6.6)')
gfile=dir+'/g'+fspec
g=readg(gfile)

psi=(g.psirz-g.ssimag)/(g.ssibry-g.ssimag) ;& psi=sqrt(psi)
iz0=value_locate(g.z,0)
rfine=linspace(min(g.r),max(g.r),64*10+1)
psi1=spline(g.r,psi(*,iz0),rfine) & psi1=sqrt(psi1)

iax=value_locate3(rfine,g.rmaxis)
psia=psi1(iax+1:*) & ra=rfine(iax+1:*)
psib=psi1(0:iax-1) & rb=rfine(0:iax-1)

nn=50
psig=linspace(min(psi1),0.7,nn)

rag=interpolo(ra,psia,psig)
rbg=interpolo(rb,psib,psig)

if n_elements(txt2) ne 0 then begin

   sh=long(strmid(txt2,0,5))
   if sh eq 11434 then sh=11433
   if sh eq 11004 then sh=11003
   if sh eq 10997 then sh=11003
   if sh eq 9324 then sh=9323
   
   if sh eq 11003 then dirmod=''
   if sh eq 11433 then dirmod='5'
   
   dir=dirbase+'/EXP'+string(sh,format='(I6.6)')+'_k'+dirmod
   if sh eq 11433 then tw=5.345
   if sh eq 11003 then tw=3.45
   if sh eq 9323 then tw=4.6
   twr=((round(tw*1000/5)*5)) / 1000.
   fspec=string(sh,twr*1000,format='(I6.6,".",I6.6)')
   gfile=dir+'/g'+fspec
   g=readg(gfile)
   
   psi=(g.psirz-g.ssimag)/(g.ssibry-g.ssimag) ;& psi=sqrt(psi)
   iz0=value_locate(g.z,0)
   rfine=linspace(min(g.r),max(g.r),64*10+1)
   psi1=spline(g.r,psi(*,iz0),rfine) & psi1=sqrt(psi1)
   
   iax=value_locate3(rfine,g.rmaxis)
   psia=psi1(iax+1:*) & ra=rfine(iax+1:*)
   psib=psi1(0:iax-1) & rb=rfine(0:iax-1)

   ;psig=linspace(min(psi1),0.7,nn)

   rag2=interpolo(ra,psia,psig)
   rbg2=interpolo(rb,psib,psig)
endif




;interpolo(a,-rout,

;stop


f1,txt1,outr=a,out2r=p,want=want,rout=rout,nostop=nostop
if n_elements(txt2) ne 0 then $
   f1,txt2,outr=a2,out2r=p2,want=want,rout=rout,nostop=nostop

if n_elements(txt3) ne 0 then $
   f1,txt3,outr=a3,out2r=p3,want=want,rout=rout,nostop=nostop


wset2,0

plot,rout,a,pos=posarr(2,2,0),yr=yr,xr=xr,xsty=1
if n_elements(txt2) ne 0 then oplot,rout,a2,col=2
if n_elements(txt3) ne 0 then oplot,rout,a3,col=3

;p+=25*!dtor
;p2+=25*!dtor
plot,rout,p*!radeg,pos=posarr(/next),/noer,psym=4,xr=xr,xsty=1,yr=[-180,180],ysty=1
if n_elements(txt2) ne 0 then oplot,rout,p2*!radeg,col=2,psym=4
if n_elements(txt3) ne 0 then oplot,rout,p3*!radeg,col=3,psym=4
oplot,!x.crange,[0,0]
;oplot,!x.crange,[1,1]*(-20)
;oplot,!x.crange,[1,1]*(160)




plot,rout,a*cos(p),pos=posarr(/next),/noer,title='cos',yr=[-1,1]*yr(1),xr=xr,xsty=1
if n_elements(txt2) ne 0 then oplot,rout,a2*cos(p2),col=2
if n_elements(txt3) ne 0 then oplot,rout,a3*cos(p3),col=3
oplot,!x.crange,[0,0]

iww=value_locate(psig,0.2)
oplot,-100*rag(iww)*[1,1],!y.crange,col=2
oplot,-100*rbg(iww)*[1,1],!y.crange,col=2
iww=value_locate(psig,0.4)
oplot,-100*rag(iww)*[1,1],!y.crange,col=3
oplot,-100*rbg(iww)*[1,1],!y.crange,col=3
oplot,-100*g.rmaxis*[1,1],!y.crange

plot,rout,a*sin(p),pos=posarr(/next),/noer,title='sin',yr=[-1,1]*yr(1),xr=xr,xsty=1
if n_elements(txt2) ne 0 then oplot,rout,a2*sin(p2),col=2
if n_elements(txt3) ne 0 then oplot,rout,a3*sin(p3),col=3
oplot,!x.crange,[0,0]

iww=value_locate(psig,0.2)
oplot,-100*rag(iww)*[1,1],!y.crange,col=2
oplot,-100*rbg(iww)*[1,1],!y.crange,col=2
iww=value_locate(psig,0.4)
oplot,-100*rag(iww)*[1,1],!y.crange,col=3
oplot,-100*rbg(iww)*[1,1],!y.crange,col=3
oplot,-100*g.rmaxis*[1,1],!y.crange

if not keyword_set(gs) then wset2,1
oval=!values.f_nan

if keyword_set(gs)  then begin&mkfig,'~/cmpresf_'+txt1+'_'+want+'.eps',xsize=20,ysize=18,font_size=10&!p.thick=3&endif

;; plot,psig,interpolo(a,-rout*.01,rag,oval=oval),pos=posarr(2,2,0),yr=yr,xsty=1
;; oplot,psig,interpolo(a,-rout*.01,rbg,oval=oval),linesty=2
;; ;if n_elements(txt2) ne 0 then oplot,rout,a2,col=2
;; if n_elements(txt3) ne 0 then oplot,rout,a3,col=3

;; ;p+=25*!dtor
;; ;p2+=25*!dtor
;; plot,psig,interpolo(p*!radeg,-rout*0.01,rag,oval=oval),pos=posarr(/next),/noer,psym=4,xsty=1,yr=[-180,180],ysty=1
;; oplot,psig,interpolo(p*!radeg,-rout*0.01,rbg,oval=oval),psym=5
;; ;if n_elements(txt2) ne 0 then oplot,rout,p2*!radeg,col=2,psym=4
;; if n_elements(txt3) ne 0 then oplot,rout,p3*!radeg,col=3,psym=4
;; oplot,!x.crange,[0,0]
;; ;oplot,!x.crange,[1,1]*(-20)
;; ;oplot,!x.crange,[1,1]*(160)

xtitle=textoidl('\rho')
dum=posarr(2,3,1,cny=0.05,fy=0.5)
if want eq 'jmid' then sgn=1
if want eq 'bmid' then sgn=-1
;goto,ng
plot,psig,interpolo(a*cos(p),-rout*0.01,rag,oval=oval),pos=posarr(2,3,0,cny=0.05,fy=0.5),title=keyword_set(nameleg) ? 'real part' : 'cos '+want,yr=[-1,1]*yr(1),xsty=1,ysty=1,xtitle=xtitle
oplot,psig,interpolo(a*cos(p),-rout*0.01,rbg,oval=oval),linesty=2
if n_elements(txt2) ne 0 then begin
oplot,psig,interpolo(a2*cos(p2),-rout*0.01,rag2,oval=oval),col=2
oplot,psig,interpolo(a2*cos(p2),-rout*0.01,rbg2,oval=oval),linesty=2,col=2


endif

if n_elements(txt3) ne 0 then oplot,rout,a3*cos(p3),col=3
oplot,!x.crange,[0,0]
legend,['outboard','inboard'],linesty=[0,2],box=0

plot,psig,interpolo(a*sin(p),-rout*0.01,rag,oval=oval),pos=posarr(/next),/noer,title=keyword_set(nameleg) ? 'imaginary part' : 'sin '+want,yr=[-1,1]*yr(1),xsty=1,ysty=1,xtitle=xtitle
oplot,psig,interpolo(a*sin(p),-rout*0.01,rbg,oval=oval),linesty=2

if n_elements(txt2) ne 0 then begin
oplot,psig,interpolo(a2*sin(p2),-rout*0.01,rag2,oval=oval),col=2
oplot,psig,interpolo(a2*sin(p2),-rout*0.01,rbg2,oval=oval),linesty=2,col=2
endif

if n_elements(txt3) ne 0 then oplot,rout,a3*sin(p3),col=3
oplot,!x.crange,[0,0]
legend,['outboard','inboard'],linesty=[0,2],box=0

ng:
c1=interpolo(a*cos(p),-rout*0.01,rag,oval=oval) + sgn*interpolo(a*cos(p),-rout*0.01,rbg,oval=oval)
plot,psig,c1,linesty=3,thick=3,pos=posarr(/next),/noer,yr=[-1,1]*yr(1),xsty=1,ysty=1,title=keyword_set(nameleg) ? 'real part, outboard-inboard' : 'cos '+want+', sum (inboard+outboard)',xtitle=xtitle
oplot,!x.crange,[0,0]
if n_elements(txt2) ne 0 then c2=interpolo(a2*cos(p2),-rout*0.01,rag2,oval=oval) + sgn*interpolo(a2*cos(p2),-rout*0.01,rbg2,oval=oval)
if n_elements(txt2) ne 0 then oplot,psig,c2,linesty=3,thick=3,col=2


leg=txt1
if n_elements(txt2) ne 0 then leg=[leg,txt2]
if n_elements(txt3) ne 0 then leg=[leg,txt3]
want2=want
if keyword_set(nameleg) then begin
   for i=0,n_elements(leg)-1 do begin
      if leg(i) eq '11003' then leg(i)='170GHz co ECCD'
      if leg(i) eq '11004' then leg(i)='170GHz cntr ECCD'

      if leg(i) eq '11433a' then leg(i)='110GHz co ECCD'
      if leg(i) eq '11434a' then leg(i)='110GHz co ECCD'
   endfor
   want2=''
endif

dum=findgen(n_elements(leg))+1
legend,leg,col=dum,textcol=dum,charsize=1.5,box=0

s1=interpolo(a*sin(p),-rout*0.01,rag,oval=oval) + sgn*interpolo(a*sin(p),-rout*0.01,rbg,oval=oval)
plot,psig,s1,linesty=3,thick=3,pos=posarr(/next),/noer,yr=[-1,1]*yr(1),xsty=1,ysty=1,title=keyword_set(nameleg) ? 'imaginary part, outboard-inboard' : 'sin '+want+', sum (inboard+outboard)',xtitle=xtitle
oplot,!x.crange,[0,0]
if n_elements(txt2) ne 0 then s2=interpolo(a2*sin(p2),-rout*0.01,rag2,oval=oval) + sgn*interpolo(a2*sin(p2),-rout*0.01,rbg2,oval=oval)
if n_elements(txt2) ne 0 then oplot,psig,s2,linesty=3,thick=3,col=2

if not keyword_set(nameleg) then begin
   xyouts,0.45,0.97,txt1,/norm
   if n_elements(txt2) ne 0 then xyouts,0.55, 0.97, txt2,/norm,col=2
endif

;goto,ng2
plot,psig,sqrt(c1^2+s1^2),linesty=3,thick=3,pos=posarr(/next),/noer,yr=[0,1]*yr(1),xsty=1,ysty=1,title=keyword_set(nameleg) ? 'amplitude, outboard-inboard' : 'amp '+want+', sum (inboard+outboard)',xtitle=xtitle
if n_elements(txt2) ne 0 then oplot,psig,sqrt(c2^2+s2^2),linesty=3,thick=3,col=2


plot,psig,atan(s1,c1)*!radeg,linesty=3,thick=3,pos=posarr(/next),/noer,yr=[-180,180],xsty=1,ysty=1,title=keyword_set(nameleg) ? 'phase, outboard-inboard' : 'amp '+want+', sum (inboard+outboard)',xtitle=xtitle
if n_elements(txt2) ne 0 then oplot,psig,atan(s2,c2)*!radeg,linesty=3,thick=3,col=2

ng2:

endfig,/gs,/jp
!p.thick=0
stop

end

;cmpflux,'11434a'
;end
