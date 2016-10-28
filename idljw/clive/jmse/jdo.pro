;goto,ff
e=read_kstar_intersect(9356)
d=read_interpolation_arrays(9356)

f=get_kstar_intersect(9356);shotno, bin=bin, beam=beam
g=calculate_mse_geometric_parameters(f,/ima);, geom, image_coords=image_coords


ee:
readpatch,9323,p,db='k',nfr=100
mgetptsnew,rarr=r,zarr=z,str=p,ix=ix2,iy=iy2,pts=pts,rxs=rxs,rys=rys,/calca,dobeam2=0,distback=distback,mixfactor=mixfactor ,/plane,bin=4

ff:
sz=size(f.r,/dim)
r2=congrid(r,sz(0),sz(1))/100
z2=congrid(z,sz(0),sz(1))/100

imgplot,(r2-f.r)*100. ,/cb,pal=-2
stop

imgplot,(z2-f.z)*100. ,/cb,pal=-2
stop
s2=sz(0)*sz(1)
rxsj=-[reform(g.n1,s2),reform(g.n3,s2),reform(g.n2,s2)]
rysj=[-reform(g.d1,s2),reform(g.d3,s2),reform(g.d2,s2)]
wset2,0
 plot,rxsj,pos=posarr(2,2,0),title='n'
plot,rxs,pos=posarr(/next),/noer,title='rxs'

 plot,rysj,pos=posarr(/next),title='d',/noer
plot,rys,pos=posarr(/next),/noer,title='rys'


wset2,1
erase
pos=posarr(3,2,0)
for k=0,1 do begin
if k eq 0 then begin
   a=rxs
   aj=rxsj
endif 
if k eq 1 then begin
   a=rys
   aj=rysj
endif 


for i=0,2 do begin

a0=a(*,*,i)
ajr=reform(aj,sz(0),sz(1),3)
aj0=ajr(*,*,i)
imgplot,aj0 - congrid(a0,sz(0),sz(1)),/cb,pal=-2,pos=pos,/noer,title=string(k,i)
pos=posarr(/next)

endfor
endfor

;imgplot,rxs
   
end

