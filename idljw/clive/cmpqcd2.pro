;pro cmpq

;suff=['b1','b2','bmix2','bmix3','bmix4','bmix5']
na=2;n_elements(suff)
qarr=fltarr(na,65)
sharr2=[11003,11433]
tarr2=[3.70, 4.565]
suff=replicate('',2)
psin=fltarr(65,65,na)
rax=fltarr(na)
txt=strarr(na)
for i=0,na-1 do begin
   tarr=tarr2(i)
   sh=sharr2(i)
   txt(i)=string(sh,tarr,format='("#",I0," @t=",G0)')
   fspec=string(sh,tarr*1000,format='(I6.6,".",I6.6)')
   dir='/home/cam112/ikstarcp/my2/EXP'+string(sh,format='(I6.6)')+'_k'+''
   gfile=dir+'/g'+fspec

   g=readg(gfile)
   qarr(i,*)=g.qpsi
   print,gfile
   psin(*,*,i)=sqrt((g.psirz - g.ssimag)/(g.ssibry-g.ssimag))
   rax(i)=g.rmaxis
endfor
ee:
mkfig,'~/qcmp_meth3.eps',xsize=8,ysize=10,font_size=9



common ab, res,t,v
;getece,11003,res,t,v
iw=value_locate(t,3.5-0.15)

ns=10
ichan=47
plot,t-t(iw),smooth(v(*,ichan),ns)-v(iw,ichan),xr=[0,0.4],yr=[-.5e3,1.8e3],ysty=1,pos=posarr(1,2,0,cnx=0.1,cny=0.1,msraty=4,fx=0.75),xtitle='time from modulation start (s)',ytitle=textoidl('\Delta T_e (eV)'),title='Core ECE signals (R~1.8m)' 
print,res.r2(ichan)
;stop
;common ab2, res2,t2,v2
;getece,11433,res2,t2,v2
ichan=2
tr=[3.8,4.0]-0.145-0.05

tr=[6.2,8.2]-0.145 + 0.4 - 0.05
iw=value_locate(t,tr(0))
oplot,t2-t2(iw),smooth(v2(*,ichan),ns)-v2(iw,ichan)+1000,col=4;,xr=tr,yr=[-1e3,3e3],xsty=1,ysty=1
print,res2.r2(ichan)

plot,g.rhovn,qarr(0,*),yr=[0,6],xtitle='r/a',ytitle='q',thick=3,pos=posarr(/next),/noer,title='q profiles'
oplot,g.rhovn,qarr(1,*),col=4,thick=3

;,pos=posarr(2,1,0,cny=0.1)
txt=['co, B=2.85T','co, B=2.0T']
legend,txt,textcol=[1,4],box=0


;; pos=posarr(/next)
;; for i=0,na-1 do begin
;;    contour,psin(*,*,i),g.r,g.z,col=i+1,pos=pos,/noer,overplot=i gt 0,c_col=replicate(i+1,10),lev=linspace(0,1,6)+[0.02,fltarr(5)],/iso
;; endfor   
;; print,rax*100
;; print,(rax-rax(0))*100,'diff'
endfig,/gs,/jp


;befit1,7757,2.8,-1,inperr=[-1.25,-1.25,-1.25,-1.25,-0.94,-1.13,-1.27,-1.31,-1.29,-1.25,-1.25,-1.25,-1.25,-1.25,-1.25,-1.25]


end
