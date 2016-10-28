pro ffunc,th,par,f,pder
a=par(0)
d=par(1)
s0=par(2)
b=!pi/2
Pi=!pi
;f=s0*(0.25 + ((Cos(2*(-a + Pi/2.))*Cos(2*(a - th)))/2. - (Cos(d)*Sin(2*(-a + Pi/2.))*Sin(2*(a - th)))/2.)/2.);s0*(0.25 + ((Cos(2*a)*Cos(2*(a - th)))/2. + (Cos(d)*Sin(2*a)*Sin(2*(a - th)))/2.)/2.)

;f=s0*(0.25 + ((Cos(2*a)*Cos(2*(a - th)))/2. + $
;      (Cos(d)*Sin(2*a)*Sin(2*(a - th)))/2.)/2.)

f=s0*(0.25 + ((Cos(2*(-a + b))*Cos(2*(a - th)))/2. - $
      (Cos(d)*Sin(2*(-a + b))*Sin(2*(a - th)))/2.)/2.)
end

pro anflc,sh=sh,i0=i0
;sh=1631&i0=1
;sh=1632&i0=2
;sh=1633&i0=1
;sh=1634&i0=1
;sh=1635&i0=1
;
;sh=1636&i0=1
;sh=1637&i0=0
;sh=1638&i0=1
;sh=1639&i0=2

;sh=1640&i0=1
;sh=1641&i0=1
;sh=1642&i0=1
;sh=1643&i0=1
path='/home/cam112/prlpro/res_jh/mse_data'
dum=getimg(sh,index=0,/getinfo,info=info,pre='',path=path)
n=info.num_images
sz=info.dimensions
d=fltarr(sz(0),sz(1),n)
for i=0,n-1 do begin
    dum=getimg(sh,index=i,pre='',path=path)
    d(*,*,i)=dum
endfor
l=d(sz(0)/2,sz(1)/2,*)

plot,l,psym=-4
oplot,[i0,i0+18],l([i0,i0+18]),psym=6,col=2
oplot,!x.crange,l(i0)*[1,1],col=3
a=''&read,'',a
;wait,1
;retall

ll=l(i0:i0+17)-l(22)
th=linspace(0,170,18)*!dtor
plot,th,ll,psym=-4
a0=[45*!dtor,180*!dtor,3.5e4]

;a0=[50*!dtor,155*!dtor,3.5e4]
;a0=[50*!dtor,180*!dtor,3.5e4]
ffunc,th,a0,f
oplot,th,f,col=2
f2=curvefit(th,ll,replicate(1,n_elements(ll)),a0,s0,function_name='ffunc',/noder,fita=[1,1,1])
a0(1)=a0(1) mod !pi
a0(0)=a0(0) mod !pi
print, a0*[!radeg,!radeg,1]
print,s0*[!radeg,!radeg,1],'is error'
oplot,th,f2,col=3
save,a0,s0,file='~/tmp/demod/'+string(sh,format='(I0)')+'.sav',/verb
end

pro plotall,sigv,oplot=oplot,qty=iqty,col=col,xtitle=xtitle,ytitle=ytitle,yrange=yrange,noerase=noerase,position=position,set=set
tab0=transpose($
    [[1644,-1,2.5],$
     [1645, 1,2.5],$
     [1646,-1,1.25],$
     [1647,+1,1.25],$
     [1648,-1,0.613],$
     [1649,+1,0.613],$
     [1652,-1,10],$
     [1651,+1,10]])
tab1=transpose($
    [[1634,+1,24],$
     [1635,-1,24],$
     [1637,+1,36],$
     [1636,-1,36]])
;     [1639,+1,36],$
;     [1638,-1,36]])

;default,set,1
if set eq 1 then tab=tab1
if set eq 0 then tab=tab0
sh=tab(*,0)
sig=tab(*,1)
volt=tab(*,2)*(set eq 0 ? 2 : 1)
idx=where(sig eq sigv)
idx=idx(sort(volt(idx)))
sh=sh(idx)
volt=volt(idx)
nsh=n_elements(sh)

idx2=where(tab(*,1) eq -sigv)
idx2=idx2(sort(tab(idx2,2)))
sh2=tab(idx2,0)
par=fltarr(nsh)
for i=0,nsh-1 do begin
    restore,file='~/tmp/demod/'+string(sh(i),format='(I0)')+'.sav',/verb
    if iqty eq 0 or iqty eq 1 then par(i)=a0(iqty)*!radeg
    if iqty eq 2 or iqty eq 3 then tmp=a0(0)*!radeg

    if iqty le 1 then continue
    restore,file='~/tmp/demod/'+string(sh2(i),format='(I0)')+'.sav',/verb
    if iqty eq 2 or iqty eq 3 then tmp2=a0(0)*!radeg
    if iqty eq 2 then par(i)=(tmp+tmp2)/2
    if iqty eq 3 then par(i)=(-tmp2+tmp)
    
endfor

if keyword_set(oplot) then oplot,volt,par,psym=-4,col=col else plot,volt,par,psym=-4,/yno,xtitle=xtitle,ytitle=ytitle,yrange=yrange,noerase=noerase,position=position

end

pro mkps,set=set
xtitle=(set eq 0 ? 'pp voltage' : 'temperature degC')

fname=(set eq 0 ? '~/rsphy/vscan.eps' : '~/rsphy/tscan.eps')
mkfig,fname,xsize=18,ysize=12

pos=posarr(2,2,0,cnx=0.1,cny=0.1)

plotall,-1,qty=1,xtitle=xtitle,ytitle='FLC delay (deg)',pos=posarr(/curr),set=set


plotall,-1,qty=0,pos=posarr(/next),/noer,yr=[0,60],xtitle=xtitle,ytitle='FLC angles at either state',set=set
plotall,1,qty=0,/oplot,col=2,set=set


plotall,-1,qty=3,xtitle=xtitle,ytitle='FLC switch angle (deg)',pos=posarr(/next),/noer,set=set
plotall,-1,qty=2,xtitle=xtitle,ytitle='FLC central angle (deg)',pos=posarr(/next),/noer,set=set
endfig,/jp,/gs
;plotall,1,qty=0,/oplot,col=2

;plotall,-1,qty=0,xtitle='voltage',ytitle='FLC angle (deg)',yrange=[0,60]
;plotall,1,qty=0,/oplot,col=2

end

