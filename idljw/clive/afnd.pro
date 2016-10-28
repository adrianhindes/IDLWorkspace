d1=1.
;n=5&d2=linspace(0.25,1.75,n)
;n=600&d2=linspace(0.1,3*2,n)
;n=2
;d2=[.75,.76]

n=10
d2=linspace(1,10,n)
vdes=[.5,1.5,2.5,3.5]
cc=fltarr(n)
for i=0,n-1 do begin
vec=abs([d1,d2(i),d1+d2(i),d1-d2(i)])
vec=vec(sort(vec))
vec=vec/vec(0)/2
print,vec
if i eq 0 then plot,vec,/nodata,yr=[0,6] else oplot,vec,col=i+1
cc(i)=total((vec-vdes)^2)
endfor

oplot,vdes,linesty=1
legend,string(d2),textcol=indgen(n)+1,box=0,/bottom,/right
dum=min(cc,imin)
print,d2(imin)
i=imin
vec=abs([d1,d2(i),d1+d2(i),d1-d2(i)])
vec=vec(sort(vec))
vec=vec/vec(0)/2
print,vec

end
