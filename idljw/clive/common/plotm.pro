pro plotm, xd,y,coffs=coffs,aug=aug,yrange=yrange,mmod=mmod,offch=offch,oplot=oplot,thick=thick,linesty=linesty,psym=psym,cmul=cmul,_extra=_extra,leg=leg,offy=offy
x=xd
if n_params() eq 1 then begin
    y=x
    nn=n_elements(y(*,0))
    x=findgen(nn)
endif
default,offy,0.

default,mmod,32
default,coffs,1
default,cmul,1
sz=size(y,/dim)
ift=where(finite(y) eq 1)
rng=[min(y(ift)),max(y(ift))]
default,yrange,rng
default,offch,0
for i=0,sz(1)-1 do begin
    if keyword_set(aug) then auggap1,y(*,i),x,yp,xp,val=!values.f_nan else begin
        yp=y(*,i)
        if size(x,/n_dim) eq 1 then xp=x else xp=x(*,i)
    endelse

    if (i eq 0) and not keyword_set(oplot) then $
      plot,xp,yp,yr=yrange,/nodata,_extra=_extra 
      oplot,xp+offch*i,yp+offy*i,col=coffs + ((i*cmul) mod mmod),thick=thick,linesty=linesty,psym=psym       ;,_extra=_extra
endfor
print,sz(1)
print,'hey'
;stop
end

