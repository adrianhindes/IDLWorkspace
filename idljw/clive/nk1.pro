



doplot=1


sets1={win:{type:'sg',sgmul:1.5,sgexp:4},$
      filt:{type:'sg',sgexp:2,sgmul:1.},$
      aoffs:-75+22.5+1.,$   
      c1offs:-12,$
        c2offs:12,$
        c3offs: 0.,$
        fracbw:0.4,$
        pixfringe:5.4,$        
        typthres:'data',$
        thres:0.1}             

sets1b={win:{type:'sg',sgmul:1.5,sgexp:4},$
      filt:{type:'sg',sgexp:2,sgmul:1.},$
      aoffs:-75+22.5+1.,$   
      c1offs:-12,$
        c2offs:12,$
        c3offs: 0.,$
        fracbw:0.4,$
        pixfringe:5.4*105/50.,$        
        typthres:'win',$
        thres:0.1}             

sets2={win:{type:'sg',sgmul:1.5,sgexp:4},$
      filt:{type:'sg',sgexp:2,sgmul:1.},$
      aoffs:-75+22.5+20.,$   
      c1offs:-12,$
        c2offs:12,$
        c3offs: 0.,$
        fracbw:0.4,$
       pixfringe:11.02,$        
        typthres:'win',$
        thres:0.1}             


r=0
;pre='Cal_09102012_1_sumd' & sets=sets1&sm=1
pre='edge_cal_sumd' & sets=sets1b&sm=2
;pre='run148_sumd' & sets=sets2&sm=1

i=0
nimg=1

img=1.*getimg(0,pre=pre,/nonum,index=0,sm=sm)/16


demodcs, img,outs, sets,doplot=doplot,zr=[-2,1],newfac=0.6*2 ,save={txt:pre,shot:r,ix:(i)},downsamp=sets.pixfringe,override=doplot eq 1,rfac=1.16,r5fac=0.6,/dofifth,linalong=1 ;,linalong=45*!dtor;,/noopl
;limg=total(img,2)
    
    if i eq 0 then begin
        outsr=outs
        sz=size(outs.c1,/dim)
        ph1s=fltarr(sz(0),sz(1),nimg)
        ph2s=ph1s
        ph3s=ph1s
        ph5s=ph1s
        a1s=fltarr(sz(0),sz(1),nimg)
        a2s=a1s
        a3s=a1s
        a5s=a1s
        
        outss=replicate(outs,nimg)
;        continue
    endif
    outss(i)=outs

    ph1=atan2(outs.c1/outsr.c1)
    ph2=atan2(outs.c2/outsr.c2)
    ph3=atan2(outs.c3/outsr.c3)
    ph5=atan2(outs.c5/outsr.c5)

    a1=abs(outs.c1)/abs(outs.c4)
    a2=abs(outs.c2)/abs(outs.c4)
    a3=abs(outs.c3)/abs(outs.c4)
    a5=abs(outs.c5)/abs(outs.c4)

    ph1s(*,*,i)=ph1
    ph2s(*,*,i)=ph2
    ph3s(*,*,i)=ph3
    ph5s(*,*,i)=ph5

    a1s(*,*,i)=a1
    a2s(*,*,i)=a2
    a3s(*,*,i)=a3
    a5s(*,*,i)=a5


mkfig,'~/'+pre+'.eps',xsize=10,ysize=8,font_size=9
pos=posarr(2,2,0)
imgplot,a1s,pos=posarr(/curr),/cb,title='sumordiff'
imgplot,a2s,pos=posarr(/next),/cb,title='difforsum',/noer
imgplot,a3s,pos=posarr(/next),/cb,title='5mm',/noer
imgplot,a5s,pos=posarr(/next),/cb,title='3mm',/noer
xyouts,0.5,0.95,pre,ali=0.5,/norm
endfig,/gs,/jp


end

