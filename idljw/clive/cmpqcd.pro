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
mkfig,'~/qcmp_meth.eps',xsize=16,ysize=10,font_size=10
plotm,g.rhovn,transpose(qarr),yr=[0,8],xtitle='r/a',ytitle='q',pos=posarr(2,1,0,cny=0.1)

legend,txt,textcol=indgen(na)+1,/right,box=0

pos=posarr(/next)
for i=0,na-1 do begin
   contour,psin(*,*,i),g.r,g.z,col=i+1,pos=pos,/noer,overplot=i gt 0,c_col=replicate(i+1,10),lev=linspace(0,1,6)+[0.02,fltarr(5)],/iso
endfor   
print,rax*100
print,(rax-rax(0))*100,'diff'
endfig,/gs,/jp


;befit1,7757,2.8,-1,inperr=[-1.25,-1.25,-1.25,-1.25,-0.94,-1.13,-1.27,-1.31,-1.29,-1.25,-1.25,-1.25,-1.25,-1.25,-1.25,-1.25]


end
