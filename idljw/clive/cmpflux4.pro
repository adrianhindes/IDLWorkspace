;mgetptsnew,rarr=r,zarr=z,str=p,ix=ix2,iy=iy2,pts=pts,rxs=rxs,rys=rys,/calca,dobeam2=dobeam2,distback=distback,mixfactor=mixfactor;,/plane
;ey=rys(*,*,0) * br1 + rys(*,*,1) * bt1 + rys(*,*,2) * bz1
;ex=rxs(*,*,0) * br1 + rxs(*,*,1) * bt1 + rxs(*,*,2) * bz1

;bzed=bz1
;bzed =( tgam * rys(*,*,1) - rxs(*,*,1)) * btcalc / (rxs(*,*,2) - 1*rys(*,*,2)*tgam)
;Objective to control local plasma pressure/current profiles and maniuplate MHD activity such as sawtooth and NTM
pro cmpflux4,items,want=want,yr=yr,dostop=dostop,xr=xr,gs=gs,nameleg=nameleg,onlymiddle=onlymiddle,rflip=rflip,fudge=fudge,just2=just2,docalc=docalc
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
default,xr,[-220,-160]
if want eq want then default,yr,[0,.04]

;want='imid'

dirmod=''
dirbase='/home/cam112/ikstarcp/my2'



sh=long(strmid(txt1,0,5))

if sh eq 13491 then sh=13494

if sh eq 11434 then sh=11433
if sh eq 11004 then sh=11003
if sh eq 10997 then sh=11003
if sh eq 9324 then sh=9323
if sh eq 9326 then sh=9323
if sh eq 9327 then sh=9323

if sh eq 11003 then dirmod=''
if sh eq 11433 then dirmod='5' ; no mse constrained is #4

dir=dirbase+'/EXP'+string(sh,format='(I6.6)')+'_k'+dirmod
if sh eq 11433 then tw=5.345
if sh eq 11003 then tw=3.45
if sh eq 9323 then tw=4.6
if sh eq 13494 then tw=1.1
if sh eq 13492 then tw=0.95

twr=((round(tw*1000/5)*5)) / 1000.
fspec=string(sh,twr*1000,format='(I6.6,".",I6.6)')
gfile=dir+'/g'+fspec
if sh eq 13494 then begin
   restore,file='~/g13494.1100.sav',/verb
endif else if sh eq 13492 then begin
   restore,file='~/g13492.950.sav',/verb
endif else g=readg(gfile)


psi=(g.psirz-g.ssimag(0))/(g.ssibry(0)-g.ssimag(0)) ;& psi=sqrt(psi)
iz0=value_locate(g.z,0)
rfine=linspace(min(g.r),max(g.r),64*10+1)
psi1=spline(g.r,psi(*,iz0),rfine) & psi1=sqrt(psi1)

iax=value_locate3(rfine,g.rmaxis)
psia=psi1(iax+1:*) & ra=rfine(iax+1:*)
psib=psi1(0:iax-1) & rb=rfine(0:iax-1)

nn=50
psig=linspace(min(psi1),keyword_set(onlymiddle) ? 0.5 : 0.7,nn)

rag=interpolo(ra,psia,psig)
rbg=interpolo(rb,psib,psig)

if n_elements(txt2) ne 0 then begin

   sh=long(strmid(txt2,0,5))
if sh eq 13491 then sh=13494

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

   if sh eq 13494 then begin
      dum=g & restore,file='~/g13494.1100.sav',/verb & g2=g & g=dum
   endif else if sh eq 13492 then begin
      dum=g & restore,file='~/g13492.950.sav',/verb & g2=g & g=dum
   endif else  g2=readg(gfile)
   
   psi=(g2.psirz-g2.ssimag(0))/(g2.ssibry(0)-g2.ssimag(0)) ;& psi=sqrt(psi)
   iz0=value_locate(g2.z,0)
   rfine=linspace(min(g2.r),max(g2.r),64*10+1)
   psi1=spline(g2.r,psi(*,iz0),rfine) & psi1=sqrt(psi1)
   
   iax=value_locate3(rfine,g2.rmaxis)
   psia=psi1(iax+1:*) & ra=rfine(iax+1:*)
   psib=psi1(0:iax-1) & rb=rfine(0:iax-1)

   ;psig=linspace(min(psi1),0.7,nn)

   rag2=interpolo(ra,psia,psig)
   rbg2=interpolo(rb,psib,psig)
endif




;interpolo(a,-rout,

;stop


f1,txt1,outr=a,out2r=p,want=want,rout=rout,nostop=nostop,rxs=rxs,rys=rys,docalc=docalc
if n_elements(txt2) ne 0 then $
   f1,txt2,outr=a2,out2r=p2,want=want,rout=rout2,nostop=nostop,rxs=rxs2,rys=rys2
if keyword_set(fudge) then begin
   rxs=rxs2
   rys=rys2
endif
;stop
if n_elements(txt3) ne 0 then $
   f1,txt3,outr=a3,out2r=p3,want=want,rout=rout3,nostop=nostop

if keyword_set(rflip) then begin
   rout=-rout
   if n_elements(rout2) ne 0 then rout2=-rout2
   xr=-reverse(xr)
endif

if want eq 'bmid' or want eq 'jmid' then begin
   aold=a
   if want eq 'bmid' then factor3=1e3
   if want eq 'jmid' then factor3 = 2.
   tgam=a*!dtor
   btcalc = g.bcentr(0) * g.rmaxis(0) / (abs(rout)*0.01) 
;   if sh eq 13494 then
 btcalc=abs(btcalc)
   if sh eq 11004 then btcalc*=3.15/2.85

   a =( -tgam * rys(*,1)) * btcalc / (rxs(*,2) - 0*rys(*,2)*tgam)*factor3
 
   if n_elements(txt2) ne 0 then begin
   
      aold=a2
      tgam=a2*!dtor
      btcalc = g2.bcentr(0) * g2.rmaxis(0) / (abs(rout2)*0.01) 
      if sh eq 11004 then btcalc*=3.15/2.85
      
      a2 =( -tgam * rys(*,1)) * btcalc / (rxs(*,2) - 0*rys(*,2)*tgam)*factor3
      a2=abs(a2)
   endif

endif


   


leg=txt1
if n_elements(txt2) ne 0 then leg=[leg,txt2]
if n_elements(txt3) ne 0 then leg=[leg,txt3]
want2=want
if keyword_set(nameleg) then begin
   for i=0,n_elements(leg)-1 do begin
      if leg(i) eq '11003' then leg(i)='#11003 co ECCD (2.85T)'
      if leg(i) eq '11004' then leg(i)='#11004 cntr ECCD (3.15T)'

      if leg(i) eq '9323b' then leg(i)='#9323 co ECCD (B=3.0T)'
      if leg(i) eq '11433a' then leg(i)='110GHz co ECCD'
      if leg(i) eq '11433c' then leg(i)='#11433, co ECCD (B=2.0T, hmode)'
      if leg(i) eq '11433b' then leg(i)='170GHz+110GHz'
      if leg(i) eq '11433a' then leg(i)='110GHz'

      if leg(i) eq '11434a' then leg(i)='110GHz cntr ECCD'

      if leg(i) eq '13491ac' then leg(i)='110 + 170GHz'
      if leg(i) eq '13491bb' then leg(i)='170GHz only'

   endfor
   want2=want eq 'bmid' ? 'bz' : ''
endif
if want eq 'bmid' then begin
   ytitle='mT'
endif

if keyword_set(gs) then begin&mkfig,'~/cmpres_'+txt1+'_'+want+'.eps',xsize=26,ysize=18,font_size=10&!p.thick=3&endif else wset2,0

if keyword_set(just2) then begin
   pos=posarr(1,2,0,cnx=0.1,fx=0.8,fy=0.5)
if keyword_set(gs) then begin&mkfig,'~/cmpres_'+txt1+'_'+want+'.eps',xsize=13,ysize=18,font_size=13&!p.thick=3&endif else wset2,0

endif  else begin
pos=posarr(2,2,0,cny=0.05,fy=0.5,msratx=7) 
if keyword_set(gs) then begin&mkfig,'~/cmpres_'+txt1+'_'+want+'.eps',xsize=26,ysize=18,font_size=10&!p.thick=3&endif else wset2,0

endelse


plot,rout,a,pos=pos,yr=yr,xr=xr,xsty=1,title='amplitude, change of '+want2,xtitle='R (cm)',ytitle=ytitle

if n_elements(txt2) ne 0 then oplot,rout2,a2,col=2
if n_elements(txt3) ne 0 then oplot,rout3,a3,col=3
dum=findgen(n_elements(leg))+1
legend,leg,col=dum,textcol=dum,box=0,charsize=1.
;oplot,xr(0)/abs(xr(0))*100*g.rmaxis*[1,1],!y.crange,linesty=3,thick=1

;p+=25*!dtor
;p2+=25*!dtor
plot,rout,p*!radeg,pos=posarr(/next),/noer,psym=4,xr=xr,xsty=1,yr=[-180,180],ysty=1,title='phase',xtitle='R (cm)',ytitle='deg'
if n_elements(txt2) ne 0 then oplot,rout2,p2*!radeg,col=2,psym=4
if n_elements(txt3) ne 0 then oplot,rout3,p3*!radeg,col=3,psym=4
oplot,!x.crange,[0,0]
;oplot,!x.crange,[1,1]*(-20)
;oplot,!x.crange,[1,1]*(160)
oplot,xr(0)/abs(xr(0))*100*g.rmaxis*[1,1],!y.crange,linesty=3,thick=1

if keyword_set(just2) then begin
   endfig,/gs,/jp
   return
endif



plot,rout,a*cos(p),pos=posarr(/next),/noer,title='real part '+want2,yr=[-1,1]*yr(1),xr=xr,xsty=1,xtitle='R (cm)',ysty=1,ytitle=ytitle
if n_elements(txt2) ne 0 then oplot,rout2,a2*cos(p2),col=2
if n_elements(txt3) ne 0 then oplot,rout3,a3*cos(p3),col=3
oplot,!x.crange,[0,0],thick=1

iww=value_locate(psig,0.2)
;oplot,-100*rag(iww)*[1,1],!y.crange,col=2
;oplot,-100*rbg(iww)*[1,1],!y.crange,col=2
iww=value_locate(psig,0.4)
;oplot,-100*rag(iww)*[1,1],!y.crange,col=3
;oplot,-100*rbg(iww)*[1,1],!y.crange,col=3
oplot,xr(0)/abs(xr(0))*100*g.rmaxis*[1,1],!y.crange,linesty=3,thick=1
legend,leg,col=dum,textcol=dum,box=0,charsize=1.

plot,rout,a*sin(p),pos=posarr(/next),/noer,title='imaginary part '+want2,yr=[-1,1]*yr(1),xr=xr,xsty=1,xtitle='R (cm)',ysty=1,ytitle=ytitle
if n_elements(txt2) ne 0 then oplot,rout2,a2*sin(p2),col=2
if n_elements(txt3) ne 0 then oplot,rout3,a3*sin(p3),col=3
oplot,!x.crange,[0,0],thick=1

;iww=value_locate(psig,0.2)
;oplot,-100*rag(iww)*[1,1],!y.crange,col=2
;oplot,-100*rbg(iww)*[1,1],!y.crange,col=2
iww=value_locate(psig,0.4)
;oplot,-100*rag(iww)*[1,1],!y.crange,col=3
;oplot,-100*rbg(iww)*[1,1],!y.crange,col=3
oplot,xr(0)/abs(xr(0))*100*g.rmaxis*[1,1],!y.crange,linesty=3,thick=1

if keyword_set(gs) then endfig,/gs,/jp

stop
if not keyword_set(gs) then wset2,1
oval=!values.f_nan

if keyword_set(gs)  then begin&mkfig,'~/cmpresf_'+txt1+'_'+want+'.eps',xsize=20,ysize=18,font_size=10&!p.thick=3&endif


xtitle=textoidl('\rho')
dum=posarr(2,3,1,cny=0.05,fy=0.5)
if want eq 'jmid' then sgn=1
if want eq 'bmid' then sgn=-1
;if keyword_set(onlymiddle) then goto,ng

plot,psig,interpolo(a*cos(p),abs(rout)*0.01,rag,oval=oval),pos=posarr(2,3,0,cny=0.05,fy=0.5,msratx=7,fx=0.5),title=keyword_set(nameleg) ? 'real part bz' : 'cos '+want,yr=[-1,1]*yr(1),xsty=1,ysty=1,xtitle=xtitle,ytitle=ytitle
oplot,psig,interpolo(a*cos(p),abs(rout)*0.01,rbg,oval=oval),linesty=2
if n_elements(txt2) ne 0 then begin
oplot,psig,interpolo(a2*cos(p2),abs(rout2)*0.01,rag2,oval=oval),col=2
oplot,psig,interpolo(a2*cos(p2),abs(rout2)*0.01,rbg2,oval=oval),linesty=2,col=2


endif

if n_elements(txt3) ne 0 then oplot,rout3,a3*cos(p3),col=3
oplot,!x.crange,[0,0],thick=1
legend,['outboard','inboard'],linesty=[0,2],box=0

plot,psig,interpolo(a*sin(p),abs(rout)*0.01,rag,oval=oval),pos=posarr(/next),/noer,title=keyword_set(nameleg) ? 'imaginary part bz' : 'sin '+want,yr=[-1,1]*yr(1),xsty=1,ysty=1,xtitle=xtitle,ytitle=ytitle
oplot,psig,interpolo(a*sin(p),abs(rout)*0.01,rbg,oval=oval),linesty=2

if n_elements(txt2) ne 0 then begin
oplot,psig,interpolo(a2*sin(p2),abs(rout2)*0.01,rag2,oval=oval),col=2
oplot,psig,interpolo(a2*sin(p2),abs(rout2)*0.01,rbg2,oval=oval),linesty=2,col=2
endif

if n_elements(txt3) ne 0 then oplot,rout3,a3*sin(p3),col=3
oplot,!x.crange,[0,0],thick=1
legend,['outboard','inboard'],linesty=[0,2],box=0

ng:
c1=interpolo(a*cos(p),abs(rout)*0.01,rag,oval=oval) + sgn*interpolo(a*cos(p),abs(rout)*0.01,rbg,oval=oval)



if want eq 'bmid' then begin
   aminor=0.55;m
   c1 = c1 * psig * aminor * 2*!pi / (4*!pi*1e-7) * 2 / 1e3 / 1e3
   yr(1)=yr(1) *  abs(aminor) * 2*!pi / (4*!pi*1e-7) * 2/10/ 1e3 /1e3*1.5
endif


;if keyword_set(onlymiddle) then goto,ng2

plot,psig,c1,linesty=0,thick=3,pos=posarr(/next),/noer,yr=[-1,1]*yr(1),xsty=1,ysty=1,title=keyword_set(nameleg) ? (keyword_set(onlymiddle) ? 'real part' : 'real part, current') : 'cos '+want+', sum (inboard+outboard)',xtitle=xtitle,ytitle=want eq 'bmid' ? 'kA' : bmid
oplot,!x.crange,[0,0],thick=1
if n_elements(txt2) ne 0 then begin
   c2=interpolo(a2*cos(p2),abs(rout2)*0.01,rag2,oval=oval) + sgn*interpolo(a2*cos(p2),abs(rout2)*0.01,rbg2,oval=oval)
   if want eq 'bmid' then begin
      c2 = c2 * psig * aminor * 2*!pi / (4*!pi*1e-7) * 2 / 1e3/1e3
   endif
endif
if n_elements(txt2) ne 0 then oplot,psig,c2,linesty=0,thick=3,col=2


dum=findgen(n_elements(leg))+1
legend,leg,col=dum,textcol=dum,charsize=1.,box=0

s1=interpolo(a*sin(p),abs(rout)*0.01,rag,oval=oval) + sgn*interpolo(a*sin(p),abs(rout)*0.01,rbg,oval=oval)

if want eq 'bmid' then begin

   s1 = s1 * psig * aminor * 2*!pi / (4*!pi*1e-7) * 2 / 1e3/1e3
endif


plot,psig,s1,linesty=0,thick=3,pos=posarr(/next),/noer,yr=[-1,1]*yr(1),xsty=1,ysty=1,title=keyword_set(nameleg) ? (keyword_set(onlymiddle) ? 'imaginary part' :'imaginary part, current') : 'sin '+want+', sum (inboard+outboard)',xtitle=xtitle,ytitle=want eq 'bmid' ? 'kA' : bmid
oplot,!x.crange,[0,0],thick=1
if n_elements(txt2) ne 0 then begin
   s2=interpolo(a2*sin(p2),abs(rout2)*0.01,rag2,oval=oval) + sgn*interpolo(a2*sin(p2),abs(rout2)*0.01,rbg2,oval=oval)
   if want eq 'bmid' then begin
      s2 = s2 * psig * aminor * 2*!pi / (4*!pi*1e-7) * 2 / 1e3/1e3
   endif
endif
if n_elements(txt2) ne 0 then oplot,psig,s2,linesty=0,thick=3,col=2

if not keyword_set(nameleg) then begin
   xyouts,0.45,0.97,txt1,/norm
   if n_elements(txt2) ne 0 then xyouts,0.55, 0.97, txt2,/norm,col=2
endif

;ng2:
plot,psig,sqrt(c1^2+s1^2),linesty=0,thick=3,pos=posarr(/next),/noer,yr=[0,1]*yr(1),xsty=1,ysty=1,title=keyword_set(nameleg) ? 'perturbed current amplitude' : 'amp '+want+', sum (inboard+outboard)',xtitle=xtitle,ytitle=want eq 'bmid' ? 'kA' : bmid
if n_elements(txt2) ne 0 then oplot,psig,sqrt(c2^2+s2^2),linesty=0,thick=3,col=2

legend,leg,col=dum,textcol=dum,charsize=1.,box=0


plot,psig,atan(s1,c1)*!radeg,linesty=0,thick=3,pos=posarr(/next),/noer,yr=[-180,180],xsty=1,ysty=1,title=keyword_set(nameleg) ? 'perturbed current phase' : 'phase '+want+', sum (inboard+outboard)',xtitle=xtitle,ytitle='deg'
if n_elements(txt2) ne 0 then oplot,psig,atan(s2,c2)*!radeg,linesty=0,thick=3,col=2
oplot,!x.crange,[0,0],thick=1
ng2:

endfig,/gs,/jp
!p.thick=0
stop

end

;cmpflux,'11434a'
;end
