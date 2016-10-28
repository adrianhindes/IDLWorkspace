pro plotss, x, y, siz, nopl=nopl,scal=scal,psym=psym,col=col
default,scal,max(siz)/4
if not keyword_set(nopl) then plot,x,y,/nodata,_extra=_extra
n=n_elements(x)
for i=0,n-1 do if siz(i)/scal gt 0.01 then plots, x(i),y(i),psym=psym,symsize=siz(i)/scal,col=col
end
