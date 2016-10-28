 pro kstar_cam_movie, shotnum=shotnum, frames=frames, ver=ver, level=level, file=file, $
    test=test, backgr=backgr ,waittime=waittime,$
    start_time=start_time,stop_time=stop_time,slice_x=slice_x,slice_y=slice_y,$
    datapath=datapath

;************************************************************
;
;   frames: The frames to show 0....  (default: all frames)
;   start_time: time of first frame to show
;   stop_time: time of last frame to show
;   slice_x: position of x slice (0...ysize-1)
;   slice_y: position of y slice (0...xsize-1)
;   waittime: time to wait between showing two frames [s] (def: 0.1sec)
;*******************************************************
default,maxlevel,4096
default,minlevel,0
default,waittime,0.1
default,datapath,local_default('datapath')

erase

;neas=read_all_cmos(shot)
;default,frames,indgen((size(meas))[1])
print,'Reading data...'
restore,dir_f_name(dir_f_name(datapath,i2str(shotnum)),i2str(shotnum)+'_CMOS_data.sav')
print,'...done'

default,frames,indgen((size(meas))[1])

if defined(backgr) then begin

for i=0, n_elements(frames)-1 do begin

meas[reform(frames[i]), *, *]=meas[reform(frames[i]), *, *]-meas[backgr, *, *]

;stop

endfor

endif


if defined(level) then begin
for i=0, n_elements(frames)-1 do begin
erase
tvscl, meas[frames[i], *, *] <level>0

xyouts,0.05, 0.95, 'shot:  '+i2str(shotnum) ,/normal, charsiz=1.3
xyouts, 0.05, 0.92, 'frame: '+i2str(frames[i]), /normal, charsiz=1.3

;exp_times = frames*0.151
;exp_times = fltarr(n-elements(frames)+0.1

exp_times=exp_info.frame.exp_time
exp_starts=exp_info.frame.exp_start


xyouts, 0.05, 0.89, 'Exp_time: '+string(exp_times[frames[i]]), /normal, charsiz=1.3
xyouts, 0.05, 0.86, 'Start_time: '+string(exp_starts[frames[i]]), /normal, charsiz=1.3

 wait, 1

   endfor

endif else begin

xsize = (size(meas))[2]
ysize = (size(meas))[3]

if (defined(start_time)) then begin
  start_frame = (where(exp_info.frame.exp_start gt start_time))[0]
  if (start_frame lt 0) then begin
    print,'No frames after start time.'
    return
  endif
endif
if (defined(stop_time)) then begin
  ind = where((exp_info.frame.exp_start lt stop_time) and (exp_info.frame.exp_start ne 0))
  if (ind[0] lt 0) then begin
    print,'No frames before stop time.'
    return
  endif
  stop_frame = ind[n_elements(ind)-1]
endif
if (defined(start_frame) and not defined(stop_frame)) then begin
  stop_frame = n_elements(exp_info.frame.exp_start)-1
endif
if (defined(start_frame) and defined(stop_frame)) then begin
  frames = lindgen(stop_frame-start_frame+1)+start_frame
endif

for i=0, n_elements(frames)-1 do begin
  erase

plot,[0,0],[0,0],/nodata,position=[0.1,0.1,0.6,0.6],$
     xrange=[-0.5,xsize-0.5],yrange=[-0.50,ysize-0.5],xstyle=1,ystyle=1,/noerase,title='Camera image'

;stop
im = reform(meas[frames[i], *, *])
otv,float(im)/max(im)*250
;  tvscl, float(((meas[frames[i], *, *]-minlevel)>0)<(maxlevel-minlevel))/(maxlevel-minlevel)*250


; EZ ITT NEM NAGYON PRAKTIKUS, JOBB LENNE EGY STRINGET CSINALNI ES A SORVALTAST !-EL INTEZNI
xyouts,0.05, 0.95, 'shot:  '+i2str(shotnum) ,/normal, charsiz=1.3
xyouts, 0.05, 0.92, 'frame: '+i2str(frames[i]), /normal, charsiz=1.3
exp_times=exp_info.frame.exp_time
exp_starts=exp_info.frame.exp_start
xyouts, 0.05, 0.89, 'Exp_time: '+string(exp_times[frames[i]]), /normal, charsiz=1.3
xyouts, 0.05, 0.86, 'Frame start time: '+string(exp_starts[frames[i]]), /normal, charsiz=1.3

default,slice_x,ysize/2
default,slice_y,xsize/2

curve = im[*,slice_x]
min = min(curve)
max = max(curve)
if max eq min then max = max+1
plot,curve,position=[0.1,0.65,0.6,0.75],/normal,/noerase,ystyle=1,$
    xstyle=1,yticks=1,yrange=[min,max],xtickname=replicate(' ',30)
xx = indgen(ysize)
curve = im[slice_y,*]
min = min(curve)
max = max(curve)
if max eq min then max = max+1
plot,curve,xx,position=[0.65,0.1,0.75,0.6],/normal,/noerase,xstyle=1,$
    ystyle=1,xticks=1,ytickname=replicate(' ',30),xrange=[min,max]


 wait, waittime

   endfor

endelse

wait, 0.1

end
