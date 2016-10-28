pro demodmses,sh=sh,istart=istart,iend=iend,doplot=doplot,sm=sm,pixfringe=pixfringe,cal=cal,test=test,prer=prer,rot=rot,average=average,ibg=ibg,fracbw=fracbw

if sh le 1615 and sh ge 1604 then roi=[641,2240,259,1902]-1
default,rot,0.
default,cal,0

default,doplot,0


r=0
default,prer,'' & r=sh

mdsplus=0

img=getimg(r,pre=prer,index=0,info=info,/getinfo,fil=fil,mdsplus=mdsplus,sm=sm,flipy=mdsplus eq 0,test=test,roi=roi)
nimg=info.num_images



if mdsplus eq 0 then default,pixfringe,6.0*5.3/5 * 4/sm / sqrt(2) * 0.96
;print,'vertical binning is',info.vbin,'so pixfringe is ',pixfringe
;stop
;5.4;*105/50.
default,fracbw,0.4
sets={win:{type:'sg',sgmul:1.2,sgexp:10},$
      filt:{type:'sg',sgexp:2,sgmul:1.},$
      aoffs:-75+rot,$   
      c1offs:0,$
        c2offs:-0.,$
        c3offs: 0.,$
        fracbw:fracbw,$
        pixfringe:pixfringe,$        
        typthres:'data',$
        thres:0.1}             



default,istart,0
default,iend,nimg-1
nimg=iend-istart+1



prearr=[replicate(prer,nimg)]
rarr=[replicate(r,nimg)]
idxarr=[intspace(istart,iend)]
nonumarr=[replicate(0,nimg)]
default,sm,1
smarr=[replicate(sm,nimg)]

if keyword_set(ibg) then begin
imgbg=1.*getimg(rarr(0),pre=prearr(0),nonum=nonumarr(0),index=ibg,sm=smarr(0),mdsplus=mdsplus,rememb=1,flipy=mdsplus eq 0,test=test,roi=roi);/16
endif else imgbg=0.


for i=0,nimg-1 do begin


img=1.*getimg(rarr(i),pre=prearr(i),nonum=nonumarr(i),index=idxarr(i),sm=smarr(i),mdsplus=mdsplus,rememb=1,flipy=mdsplus eq 0,test=test,roi=roi) - imgbg;/16
print, 'got img num ',i
if keyword_set(average) then if  i eq 0 then imgs=img else imgs=imgs+img
if keyword_set(average) and i lt nimg-1 then continue
if keyword_set(average) then img=imgs / float(nimg)


   if cal eq 0 then begin
;       imgz=1.*getimg(rarr(i),pre=prearr(i),nonum=nonumarr(i),index=1,sm=smarr(i),mdsplus=mdsplus,/rememb) ;/16
;       img-=imgz
   endif

demodcs, img,outs, sets,doplot=doplot,zr=[-2,1],newfac=0.6 ,save={txt:prearr(i),shot:rarr(i),ix:idxarr(i)},override=doplot eq 1,plotwin=0;,downsamp=sets.pixfringe
;,linalong=1;,/noopl
;limg=total(img,2)
;    stop
print,i,nimg 
endfor


end




;demodmses,sh=147,istart=10,/doplot,sm=4,/test,prer='run',rot=-12.
