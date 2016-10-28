pro cmpq

suff=['b1','b2','bmix2','bmix3','bmix4','bmix5']
na=n_elements(suff)
qarr=fltarr(na,65)
sh=9414
psin=fltarr(65,65,na)
rax=fltarr(na)
for i=0,na-1 do begin
   tarr=5.975
   fspec=string(sh,tarr*1000,format='(I6.6,".",I6.6)')
   dir='/home/cam112/ikstar/my2/EXP00'+string(sh,format='(I0)')+'_k'+''
   gfile=dir+'/g_'+suff(i)+'_'+fspec
   g=readg(gfile)
   qarr(i,*)=g.qpsi
   print,gfile
   psin(*,*,i)=sqrt((g.psirz - g.ssimag)/(g.ssibry-g.ssimag))
   rax(i)=g.rmaxis
endfor
ee:
mkfig,'~/qcmp_meth.eps',xsize=20,ysize=10,font_size=10
plotm,g.rhovn,transpose(qarr),yr=[0,8],xtitle='r/a',ytitle='q',pos=posarr(2,1,0)
legend,suff,textcol=indgen(na)+1,/right,box=0,/bottom

pos=posarr(/next)
for i=0,na-1 do begin
   contour,psin(*,*,i),g.r,g.z,col=i+1,pos=pos,/noer,overplot=i gt 0,c_col=replicate(i+1,10),lev=linspace(0,1,6)+[0.02,fltarr(5)],/iso
endfor   
print,rax*100
print,(rax-rax(0))*100,'diff'
endfig,/gs,/jp


;befit1,7757,2.8,-1,inperr=[-1.25,-1.25,-1.25,-1.25,-0.94,-1.13,-1.27,-1.31,-1.29,-1.25,-1.25,-1.25,-1.25,-1.25,-1.25,-1.25]


end


;befitf,9414,5.925, 5.975,field=3.,gfile='/home/cam112/ikstar/my2/EXP009414_k/g_orig_009414.005975',outgname='b1';,mixfactor=0.5;,/cmpang;,/dobeam2

;befitf,9414,5.925, 5.975,field=3.,gfile='/home/cam112/ikstar/my2/EXP009414_k/g_orig_009414.005975',/dobeam2,outgname='b2';,mixfactor=0.5;,/cmpang;,/dobeam2

;befitf,9414,5.925, 5.975,field=3.,gfile='/home/cam112/ikstar/my2/EXP009414_k/g_orig_009414.005975',outgname='bmix2',mixfactor=0.5;,/cmpang;,/dobeam2

;befitf,9414,5.925, 5.975,field=3.,gfile='/home/cam112/ikstar/my2/EXP009414_k/g_orig_009414.005975',outgname='bmix3',mixfactor=0.5,errmixfactor=-0.2;,/cmpang;,/dobeam2

;befitf,9414,5.925, 5.975,field=3.,gfile='/home/cam112/ikstar/my2/EXP009414_k/g_orig_009414.005975',outgname='bmix4',mixfactor=0.5,errmixfactor=0.2;,/cmpang;,/dobeam2

befitf,9414,5.925, 5.975,field=3.,gfile='/home/cam112/ikstar/my2/EXP009414_k/g_orig_009414.005975',outgname='bmix5',mixfactor=0.5,errmixfactor=0.4;,/cmpang;,/dobeam2

;cmpq
end

