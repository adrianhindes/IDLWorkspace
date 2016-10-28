pro plotm2, x,y,z,coffs=coffs,aug=aug,xrange=xrange,yrange=yrange,zrange=zrange,nplot=nplot,mmod=mmod,offch=offch,oplot=oplot,thick=thick,linesty=linesty,psym=psym,cmul=cmul,exact=exact,ctop=ctop,legsi=legsi,noleg=noleg,legtxt=legtxt,legbox=legbox,pal=pal,noright=noright,right=right,offy=offy,_extra=_extra
default,mmod,1e9
default,ctop,255
;default,coffs,32
default,pal,4
loadct,pal,bottom=32
;default,cmul,1
sz=size(z,/dim)
default,xrange,minmax(x)
idx=where( (x ge xrange(0)) and (x le xrange(1)))
if idx(0) eq -1 then return
z2=z(idx,*)
ift=where(finite(z2) eq 1)
if ift(0) eq -1 then return
rng=[min(z2(ift)),max(z2(ift))]
default,zrange,rng
default,offch,0
default,offy,0.
default,yrange,minmax(y)
default,nplot,n_elements(y)
ywant=linspace(yrange(0),yrange(1),nplot)
idx=fltarr(nplot)
for i=0,nplot-1 do begin
    dummy=min(abs(ywant(i)-y),imin)
    idx(i)=imin
endfor

if keyword_set(exact) then begin
    idx=where((y ge yrange(0)) and (y le yrange(1)))
    ywant=y(idx)
    nplot=n_elements(ywant)
;    idx=indgen(nplot)
endif

;default,cmul,(ctop-32.)/float(nplot-1)
default,cmul,1
default,coffs,1

col=coffs + ((findgen(nplot)*cmul) mod mmod)
for i=0,nplot-1 do begin
        yp=z(*,idx(i))
        xp=x

    if (i eq 0) and not keyword_set(oplot) then $
      plot,xp,yp,xrange=xrange,yr=zrange,/nodata,_extra=_extra 
    oplot,xp+offch*i,yp+offy*i,col=col(i),thick=thick,linesty=linesty,psym=psym ;,_extra=_extra
endfor

default,legsi,1.
if not keyword_set(noleg) then begin
    default,legtxt,string(y(idx),format='(G0.3)')
    legend,legtxt,textcolor=col,box=legbox,/clear,charsize=legsi,margin=0.5*legsi,spacing=legsi,right=right
end
end

