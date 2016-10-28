function load_cal_images,experiment,shot,frames_per_pos,nstates,state

mdsopen,experiment,shot

background=mdsvalue('.MSE:DARK_FRAME')*mdsvalue('PCO_CAMERA.SETTINGS.TIMING:NUM_IMAGES')/nstates
im=mdsvalue('.MSE:CAL_IMAGES')
sz=size(im)
width=sz[1]
height=sz[2]
stops=sz[3]/frames_per_pos


frames=fltarr(width,height,stops)
for i=0, stops-1 do begin
   j=0
   while (j lt frames_per_pos/nstates) do begin
      frames[*,*,i]  =frames[*,*,i]+im[*,*,frames_per_pos*i+ state + j*nstates]
      j++
   endwhile
endfor
return,frames
end