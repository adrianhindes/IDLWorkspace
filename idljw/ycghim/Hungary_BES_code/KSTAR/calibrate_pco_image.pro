pro calibrate_pco_image, ps=ps, shot=shot, apdpos=apdpos

;*************************************************
;************** Calibrate pco image **************
;*************************************************
;* This software is usable for spatial calibration
;* for the shots where the mirror_position exactly
;* defines the measurement position. It is not
;* usable for those shots, where the front mirror
;* or the mirror in the tower was moved.
;*************************************************
;* INPUTs:
;*          shot: shotnumber
;*          ps:   plot the mirror position -
;*                radial position into ps file
;* OUTPUTs:
;*          None, it creates cal/mirror_calibration_db.sav
;*          which containes 

default, shot, 7104
default, apdpos, 30000
if keyword_set(ps) then hardon, /color

cd, 'D:\KFKI\Measurements\KSTAR\Measurement'

  
if shot lt 7000 then begin
  print, 'Please use getcal_kstar_spat function for spatial calibration'
  return
endif
if shot gt 7190 and shot lt 7660 then begin
  print, 'Please use calibrate_pco_image_one.sav'
  return
endif


  ;top,bottom,left,rightif shot
if shot ge 7000 and shot lt 7190 then begin
  ;These coordinates are from shot 7109
  ;fourcord=[[xt,xb,xl,xr],[yt,yb,yl,yr]]
  fourcord_b=[[439,458,411,486],[274,349,321,302]] 
  fourcord_m=[[403,421,374,449],[126,201,174,155]]
endif
if shot ge 7661 then begin
  ;These coordinates are from shot 7685
  ;fourcord=[[xt,xb,xl,xr],[yt,yb,yl,yr]]
  fourcord_b=[[451,472,428,496],[318,387,364,341]]
  fourcord_m=[[410,431,386,454],[186,255,231,208]]
endif
    oa_pic=[320,240] ; The picture is 640x480
 
;direction 1: middle, direction 2: lower
calc_nbi_oa, shot=shot, oa_nbi=oa_nbi_m, oa_pic=oa_pic, direction=1, fourcord=fourcord_m
calc_nbi_oa, shot=shot, oa_nbi=oa_nbi_b, oa_pic=oa_pic, direction=2, fourcord=fourcord_b

oa_nbi=(oa_nbi_m+oa_nbi_b)/2
stop
;STEPS:

;Read the calibration image on the screen
;
if shot gt 7661 then begin
  if apdpos eq 30000 then begin
    restore, dir_f_name('cal','calib_database023.sav')
    filename=dir_f_name('cal','ccd_apd_pic_corn_7685.sav')
  endif
  if apdpos eq 12150 then begin
    restore, dir_f_name('cal','calib_database027.sav')
    filename=dir_f_name('cal','ccd_apd_pic_corn_7685_vert.sav')
  endif
  if apdpos ne 12150 and apdpos ne 30000 then begin
    print, 'Spatial calibration is only available for apdpos 12150 and 30000.'
    return
  endif
endif else begin
  restore, dir_f_name('cal','calib_installed_database000.sav')
  filename=dir_f_name('cal','ccd_apd_pic_corn_7109.sav')
endelse

ind=where(database.apd_position eq apdpos)
n=n_elements(ind)

;Read the four corners of the APDCAM detector frame
if file_test(filename) then begin
  restore, filename
endif else begin
  corner_pos=dblarr(n,4,2)
  
Window,1,XSIZE=640,YSIZE=480
  for i=0,n-1 do begin
    if shot lt 7700 then begin
      if i lt n/2 then begin
        tvscl, database[ind[i]].image-database[n-1].image, /device
      endif else begin
        tvscl, database[ind[i]].image-database[0].image, /device
      endelse
    endif else begin
      tvscl, database[ind[i]].image-database[16].image, /device
    endelse
    print, 'Click on the inner corner of the APD in the following order (bl,br,tr,tl)'
    for j=0,3 do begin
      cursor, x, y, /down, /device
      corner_pos[i,j,0]=x
      corner_pos[i,j,1]=y
      print, x, y
    endfor
  endfor
  mirror_position=database[ind].mirror_position
  apd_position=database[ind].apd_position
  save, corner_pos, mirror_position, apd_position, filename=filename
endelse

corner_pos[*,*,0]=640-corner_pos[*,*,0]
corner_pos[*,*,1]=corner_pos[*,*,1]

;Fit on the APDCAM frame's inner corner
error=dblarr(11)
error[*]=0.01
param=dblarr(4,2,2)
;Calculate for all the possible mirror positions
n=80
mirror_position2=lindgen(n)*1000
corner_pos2=dblarr(n,4,2)

for i=0,3 do begin
  for j=0,1 do begin
    param[i,j,*]=mpfitfun('linear_fit', mirror_position[4:14], reform(corner_pos[4:14,i,j]), error,double([-25,2000]))
    corner_pos[*,i,j]=param[i,j,0]+param[i,j,1]*mirror_position
    corner_pos2[*,i,j]=param[i,j,0]+param[i,j,1]*mirror_position2
  endfor  
endfor

corner_pos=corner_pos2
mirror_position=mirror_position2

;Calculate the geometry of the detector
spatcor_d = dblarr(n,4,8,3)
pixcor_d = dblarr(n,4,8,2)     

for k=0,n-1 do begin
;calculate the spatial coordinates from the last calculation for each pixel on the apd array
 
    ;the pixel coordinates of the detector array
  
  hps = 0.8   ;half size of the pixel
  gap = 2.3   ;gap between pixels
  gapm = 2.6    ;gap in the middle
  arrl = 17.7 ;length of the pixel array horizontally
  arrh = 8.8  ;height of the pixel array vertically BTW: gap+hps*2+gapm=4.9

    ;these are the coordinates of the frame of the APD detector

    ;         ------------------------
    ;         |[i,3,*]        [i,2,*]|
    ;         |                      |
    ;         ------------------------         <--- APD array
    ;         |                      |
    ;         |[i,0,*]        [i,1,*]|
    ;         ------------------------

  ;First the points are calculated for the frame lines, then the corresponding coordinates determines lines, which determines one
  ;intersection point which is either the center of the pixel or one of its corner
  ;first the centers are calculated then the corners
  frame_tb=dblarr(8,2,2) ;[*,0,*] :bottom ,[*,1,*] :top 
  frame_lr=dblarr(4,2,2) ;[*,0,*] :left ,[*,1,*]   :right
  
  for i=0,7 do begin
    dist=(hps+i*gap)/(2*hps+7*gap)
    frame_tb[i,0,0]=(corner_pos[k,1,0]-corner_pos[k,0,0])*dist+corner_pos[k,0,0]
    frame_tb[i,0,1]=(corner_pos[k,1,1]-corner_pos[k,0,1])*dist+corner_pos[k,0,1]
    frame_tb[i,1,0]=(corner_pos[k,2,0]-corner_pos[k,3,0])*dist+corner_pos[k,3,0]
    frame_tb[i,1,1]=(corner_pos[k,2,1]-corner_pos[k,3,1])*dist+corner_pos[k,3,1]
  endfor
  for j=0,3 do begin
    if j le 1 then dist=(hps+j*gap)/(2*hps+2*gap+gapm) else dist=(hps+(j-1)*gap+gapm)/(2*hps+2*gap+gapm)
    frame_lr[j,0,0]=(corner_pos[k,3,0]-corner_pos[k,0,0])*dist+corner_pos[k,0,0]
    frame_lr[j,0,1]=(corner_pos[k,3,1]-corner_pos[k,0,1])*dist+corner_pos[k,0,1]
    frame_lr[j,1,0]=(corner_pos[k,2,0]-corner_pos[k,1,0])*dist+corner_pos[k,1,0]
    frame_lr[j,1,1]=(corner_pos[k,2,1]-corner_pos[k,1,1])*dist+corner_pos[k,1,1]
  endfor

  ;the following lines calculates the intersections of lines from the upper calculated points
  for i=0,7 do begin
    for j=0,3 do begin
      x1=frame_tb[i,0,0]
      y1=frame_tb[i,0,1]
      x2=frame_tb[i,1,0]
      y2=frame_tb[i,1,1]
      
      x3=frame_lr[j,0,0]
      y3=frame_lr[j,0,1]
      x4=frame_lr[j,1,0]
      y4=frame_lr[j,1,1]
      ;the following is from Mathworld: http://mathworld.wolfram.com/Line-LineIntersection.html
      pixcor_d[k,j,i,0]=determ([[determ([[x1,y1],[x2,y2]]),x1-x2],[determ([[x3,y3],[x4,y4]]),x3-x4]])/$
                      determ([[x1-x2,y1-y2],[x3-x4,y3-y4]])
      pixcor_d[k,j,i,1]=determ([[determ([[x1,y1],[x2,y2]]),y1-y2],[determ([[x3,y3],[x4,y4]]),y3-y4]])/$
                      determ([[x1-x2,y1-y2],[x3-x4,y3-y4]])
      calc_nbi_oa, shot=shot, oa_nbi=spatcor1, oa_pic=reform(pixcor_d[k,j,i,*]), direction=1, fourcord=fourcord_m
      calc_nbi_oa, shot=shot, oa_nbi=spatcor2, oa_pic=reform(pixcor_d[k,j,i,*]), direction=2, fourcord=fourcord_b
      spatcor_d[k,j,7-i,*]=xyztocyl((spatcor1+spatcor2)/2)
    endfor
  endfor
endfor

radial_position=dblarr(n)
oa_position=dblarr(n,3)             
for i=0,n-1 do begin
  radial_position[i]=(spatcor_d[i,1,3,0]+spatcor_d[i,1,4,0]+spatcor_d[i,2,3,0]+spatcor_d[i,2,4,0])/4
  oa_position[i,*]=reform((spatcor_d[i,1,3,*]+spatcor_d[i,1,4,*]+spatcor_d[i,2,3,*]+spatcor_d[i,2,4,*])/4)
endfor             

!p.font=2
      
plot, mirror_position, radial_position, xtitle='Mirror position [step]', ytitle='Radial position [mm]', $
      xcharsize=1.5, ycharsize=1.5, thick=2, position=[0.05,0.05,0.95,0.95], ystyle=1, xstyle=1
error=dblarr(11)
error[*]=0.01
p=mpfitfun('linear_fit', mirror_position[4:14], radial_position[4:14], error,double([-25,2000]))
print, p
 
description={spatcor_d:       'Spatial coordinates of each detector pixel: [mirror_pos,ch_v,ch_h,[R,z,phi]]',$
             corner_position: 'Inner corner of the APD array: [mirror_pos,[],[pix_x,pix_y]]',$
             pixcor_d:        'Pixel coordinates of each detector:[mirror_pos,ch_v,ch_h,[pix_x,pix_y]]',$
             mirror_position: 'Position of the mirror in stepmotor steps',$
             radial_position: 'Radial position of the optical axis [mirror_position]',$
             oa_position:     'Spatial position of the optical axis [mirror_position,[R,z,phi]]',$
             p:               'Fitting coefficients, R=p[0]+m*p[1] where m is the mirror position'}
             
if shot gt 7661 then begin
  filename=dir_f_name('cal','mirror_calibration_db_7685.sav')
endif else begin
  filename=dir_f_name('cal','mirror_calibration_db_7109.sav')
endelse

if not file_test(filename) then begin
mirror_db={apdpos:long(30000),spatcor_d:spatcor_d, pixcor_d:pixcor_d, corner_pos:corner_pos,$
           mirror_position:mirror_position, radial_position:radial_position, oa_position:oa_position,$
           description:description,p:param}
           mirror_db=replicate(mirror_db,2)
endif else begin
  restore, filename
endelse

if apdpos eq 30000 then begin
  mirror_db[0].apdpos=apdpos  
  mirror_db[0].spatcor_d=spatcor_d
  mirror_db[0].pixcor_d=pixcor_d
  mirror_db[0].corner_pos=corner_pos
  mirror_db[0].mirror_position=mirror_position
  mirror_db[0].radial_position=radial_position
  mirror_db[0].oa_position=oa_position
  mirror_db[0].description=description
  mirror_db[0].p=param
endif
if apdpos eq 12150 then begin
  mirror_db[1].apdpos=apdpos 
  mirror_db[1].spatcor_d=spatcor_d
  mirror_db[1].pixcor_d=pixcor_d
  mirror_db[1].corner_pos=corner_pos
  mirror_db[1].mirror_position=mirror_position
  mirror_db[1].radial_position=radial_position
  mirror_db[1].oa_position=oa_position
  mirror_db[1].description=description
  mirror_db[1].p=param
endif
       
save, mirror_db, filename=filename
    
      
if keyword_set(ps) then hardfile, dir_f_name('plots','spat_cal_plot_2012.ps')
stop
;for k=0,15 do begin
;  image=database[ind[k]].image
;  m=mean(image)
;  for i=1,638 do begin
;    for j=1,478 do begin
;      if image[i,j] gt 5*m then begin
;        image[i,j]=(image[i-1,j]+image[i+1,j]+image[i,j-1]+image[i,j+1]+image[i-1,j-1]+image[i-1,j+1]+image[i+1,j-1]+image[i+1,j+1])/8.
;      endif
;    endfor
;  endfor
;  database[ind[k]].image=image
;endfor
;stop
;Calculate the calibration positions with calc_nbi_oa

end