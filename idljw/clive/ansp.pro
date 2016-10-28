pro getd, sh, davg
nimg=16
for i=0,nimg-1 do begin
    d=getimg(sh,sm=1,index=i)
    if i eq 0 then begin
        sz=size(d,/dim)
        ds=fltarr(sz(0),sz(1),nimg)
    endif
    ds(*,*,i)=d
endfor
davg=totaldim(ds,[0,0,1])/nimg
end

;oto,af
sh=1616;1623;1616
shr=1617;1626;1617

getd,sh,d1
getd,shr,d0
af:

img=d1-d0

sm=4
pixfringe=6.0*5.3/5 * 4/sm / sqrt(2) * 0.96
rot=0
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

doplot=1

demodcs, img,outs, sets,doplot=doplot,zr=[-2,1],newfac=0.6 ,save={txt:'',shot:sh,ix:0},override=doplot eq 1,plotwin=0;,downsamp=sets.pixfringe

end
