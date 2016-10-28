pro lookup_kstar2013

;load the calibration images
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

;read in KSTAR shot,pick two frames of different and demod
mdsopen,'mse_2013',172
;im=mdsvalue('.PCO_CAMERA:IMAGES')
im=mdsvalue('.MSE:CAL_IMAGES')
on=im[*,*,38]   ;positive flc state (good state)
off=im[*,*,39]  ;negative flc state
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

plot,atheta[width/2,*]
oplot,atheta[*,height/2]
stop

end