pro cosfit, x, a, f

f = (1+a(0))/2 + cos(2*!pi*1/a(1)*x) * (1-a(0))/2
f = ((1+a(0))/2 + cos(2*!pi*1/a(1)*x) * (1-a(0))/2)*a(2)

;stop
end

pro getit, ifr, wy,ex,ph

fil1='4 careeriers one'
fil2='calibration 3 07-2-2014'

;im1=getimgnew(fil1,ifr,db='h')
;im2=getimgnew(fil2,0,db='h')
;im=im1*1. - im2*1.

simimgnew,simg,sh=fil1,db='h',lam=658e-9,svec=[1,0.5,0.5,0.];,angdeptilt=angdeptilt
im=simg

;stop

    readpatch,fil1,p,db='h';,/getflc
    p=create_struct(p,'infoflc',{stat1:[[0,0,0,0],[0,0,0,0]]})
    readdemodp,'basicfull',sd
    readcell,p.cellno,str

newdemod,im,cars,sh=fil1,db='h',str=str,p=p,sd=sd,demodtype='basicfull',kx=kx,ky=ky,kz=kz,/doplot,/noload

stop
carsx=cars & for i=1,4 do carsx(*,*,i)*=2. / abs(cars(*,*,0))
carsx(*,*,0)=0.


;erase

for i=1,4 do begin
;imgplot,abs(carsx(*,*,i)),/cb,pos=posarr(2,2,i-1),/noer,title=string(kx(i),ky(i),kz(i),i,format='(4(G0," "))')
endfor
;stop

ex=reform(abs(kz(1:4)))
wy=reform(abs(carsx(19,19,1:4)))
ph=reform(atan2(carsx(19,19,1:4)))
;plot,ex,wy,psym=4
end

n=60
arr=fltarr(4,n)
ph=arr
for i=0,n-1 do begin
   getit,i,dum,ex,dum2
   arr(*,i)=dum
   ph(*,i)=dum2
   if i gt 0 then begin
      plotm,transpose(ph(*,0:i)),psym=-4,pos=posarr(1,2,0),title='phase/red'
      plotm,transpose(arr(*,0:i)),psym=-4,pos=posarr(/next),/noer,title='contrast'
      legend,string(ex,format='(I0)'),textcol=[1,2,3,4],/right,/bottom,box=0

   endif
endfor
end


