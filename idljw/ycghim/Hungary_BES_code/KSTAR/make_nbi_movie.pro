pro make_NBI_movie,shot,timerange=timerange,plotrange=plotrange,waittime=waittime,thick=thick,$
    mpeg_filename=mpeg_filename,nlev=nlev, int=int, deadpix=deadpix, bgsub=bgsub, user=user,$
    xyz=xyz, dim1=dim1, channel=channel, twin=twin,shiftrate=shiftrate

default,shot,7715
restore, 'data\7715_CCD.sav'
mpeg_filename='NBI_movie.mpg'
mpeg_id=mpeg_open([640,480],filename=mpeg_filename,quality=100)
mpeg_frame_rate=25  
default,shiftrate,1
Device, Decomposed=0
loadct, 3
frame=indgen(250)
window, xsize=640, ysize=480
for i=0,n_elements(frame)-1 do begin
  
   title='shot:'+strtrim(shot,2)+' @ '+strtrim(exp_info.frame[frame[i]].exp_start,2)+'s'
   tvscl, data_arr[frame[i],*,*]<3000
   xyouts, 0.75, 0.95, title, /norm, color=255, charsize=1
   if (defined(mpeg_filename)) then begin
      im = tvrd(/order,true=1)
      mpeg_put,mpeg_id,window=!d.window,/order,frame=i
   endif
   erase
endfor

                                ;save and close the mpeg file
if (defined(mpeg_filename)) then begin
   mpeg_save,mpeg_id,filename=mpeg_filename
   mpeg_close,mpeg_id
endif

end
