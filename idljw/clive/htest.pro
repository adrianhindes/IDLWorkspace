;goto,ee
sharr=['none','bottom_left','bottom_right','top_right','top_left']
sharr=['none2','64mm','44mm']
sharr2=['','6.4mm bbo delay','4.4 bbo delay']
nsh=n_elements(sharr)

base='heterodyne_'

for i=0,nsh-1 do begin
sh=base+sharr(i)
newdemod,im,cars,sh=sh,/doload,lam=529e-9,demodtype='basicsm'  
if i eq 0 then begin
    sz=size(cars,/dim)
    cars2=complexarr(sz(0),sz(1),nsh)
endif
cars2(*,*,i)=cars(*,*,1)

endfor


ee:
mkfig,'~/rsphy/ref1im.eps',xsize=14,ysize=11,font_size=10
erase

pos=posarr(2,2,0)
for i=1,2 do begin

p=atan2(cars2(*,*,i)/cars2(*,*,0))
jumpimg,p
contourn2,p*!radeg,pal=-2,zr=[-360,360],title=sharr2(i),nl=30,pos=pos,/noer
;plot,p(*,450)*!radeg,title=sharr(i),pos=pos,/noer,ytitle='deg',xtitle='x'
pos=posarr(/next)

;stop
endfor
endfig,/gs,/jp
end
