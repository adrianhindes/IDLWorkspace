
db='pfly'
sh=7021
d=getimgnew(sh,0,db=db,info=info,/getinfo)
n=info.num_images
dmax=fltarr(n)
for i=0,n-1 do begin
d=getimgnew(sh,i,db=db)
dmax(i)=max(d)

endfor
end
