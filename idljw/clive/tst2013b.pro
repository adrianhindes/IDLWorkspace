@newdemodflclt
;@getptsnew
;goto,af



;newdemod,img,cars,/doload,/doplot,sh=sh,ifr=ifr,demodtype=demodtype

;on=load_cal_images('mse_2013',172,4,2,0)
;off=load_cal_images('mse_2013',172,4,2,1)
;,frames_per_pos,nstates,state

;background=mdsvalue('.MSE:DARK_FRAME')*mdsvalue('PCO_CAMERA.SETTINGS.TIMING:NUM_IMAGES')/nstates
;im=mdsvalue('.MSE:CAL_IMAGES')
;sz=size(im)
;width=sz[1]
;height=sz[2]
;stops=sz[3]/frames_per_pos
;

;frames=fltarr(width,height,stops)
;for i=0, stops-1 do begin
;   j=0
;   while (j lt frames_per_pos/nstates) do begin
;      frames[*,*,i]  =frames[*,*,i]+im[*,*,frames_per_pos*i+ state + j*nstates]
;      j++
;   endwhile
;endfor
;return,frames
;end

;goto,ee

sh=172&db='kcal'&ifr0=1

;sh=9240&ifr0=frameoftime(sh,0.34)&db='k'
;sh=9240&ifr0=frameoftime(sh,2.18)&db='k'
;sh=9249&ifr0=frameoftime(sh,0.51)&db='k'

offset=0
theta=-18+findgen(19)*2+offset
nn=19

ifr=ifr0+4*8&only2=1&demodtype='sm32013mse'
newdemodflclt,sh, ifr,dopc=dopc1,angt=ang1,eps=eps1,ix=ix2,iy=iy2,pp=p,str=str,only2=only2,cars=cars1,istata=istata1,demodtype=demodtype,/noid2,db=db

sz=size(ang1,/dim)


g=fltarr(sz(0),sz(1),nn)
ftmp=anga

for kk=0,nn-1 do begin
   ifr=ifr0+4*kk&only2=1
   newdemodflclt,sh, ifr,dopc=dopc1x,angt=ang1x,eps=eps1x,ix=ix2,iy=iy2,pp=p,str=str,only2=only2,cars=cars1,istata=istata1,demodtype=demodtype,/noid2,db=db

   g(*,*,kk)=ang1x
   ftmp(*,*,kk)=dopc1x
endfor

ee:

aa:

;imgplot,anga(*,*,0),/cb
f=ftmp
iz0=value_locate(theta,0)
for i=0,sz(0)-1 do for j=0,sz(1)-1 do begin
   tmp=phs_jump(ftmp(i,j,*)*!dtor)*!radeg
   f(i,j,*)=tmp - tmp(iz0)
endfor
hplus=g+f/2
hminus=g-f/2


str={f:f,g:g,hplus:hplus,hminus:hminus,theta:theta,demodtype:demodtype}
;str={corr:corr,true:theta,meas:anga,demodtype:demodtype}

hdfsaveext,'/home/cam112/idl/lt_'+demodtype+'.hdf',str

end
