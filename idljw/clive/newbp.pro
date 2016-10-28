@pr_prof2

sh=intspace(83882,83887)
nsh=n_elements(sh)
th=90-findgen(nsh)*30.
tw=[.03,.035]-0.005;*3
v=fltarr(nsh,3)
parr=['vfloat','vfloatfork','vplasma']
den=fltarr(nsh)
for i=0,nsh-1 do for j=0,2 do begin
   v(i,j)=getpar(sh(i),parr(j),tw=tw)
   den(i)=getpar(sh(i),'lint',tw=tw)
endfor
plotm,th,v,psym=-4
v2=v & v2(*,2)-=(10+70)
plotm,th,v2,psym=-4
plot,th,den
end
