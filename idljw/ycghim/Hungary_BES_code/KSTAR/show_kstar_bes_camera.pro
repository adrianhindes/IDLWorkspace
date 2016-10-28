;+
;NAME:
; SHOW_KSTAR_BES_CAMERA
;
;Author: Sandor Zoletnik (sandor.zoletnik@wigner.mta.hu)
;
;PURPOSE:
;Plots the CMOS camera image in the KSTAR BES measurement
;
;CATEGORY:
;Plotting
;
;CALLING SEQUENCE
; show_kstar_bes_camera,shot[,time=time][,datapath=datapath][,errormess=errormess][,noplot=noplot]
;                      [,frame_times=frame_times][,frame_numbers=frame_numbers][,data_arr=data][,measurement=meas],[,waittime=waittime][,offset_frame]
;                      [,thick=thick][,charsize=charsize][,smooth=smooth_len][,median=median_width][,calib=calib]
;                      [,cutline=cutline][,cutx=cutx][,cuty=cuty]
;
;INPUTS:
; shot - Shot number
; time - The time of the frame to plot. The closest frame will be selected.
;        If a 2-element array then all frames in the time range will be plotted.
;        If not set all frames will be plotted and returned.
; frame_numbers - The frame numbers to plot (0....)
;        If a 2-element array then all frames in that range will be plotted.
;    If neither time nor frame_numbers are set all frames will be plotted and returned.
; datapath - Data directory without the shot number. If not set will be loaded from fluct_local_config.dat
; /noplot - Do not plot, just return data array
; waittime - Wait time between frame in sec
; scale - Scale factor. If not set all images will be scaled between min and max.
;         If set data will be multiplied by this.
; offset_frame - The offset frame number (0...) this will be subtracted as offset
;                -1 to avoid offset subtraction
; smooth - Smooth in pixels
; median - Median filter, width in pixels
; thick - Line thickness  (default: 1)
; charsize - Character size (default: 1)
; mpeg_filename - If set program will generate and MPEG movie
; /calib - Use calibration measurement after shot
; cut_line - An array of [x1,y1,x2,y2, ...] values or -1.
;           If -1 a series of point pairs will be read from the image by the mouse to create the above x,y list
;           If not -1 then cuts will be plotted along the lines
; cut_x - The length along the cut line in pixels. 2D array, first is line, second is point along line
; cut_y - The values for the cuts, as for cut_x
;
; OUTPUTS:
; errormess: '' or error message
; data: The data matrix [time,x,y] (Full measurement)
; measurement: The data array for the selected frames
; frame_times: The exposure start time of the images in sec
;-

pro show_kstar_bes_camera,shot,datapath=datapath,errormess=errormess,noplot=noplot,frame_times=frame_times,$
                          waittime=waittime,scale=scale,time=time,frame_numbers=frame_numbers,offset_frame=offset,data_arr=meas_all,measurement=meas,$
                          thick=thick,charsize=charsize,mpeg_filename=mpeg_filename,smooth=smooth_len,median=median_width,calib=calib,$
                          overcalib=overcalib, frametime=frametime, exptime=exptime, offset_sub=offset_sub, reverse_offset=reverse_offset,$
                          cut_line=cut_line,cut_x=cut_x,cut_y=cut_y

errormess = ''
default,thick,1
default,charsize,1
default,waittime,0.1
default,offset,-1

if (not defined(datapath)) then datapath=local_default('datapath')

if (defined(time) and defined(frame_numbers)) then begin
  errormess = 'Cannot set time and frame_numbers at the saem time.'
  print,errormess
  return
endif

if keyword_set(overcalib) then begin
   restore, dir_f_name(dir_f_name(datapath,i2str(shot)),i2str(shot)+'_CMOS_data_calib.sav')
   im2=reverse(reform(meas[0,*,*]),2)
endif

if (keyword_set(calib)) then begin
   restore, dir_f_name(dir_f_name(datapath,i2str(shot)),i2str(shot)+'_CMOS_data_calib.sav')
endif else begin
   if n_elements(meas_all) le 1 then begin
      restore, filename = dir_f_name(dir_f_name(datapath,i2str(shot)),i2str(shot)+'_CMOS_data.sav')
      meas_all=meas
   endif else begin
      meas=meas_all
   endelse
endelse

on_ioerror,camerr

if defined(frametime_ms) then frametime=frametime_ms
default,frametime, 535.
default, exptime, 500.
trigger_time=0
;meas = reverse(meas,3)

if (not defined(meas)) then return
xdim = (size(meas))[2]
ydim = (size(meas))[3]
nt = (size(meas))[1]
if (defined(offset)) then begin
  if (offset ge 0) then begin
    for i=0,nt-1 do begin
      if (i ne offset) then meas[i,*,*] = meas[i,*,*]-meas[offset,*,*]
    endfor
    meas[offset,*,*] = 0
  endif
endif
;frame_times = cmos_meas_times
frame_times = trigger_time+findgen(nt)*frametime[0]*1e-3

if (defined(time)) then begin
  if (n_elements(time) eq 1) then begin
    ; Select closest frame
    ind = closeind(frame_times,time[0])
  endif
  if (n_elements(time) ge 2) then begin
    ind = where((frame_times ge time[0]) and (frame_times le time[1]))
    if (ind[0] lt 0) then begin
      errormess = 'No frame in time interval'
      print,errormess
      return
    endif
  endif
endif
if (defined(frame_numbers)) then begin
  if (n_elements(frame_numbers eq 1)) then begin
    ind = frame_numbers
  endif else begin
    ind = indgen(frame_numbers[1]-frame_numbers[0]+1)+frame_numbers[0]
  endelse
endif
if (defined(ind)) then begin
  if ((min(ind) lt 0) or (max(ind) ge nt)) then begin
    errormess = 'Requested frame range out of measurement.'
    print,errormess
    return
  endif
endif
if (defined(ind)) then begin
  meas = meas[ind,*,*]
  nt = n_elements(ind)
  frame_times = frame_times[ind]
  startframe = ind[0]
endif else begin
  startframe = 0
endelse
if (keyword_set(noplot)) then return

if (defined(mpeg_filename)) then begin
  mpeg_id=mpeg_open([!d.x_vsize,!d.y_vsize],filename=mpeg_filename,quality=100)
endif

loadct,0
for i=0,nt-1 do begin
  im = float(reform(meas[i,*,*]))
  im = reverse(im,2)
  if keyword_set(offset_sub) then begin
     if i gt 1 then begin
        ind1=i/2*2
        ind2=i/2*2-1
        im = float(reform(meas[ind1,*,*]))-float(reform(meas[ind2,*,*]))
        if keyword_set(reverse_offset) then begin
           im=im*(-1)
        endif
     endif else begin
        im = float(reform(meas[i,*,*]))
     endelse
  endif else begin
     im = float(reform(meas[i,*,*]))
  endelse
  im = reverse(im,2)
  maxrange_x =[0,xdim-1]
  maxrange_y = [0,ydim-1]
  if (defined(median_width)) then begin
    im = median(im,median_width)
    maxrange_x = [median_width/2,xdim-1-median_width/2]
    maxrange_y = [median_width/2,ydim-1-median_width/2]
  endif
  if (defined(smooth_len)) then im = smooth(im,smooth_len,/edge_truncate)
  immax = max(im[maxrange_x[0]:maxrange_x[1],maxrange_y[0]:maxrange_y[1]])
  immin = min(im[maxrange_x[0]:maxrange_x[1],maxrange_y[0]:maxrange_y[1]])
  im_orig = im
  if (not defined(scale)) then begin
    im = (im-immin)/(immax-immin)*255
  endif else begin
    im = im*float(scale)
  endelse
  im = (im >0) < 255

  plot,[0,1],/iso,/nodata,xrange=[0,xdim-1],xstyle=1,yrange=[0,ydim-1],ystyle=1,title=i2str(shot)+' Frame: '+i2str(startframe+i)+' Time:'+string(frame_times[i],format='(F7.3)')+$
      ' [s] Max:'+string(immax,format='(I4)'),$
      thick=thick,charthick=thick,xthick=thick,ythick=thick,charsize=charsize,yticklen=-1*!p.ticklen,xticklen=-1*!p.ticklen, noerase=noerase,pos=[0.15,0.15,0.7,0.9]
  if keyword_set(overcalib) then im=(im+im2)/(max(im+im2)/255)
  otv,im
  if (defined(cut_line)) then begin
    if (cut_line[0] lt 0) then begin
      print,'Click on the start and end point of a lines. Click with the right button if no more lines.'
      digxyadd,xx,yy,/data
      if (n_elements(xx) gt 1) then begin
        ncut = n_elements(xx)/2
        cut_line = fltarr(ncut*4)
        ind = lindgen(ncut*2)
        cut_line[ind*2] = xx[ind]
        cut_line[ind*2+1] = yy[ind]
      endif
    endif
    ncut = n_elements(cut_line)/4
    cut_x = fltarr(ncut,xdim)-1
    cut_y = fltarr(ncut,xdim)
    maxpix = 0
    for ic=0,ncut-1 do begin
      xx = [cut_line[ic*4],cut_line[ic*4+2]]
      yy = [cut_line[ic*4+1],cut_line[ic*4+3]]
      npix = max(abs([xx[1]-xx[0],yy[1]-yy[0]]))
      if (npix gt maxpix) then maxpix = npix
      xc = findgen(npix)/(npix-1)*(xx[1]-xx[0])+xx[0]
      yc = findgen(npix)/(npix-1)*(yy[1]-yy[0])+yy[0]
      cut_x[ic,0:npix-1] = sqrt((xc-xx[0])^2 + (yc-yy[0])^2)
      cut_y[ic,0:npix-1] = reform(im_orig[xc,yc])
      oplot,xx,yy,linestyle=ic,thick=thick
    endfor
    cut_x = cut_x[*,0:maxpix-1]
    cut_y = cut_y[*,0:maxpix-1]
    yrange_cut = [0,max(cut_y)*1.05]
    plot,[0,maxpix-1],yrange_cut,/nodata,pos=[0.75,0.15,0.95,0.4],/noerase,thick=thick,charsize=charsize*0.7,xthick=thick,$
      ythick=thick,charthick=thick,xtitle='Pixel',title='Distributions along lines',xrange=[0,maxpix-1],xstyle=1,yrange=yrange_cut,ystyle=1
    for ic=0,ncut-1 do begin
      ind = where(reform(cut_x[ic,*]) ge 0)
      oplot,reform(cut_x[ic,ind]),reform(cut_y[ic,ind]),linestyle=ic,thick=thick
    endfor
  endif
  wait,waittime
  if (defined(mpeg_filename)) then begin
      rep = fix(frametime[0]/20.)
      for ii=0,rep-1 do begin
        mpeg_put,mpeg_id,window=!d.window,/order,frame=i*rep+ii
      endfor
  endif

endfor

;save and close the mpeg file
if (defined(mpeg_filename)) then begin
  mpeg_save,mpeg_id,filename=mpeg_filename
  mpeg_close,mpeg_id
endif

return

camerr:
errormess = 'Error loading camera data from file: '+filename
print,errormess
end
