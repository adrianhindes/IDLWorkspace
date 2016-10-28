;@getptsnew
;goto,af

;goto,ee

;newdemod,img,cars,/doload,/doplot,sh=sh,ifr=ifr,demodtype=demodtype
sh=9243
ifr=frameoftime(sh,0.34)&only2=1&demodtype='sm32013mse';'basic2013mse'
newdemodflclt,sh, ifr,dopc=dopc1,angt=ang1,eps=eps1,ix=ix2,iy=iy2,pp=p,str=str,only2=only2,cars=cars1,istata=istata1,demodtype=demodtype,/noid2,/lut

;tarr=0.5 + 0.4 * findgen(fix(5.5/.4))
tarr=0.5 + 0.2 * findgen(fix(5.5/.2))
ix=where(setcompl(indgen(27),[1,6])) & tarr=tarr(ix)
nt=n_elements(tarr)
sh=9242
;goto,ee
for i=0,nt-1 do begin

   ifr=frameoftime(sh,tarr(i))&only1=1&only2=0&demodtype='sm32013mse';'basic2013mse'
   newdemodflclt,sh, ifr,dopc=dopc1,angt=ang1b,eps=eps1b,ix=ix2,iy=iy2,pp=p,str=str,only2=only2,only1=only1,cars=cars1b,istata=istata1b,demodtype=demodtype,/noid2,/lut
   
   if i eq 0 then begin
      sz=size(ang1b,/dim)
      angs=fltarr(sz(0),sz(1),nt)
   endif

   imgplot,ang1b,/cb,title=tarr(i)
   angs(*,*,i)=ang1b
endfor

ee:
getptsnew,rarr=r,zarr=z,str=p,ix=ix2,iy=iy2,pts=pts,bin=1,rxs=rxs,rys=rys,/calca

arat=rys(*,iz0,1)/rxs(*,iz0,2)  ;tor y / z x [rad,tor,z]

iz0=value_locate(z(sz(0)/2,*),0)
r1=r(*,iz0)
z1=z(sz(0)/2,*)


;mkfig,'h:\img_'+string(sh,format='(I0)')+'.eps',xsize=25,ysize=16,font_size=9




field=2.7
offextra= 2 * (field - 3) ; for new cmapign ref is at 3T

tmp=(reform(angs(*,iz0,*)))-1.5 -offextra
for i=0,nt-1 do tmp(*,i)*=arat*(-1)


; -12)
contourn2,tmp,-r1,tarr,/cb,zr=[-10,10],pal=-2,pos=posarr(2,1,0,cny=0.1),xtitle='-Radius (cm)',ytitle='time (s)',title='Pitch angle vs Radius and time #'+string(sh,format='(I0)'),offx=1.,ztitle = 'pitch angle (deg)',xr=[-240,-160],/box
ig=indgen(5)*2

plotm,-r1,tmp(*,ig),pos=posarr(/next),/noer,xtitle='-Radius (cm)',ytitle='Pol angle (degrees)',title='Pitch angle vs R for early times',yr=[-10,10],thick=2
oplot,!x.crange,[0,0]
legend,string(tarr(ig)),linesty=replicate(0,5),col=indgen(5)+1,/right
endfig,/jp,/gs

;;contourn2,r
;        if whatplot ge 0 then begin
;            imgplot,abs(cars(*,*,whatplot)),xsty=1,ysty=1
;            contour,r,xsty=1,ysty=1,/noer,nl=10,c_lab=replicate(1,10)
;        endif


;plotm,reform(angs(*,77/2,*)),yr=[-10,10]+10

;sh=9098&ifr=frameoftime(sh,3.32)&only1=1&only2=0&demodtype='basic2013mse'
;newdemodflc,sh, ifr,dopc=dopc1,angt=ang1c,eps=eps1b,ix=ix2,iy=iy2,pp=p,str=str,only2=only2,only1=only1,cars=cars1b,istata=istata1b,demodtype=demodtype,/noid2



end
