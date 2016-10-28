pro cosfit, x, a, f

f = (1+a(0))/2 + cos(2*!pi*1/a(1)*x) * (1-a(0))/2
f = ((1+a(0))/2 + cos(2*!pi*1/a(1)*x) * (1-a(0))/2)*a(2)

;stop
end


fil1='field widening one'
fil2='calibration 1 07-2-2014'

im1=getimgnew(fil1,0,db='h')
im2=getimgnew(fil2,0,db='h')
im=im1*1. - im2*1.
stop
newdemod,im,cars,sh=fil1,db='h',/doplot,str=str,demodtype='basic',kx=kx,ky=ky,kz=kz
carsx=cars & for i=1,4 do carsx(*,*,i)*=2. / cars(*,*,0)


;fil1='calibration 19 05-2-2014'
;fil2='calibration 20 05-2-2014'
fil1='calibration 15 05-2-2014'
fil2='calibration 16 05-2-2014'

im1=getimgnew(fil1,0,db='h')
im2=getimgnew(fil2,0,db='h')
imb=im1*1. - im2*1.

newdemod,imb,carsb,sh=fil1,db='h',/doplot,str=str,demodtype='basic',kx=kx,ky=ky,kz=kz
carsbx=carsb & for i=1,4 do carsbx(*,*,i)*=2. / carsb(*,*,0)

erase
for i=1,4 do begin
imgplot,abs(carsx(*,*,i)),/cb,pos=posarr(2,4,i-1),/noer,title=string(kx(i),ky(i),kz(i),i,format='(4(G0," "))')

endfor
for i=1,4 do begin
imgplot,abs(carsbx(*,*,i)),/cb,pos=posarr(2,4,4+i-1),/noer,title=string(kx(i),ky(i),kz(i),i,format='(4(G0," "))')

endfor
stop
ex=reform(abs(kz(1:4)))
wy=reform(abs(carsbx(19,19,1:4)/carsx(19,19,1:4)))
plot,ex,wy,psym=4
weights=replicate(1,4)
weights=[1.,0,0,1]
a=[0.3,13000.,1.]
res=curvefit(ex,wy,weights,a,function_name='cosfit',/noderivative)
ex2=linspace(0,max(abs(kz)),100)
cosfit,ex2,a,wy2
oplot,ex2,wy2,col=2
end
