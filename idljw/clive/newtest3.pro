r=79
i=0

img=getimg(r,index=i)

;imgplot,img

p0=14.1
c3o=0.
 sets={win:{type:'sg',sgmul:1.5,sgexp:4},$
       filt:{type:'hat'},$
       aoffs:60.,$
       c1offs:180,$
       c2offs:0,$
       c3offs:c3o,$

       fracbw:1.0,$
       pixfringe:p0,$

       typthres:'win',$
       thres:0.1}


;demodcs, img,outs, sets,/doplot,zr=[-2,1],newfac=1.;,linalong=-45*!dtor;,/noopl
;sets.pixfinge
       h1=0. & h2=-2             ;-2.
;sets.
pff=sqrt(h1^2 + h2^2)
dc3o=atan(h2,h1)*!radeg
sets.c3offs=c3o+dc3o
sets.pixfringe=p0/pff
demodcs, img,outs, sets,/doplot,zr=[-2,1],newfac=1.,linalong=!values.f_nan;-45*!dtor;,/noopl
;limg=total(img,2)
end
