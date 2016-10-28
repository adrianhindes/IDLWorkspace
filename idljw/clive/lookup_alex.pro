pro lookup_kstar2013

;load the calibration images (for linear polarisation)
on=load_cal_images('mse_2013',172,4,2,0)
off=load_cal_images('mse_2013',172,4,2,1)
sz=size(on)
width=sz[1]
height=sz[2]
stops=19

;input linear polarisation orientation
offset=0
theta=-18+findgen(19)*2+offset

;read in phase differences and bin
demod2state,on,off,phase,width,height,stops
height_bin=4
width_bin=4
ptheta=rebin(phase,width/width_bin,height/height_bin,stops)

;read in KSTAR shot,pick two frames of different FLC states and demod
tdms_get_image,data=background,ifr=0,path='C:\Data\mse_2013_data\',file='MSE_2013_9039_Record.tdms',nx=2560,ny=2160,nfr=260
tdms_get_image,data=on,ifr=44,path='C:\Data\mse_2013_data\',file='MSE_2013_9039_Record.tdms',nx=2560,ny=2160,nfr=260   ;positive flc state (good state)
tdms_get_image,data=off,ifr=45,path='C:\Data\mse_2013_data\',file='MSE_2013_9039_Record.tdms',nx=2560,ny=2160,nfr=260  ;negative flc state
on=on-background
off=off-background
sz=size(on)
width2=sz[1]
height2=sz[2]
demod2state,on,off,phase,width2,height2,1
delvar,im

;lookup
atheta=fltarr(width2,height2)
for j=0, width/width_bin-1 do begin
   for k=0, height/height_bin-1 do begin 
      for m=0, width_bin*width2/width-1 do begin
         for n=0, height_bin*height2/height-1 do begin
            atheta[j*width_bin*width2/width+m,k*height_bin*height2/height+n]=  interpol(theta,ptheta[j,k,*],phase[j*width_bin*width2/width+m,k*height_bin*height2/height+n])
         endfor
      endfor
   endfor
endfor

im=image(atheta<10>(-14),rgb_table=15,axis_style=1,title='Polarisation Orientation',xtitle='x-pixel',ytitle='y-pixel',position=[0.12,0,0.8,1.0])
cb=colorbar(target=im,title='Polarisation angle (deg)',orientation=1,position=[0.94,0.1,0.97,0.9],border_on=1)
;im.Save, "image.png",/TRANSPARENT

;pl=plot(atheta[*,500],yrange=[-6,10],ytitle='polarisation angle (deg)',xtitle='x-pixel number (ypixel=500)')
;p1.Save, "image.png",/TRANSPARENT
stop
end
