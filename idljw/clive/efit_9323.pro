function jof, g
r=g.r
z=g.z
br=g.psirz*0
bz=br
for i=0,64 do br(i,*)=-deriv(z,g.psirz(i,*))/r(i)
for i=0,64 do bz(*,i)=deriv(r,g.psirz(*,i))/r
dbrdz=br*0
dbzdr=br*0
for i=0,64 do dbrdz(i,*)=deriv(z,br(i,*))
for i=0,64 do dbzdr(*,i)=deriv(r,bz(i,*))

jay=dbzdr - dbrdz

return,jay
end



;befit1,9323,1.925,1.950,field=3.;,/norun

trefa=0.925+[0,1,2,3,4,5,6,7]
ntref=n_elements(trefa)

nt=(7.5 - 1.0) / 0.025 - 1

tw=1.0 + 0.025 * findgen(nt)
idx=where(tw ne 4.075)
tw=tw(idx) & nt=n_elements(idx)

tref=tw*0

for i=0,nt-1 do begin
   dum=min(abs(tw(i) - trefa),imin)
   tref(i)=trefa(imin)
endfor


;goto,af

for i=0,nt-1 do begin

befit1,9323,tref(i),tw(i),field=3.,/norun;/noplot,/norun
endfor


stop
af:
rq1=fltarr(nt) + !values.f_nan
rax1=rq1
q=fltarr(65,nt)
qmin=fltarr(nt)
psimap=fltarr(65,nt)
qmap=psimap
jmap=psimap
for i=0,nt-1 do begin
   sh=9323
   dirmod=''
   dir='/home/cam112/EXP00'+string(sh,format='(I0)')+'_k'+dirmod
   twr=((round(tw(i)*1000/5)*5)) / 1000.
   fspec=string(sh,twr*1000,format='(I6.6,".",I6.6)')
   gfile=dir+'/g'+fspec
   g=readg(gfile)
   q(*,i)=g.qpsi
   rax1(i)=g.rmaxis
   qmin(i)=min(g.qpsi)
   iz0=value_locate(g.z,0)
   psimap(*,i)=g.psirz(*,iz0)
   qmap(*,i)=interpol(g.qpsi,linspace(g.ssimag,g.ssibry,65),psimap(*,i))
  
   jayrz=jof(g)
   jmap(*,i)=jayrz(*,iz0)

   if min(g.qpsi) gt 1 then continue
   psin=linspace(0,1,65)
;   dum=min(abs(g.qpsi-1),imin)
   imin=interpol(psin,g.qpsi,1)

   psin1=psin(imin)
   iax=value_locate(g.r,g.rmaxis)
   iz0=value_locate(g.z,0)
   var1=(g.psirz(iax:*,iz0)-g.ssimag)/(g.ssibry-g.ssimag)
   var2=g.r(iax:*)
   rofit = interpol(var2,var1,psin1)
   rq1(i)=rofit

   
   

endfor
af2:

plot,tw,rq1,yr=[1.7,2.0],ysty=1
oplot,tw,rax1,col=2
;stop


mkfig,'~/q_evol.eps',xsize=30,ysize=20,font_size=12
;imgplot,transpose(q),tw,linspace(0,1,65),/cb ,pos=posarr(1,2,0,cnx=0.1,cny=0.1),title='q',ytitle='norm psi',xtitle='time/s',offx=1.
;contour,transpose(q),tw,linspace(0,1,65),lev=[1,2,5],/noer,pos=posarr(/curr)

contourn2,transpose(qmap),tw,g.r,/cb ,pos=posarr(1,2,0,cnx=0.1,cny=0.1),title='q',ytitle='R (m)',xtitle='time/s',offx=1.,yr=[1.5,2.2],ysty=1,pal=15,xsty=1,/nonice,zr=[0.8,5]
contour,transpose(qmap),tw,g.r,lev=[1,2],/noer,pos=posarr(/curr),yr=[1.5,2.2],ysty=1,xsty=1

;contourn2,transpose(jmap),tw,g.r ,pos=posarr(1,2,0,cnx=0.1,cny=0.1),title='q',ytitle='norm psi',xtitle='time/s',offx=1.,yr=[1.5,2.2],ysty=1,pal=15
;contour,transpose(qmap),tw,g.r,lev=[1,2],/noer,pos=posarr(/curr),yr=[1.5,2.2],ysty=1


;getece, sh,res,v,t,r
;imgplot,res.v,res.t,-res.r,pos=posarr(/next),/cb,xr=!x.crange,/noer

plot,t,smooth(v(*,47-5),30),xr=!x.crange,xsty=1,pos=posarr(/next),/noer,/yno,title='ece temperature ch#6',xtitle='time'
vs=smooth(v(*,47-5,*),1000)
;oplot,t,vs,col=2
plot,t,smooth(v(*,47-5),100)-vs,xr=!x.crange,pos=posarr(/curr),/noer,col=4,xsty=4+1,ysty=4
;plot,t,smooth(v(*,47-5),30),xr=!x.crange,pos=posarr(/next),/noer,/yno
;plot,tw,qmin,pos=posarr(/curr),/noer,col=5,xsty=4,ysty=4
;befit1,9323,.925,1.00,field=3.;,/norun
endfig,/gs,/jp
end
