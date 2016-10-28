r=113;83;80;81
i=0

img=getimg(r,index=i)

imgplot,img


 sets={win:{type:'sg',sgmul:1.5,sgexp:4},$
       filt:{type:'hat'},$
       aoffs:60.,$
       c1offs:180,$
       c2offs:0,$
       c3offs:90,$

       fracbw:1.0,$
       pixfringe:14.1,$
;       pixfringe:10,$
       typthres:'win',$
       thres:0.1}


demodcs, img,outs, sets,/doplot,zr=[-2,1],newfac=2.,linalong=90*!dtor;,/noopl
;limg=total(img,2)
end
