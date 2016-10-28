pro gaussofp,x,a,f,pder
fa=a(0)*gaussof(x,529.1,a(1),a(2))+a(3)
;f=fa
dl=abs(x(1)-x(0))
nsm=0.128/dl
f=smooth(fa,nsm)
;stop
end

function gaussof,lam,l0,vrot,ti



echarge=1.6e-19
mi=12*1.67262158e-27;carbon
clight=3e8

vth=sqrt(2 * echarge * ti/mi)/clight
scal=16e4/clight

vel=(lam-l0)/l0

val=exp(-(vel-vrot/clight)^2 / vth^2) / (vth/scal)
return,val
end

rarr=[2000,2100,2200,2250]
n=n_elements(rarr)
apar=fltarr(4,n)
ppar=apar

act=fltarr(n)
pas=fltarr(n)
off=fltarr(n)
for i=0,n-1 do begin
fn='~/rsphy/7266_T5355ms_R'+string(rarr(i),format='(I0)')+'mm.txt'
dat=(read_ascii(fn,data_start=0)).(0)
;mkfig,'~/fit1.eps',xsize=14,ysize=10,font_size=9
if i eq 0 then plot,dat(0,*),dat(4,*) else oplot,dat(0,*),dat(4,*),col=i+1
continue
plot,dat(0,*),dat(1,*)/dat(4,*)
oplot,dat(0,*),dat(2,*)/dat(4,*),col=2



;cursor,dx1,dy,/down
;cursor,dx2,dy,/down
dx1=528.65
dx2=529.97
ia=value_locate(dat(0,*),dx1)
ib=value_locate(dat(0,*),dx2)

actf=dat(1,ib:ia)/dat(4,ib:ia)
pasf=dat(2,ib:ia)/dat(4,ib:ia)
nn=n_elements(actf)
offs=min(pasf)
pasf2=pasf
actf2=actf
pasf-=offs
actf-=offs
;plot,actf
;oplot,pasf
acts=total(actf);/nn
pass=total(pasf);/nn
act(i)=acts
pas(i)=pass
dl=abs(dat(0,2) - dat(0,1))
nwid = 1.5 / dl ; imagine it is 1.5nm wide

off(i)=offs* nwid
lamf=dat(0,ib:ia)
a=[offs,50e3,500,offs]
;gaussofp,lamf,a,tmp
;oplot,lamf,tmp,col=3
lamf=reform(lamf)
pasf=reform(pasf)
dum=curvefit2(lamf,pasf2,lamf*0+1.,a,function_name='gaussofp',noderivative=1)
print,a
ppar(*,i)=a
oplot,lamf,dum,col=2
stop
dif2=actf2-pasf2
oplot,dat(0,*),(dat(1,*)-dat(2,*))/dat(4,*),col=3
a=[offs,50e3,1000,offs]
if i ge 2 then a=[offs*5,50e3,1000,offs]
dum=curvefit(lamf,dif2,lamf*0+1.,a,function_name='gaussofp',noderivative=1)
print,a
apar(*,i)=a
oplot,lamf,dum,col=3
endfig,/gs,/jp
;stop
endfor
stop
mkfig,'~/gpars.eps',xsize=14,ysize=9,font_size=9
sm=(act+pas+off)
plot,rarr,act/sm,pos=posarr(2,1,0),title='fractions vs r'
oplot,rarr,pas/sm,col=2
oplot,rarr,off/sm,col=3
legend,['active','passive gaussian','passive offset'],textcol=[1,2,3],box=0

plot,rarr,apar(2,*),pos=posarr(/next),/noer,title='temps vs r'
oplot,rarr,ppar(2,*),col=2
endfig,/gs,/jp
end

