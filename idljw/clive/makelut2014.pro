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

sh=33&db='kcal2014'&ifr0=0

;sh=9240&ifr0=frameoftime(sh,0.34)&db='k'
;sh=9240&ifr0=frameoftime(sh,2.18)&db='k'
;sh=9249&ifr0=frameoftime(sh,0.51)&db='k'

offset=0
theta=[160D0,162.0000152587891D0,164D0,166.0000152587891D0,168D0,170D0,172.0000152587891D0,174D0,176D0,178D0,180D0,182D0,184D0,186.0000152587891D0,188D0,190.0000152587891D0,192D0,194.0000305175781D0,196.0000457763672D0,198D0,200.0000457763672D0] - 180.

;-18+findgen(19)*2+offset
nn=n_elements(theta)

ifr=ifr0&only2=1
demodtype='sm32013mse'
;demodtype='smktest2013mse'
newdemodflclt,sh, ifr,dopc=dopc1,angt=ang1,eps=eps1,ix=ix2,iy=iy2,pp=p,str=str,only2=only2,cars=cars1,istata=istata1,demodtype=demodtype,/noid2,db=db,doplot=0,plotcar=1
;print,ang1(1280/2,1080/2)


;stop
sz=size(ang1,/dim)


g=fltarr(sz(0),sz(1),nn)
ftmp=g;ang1;anga

for kk=0,nn-1 do begin
   ifr=ifr0+2*kk&only2=1
   newdemodflclt,sh, ifr,dopc=dopc1x,angt=ang1x,eps=eps1x,ix=ix2,iy=iy2,pp=p,str=str,only2=only2,cars=cars1,istata=istata1,demodtype=demodtype,/noid2,db=db

   g(*,*,kk)=ang1x
   ftmp(*,*,kk)=dopc1x
endfor

ee:

aa:

;imgplot,anga(*,*,0),/cb
f=ftmp
iz0=value_locate3(theta,0)
for i=0,sz(0)-1 do for j=0,sz(1)-1 do begin
   tmp=phs_jump(ftmp(i,j,*)*!dtor)*!radeg
   f(i,j,*)=tmp - tmp(iz0)
endfor
hplus=g+f/2
hminus=g-f/2


str={f:f,g:g,hplus:hplus,hminus:hminus,theta:theta,demodtype:demodtype}
;str={corr:corr,true:theta,meas:anga,demodtype:demodtype}

hdfsaveext,'/home/cam112/idl/lt2014_'+demodtype+'.hdf',str

end
