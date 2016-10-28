
pro cmp,items,want=want,yr=yr,dostop=dostop,real=real,gs=gs,nameleg=nameleg,docalc=docalc,scal=scal
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
if want eq 'ectheor' then begin
   ecres,want=txt1,rout,a,/nostop & p=a*0

if n_elements(txt2) ne 0 then begin
   ecres,want=txt2,rout2,a2,/nostop & p2=a2*0
endif

if n_elements(txt3) ne 0 then begin
   ecres,want=txt3,rout3,a3,/nostop & p3=a3*0
endif
endif else begin

f1,txt1,outr=a,out2r=p,want=want,rout=rout,nostop=nostop,docalc=docalc,scal=scal
if n_elements(txt2) ne 0 then $
   f1,txt2,outr=a2,out2r=p2,want=want,rout=rout2,nostop=nostop

if n_elements(txt3) ne 0 then $
   f1,txt3,outr=a3,out2r=p3,want=want,rout=rout3,nostop=nostop

endelse
if keyword_set(gs) and keyword_set(real) then begin&mkfig,'~/cmpres.eps',xsize=13,ysize=11,font_size=10&!p.thick=3&endif
if keyword_set(gs) and not keyword_set(real) then begin&mkfig,'~/cmpres.eps',xsize=26,ysize=13,font_size=10&!p.thick=3&endif


leg=txt1
if n_elements(txt2) ne 0 then leg=[leg,txt2]
if n_elements(txt3) ne 0 then leg=[leg,txt3]

want2=want
if keyword_set(nameleg) then begin
   for i=0,n_elements(leg)-1 do begin
      if leg(i) eq '11003' then leg(i)='170GHz co ECCD'
      if leg(i) eq '11004' then leg(i)='170GHz cntr ECCD'
      if leg(i) eq '13491ac' then leg(i)='110 + 170GHz'
      if leg(i) eq '13491bb' then leg(i)='170GHz only'
   endfor
   want2=''
endif

dum=findgen(n_elements(leg))+1


if keyword_set(real) then begin
   plot,rout,a*cos(p),yr=[-1,1]*yr(1),xr=xr,xsty=1,xtitle='R(cm)',ytitle='d Te (eV)'
   if n_elements(txt2) ne 0 then oplot,rout2,a2*cos(p2),col=2
   if n_elements(txt3) ne 0 then oplot,rout3,a3*cos(p3),col=3
   oplot,!x.crange,[0,0]

legend,leg,col=dum,textcol=dum
endif else begin
   plot,rout,a,pos=posarr(2,2,0,cny=0.05,fy=0.5),yr=yr,xr=xr,xsty=1,title='amplitude '+want2,xtitle='R (cm)'
   if n_elements(txt2) ne 0 then oplot,rout2,a2,col=2
   if n_elements(txt3) ne 0 then oplot,rout3,a3,col=3
legend,leg,col=dum,textcol=dum,box=0,charsize=2

;p+=25*!dtor
;p2+=25*!dtor
   plot,rout,p*!radeg,pos=posarr(/next),/noer,psym=4,xr=xr,xsty=1,yr=[-180,180],ysty=1,title='phase',xtitle='R (cm)'
   if n_elements(txt2) ne 0 then oplot,rout2,p2*!radeg,col=2,psym=4
   if n_elements(txt3) ne 0 then oplot,rout3,p3*!radeg,col=3,psym=4
   oplot,!x.crange,[0,0]
;oplot,!x.crange,[1,1]*(-20)
;oplot,!x.crange,[1,1]*(160)


   plot,rout,a*cos(p),pos=posarr(/next),/noer,title='real part '+want2,yr=[-1,1]*yr(1),xr=xr,xsty=1,xtitle='R (cm)',ysty=1
   if n_elements(txt2) ne 0 then oplot,rout2,a2*cos(p2),col=2
   if n_elements(txt3) ne 0 then oplot,rout3,a3*cos(p3),col=3
   oplot,!x.crange,[0,0]


   plot,rout,a*sin(p),pos=posarr(/next),/noer,title='imaginary part '+want2,yr=[-1,1]*yr(1),xr=xr,xsty=1,xtitle='R (cm)',ysty=1
   if n_elements(txt2) ne 0 then oplot,rout2,a2*sin(p2),col=2
   if n_elements(txt3) ne 0 then oplot,rout3,a3*sin(p3),col=3
   oplot,!x.crange,[0,0]

endelse
endfig,/gs,/jp
!p.thick=0
stop

end

