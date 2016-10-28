pro apd_calib, shot=shot, focal_length=focal_length, plot=plot, trial=trial,$
               pixarea=pixarea, detpos=detpos, detcorncord=detcorncord,$
               silent=silent, error=error, postscript=postscript,  xyz=xyz
  
  ;*//////////////////////////////////////////////////////////
  ;*                  APDCAM spatial calibration
  ;*//////////////////////////////////////////////////////////
  ;*This procedure takes the shot number and gives back the
  ;*radial and zeta coordinates of the line of site of the
  ;*APD detectors in the plasma.
  ;*It is important to note, that the coordinate system used by Yong Un differs from ours.
  ;*The difference is in the direction of the axes, the origo is the same. The angle difference
  ;*can be calculated from the two direction of the NBI beams, and it's value is 114.30236°.
  ;*
  ;*INPUT:
  ;*      shot: the shot number the calibration is used for
  ;*      focal_length: the focal length of the lens in front of the APDCAM
  ;*      trial: only for debugging, if real measurement data is used, then it should be 0
  ;*      plot: plot the usable area where the pixels are with the NBI's line
  ;*      postscript: write postscript file
  ;*      
  ;*OUTPUT
  ;*      detpos: [4,8,3] array of the detectors and its spatial
  ;*        coordinates in cylindrical [R,z,phi], the origo is the center of the tokamak,
  ;*        Fi=0 is the angle at the mirrors optical axis at z=0
  ;*        the coordinates are in mm
  ;*      pixarea: [4,8], the detected area in mm^2
  ;*COMMENT
  ;*      At the end of the calculation, the coordinates has to be mirrored to the
  ;*      z axis, because the names of the channels are in the opposite order
  ;*
  ;//////////////////////////////////////////////////////////

  ;  cd, '/media/disk/KFKI/Measurements/KSTAR/Measurement'
  ;  cd, 'C:\Users\lampee\KFKI\Measurements\KSTAR\Measurement'
  ;  
  ;  
  ; coordinates of the optical axis on the mirror and on the wall
    
  default,mirr_cord_oa_cyl,double([2833,-250,0])    ;from A. Kovacsik
  default,mirr_cord_oa_cyl,double([2747,-253,0])    ;from Yong Un (position of the bay window center)
  ;default,nbi_cord_oa_cyl, double([0,0,0])    ;from Yong Un NBI coordinate at optical axis during measurement
  default,plane_mirr_d,2317
  default,focal_length,50 ;focal length of the objective in mm in front of the APDCAM
  default,plot, 0
  default,trial,0
  default,shot,6076
  default,postscript,0
  ;restore the database for calibration
  restore, dir_f_name('cal','calib_database.sav')
  ind=where(database.shot eq shot)
  if (ind[0] eq -1) then begin
    print, 'The four coordinates on the EDICAM picture should be read'
    print, 'and filled into the database with fill_calib_database.pro.'
    print, 'Open the EDICAM picture with the closest shot number, and read'
    print, "the picture with Illustrator as described in Yong Un's riport."
    bl=''
    read,'Do you want to do this now? (y/n)',bl
    if (bl eq 'n') then begin
      error=1
    endif
    fill_calib_database
    restore, dir_f_name('cal','calib_database.sav')
    ind=where(database.shot eq shot)
  endif
  calc_nbi_oa,shot=shot,direction=database[ind].direction, fourcord=database[ind].fourcord, oa_nbi=nbi_cord_oa_xyz
  
  nbi_cord_oa_cal_cyl = double([1976,3,0]) ; NBI at optical axis  at the calibration measurement coordinate in CYLINDRICAL
  mirr_beam_d = double(2043)
  fl_cal=80 ;the focal length of the objective at the calibration.
  

 
  ; do the calibration, if the cal file is not present
  fname=dir_f_name('cal','spat_cal_'+strtrim(focal_length,2)+'mm.sav')
  if not (file_test(fname)) then begin  
  
    ;the following coordinates are measured on the paper
    ;vectors are [xmm,ymm]
    bl = [0,0] ; bottom left corner pixel has an approx. +-3 pixel dispersion
    tl = [0,210] ; top left corner
    mpl = [0,110] ;middle point of the left side of the paper
    mpr = [297,110] ;middle point of the right side of the paper
    
    lp = [68,113] ;coordinate of the left point
    rp = [253,113] ;coordinate of the right point
    tp = [164,184] ;coordinate of the top middlepoint
    mp = [183,110] ;coordinate of the m point on the paper
    
    ; [0,0,*] --- [1,0,*]
    ;         | |
    ; [0,1,*] --- [1,1,*]
    ;the coordinates shown on the upper scetch
    corner_cor = double([[[30,1763],[25,1712]],[[722,290],[1825,2352]]]) ;these are the positions of the corners of the paper on the image
    
    a4l = 297 ; the length of the A4 paper
    a4h = 210 ; the height of the A4 paper
    res = 5   ; the resolution of the mesh (equals 1/res [mm])
    
    xn = double(res*a4l)
    yn = double(res*a4h)
    spat_cor_p = dblarr(xn,yn,2)
    lxres = dblarr(xn)
    hxres = dblarr(xn)
    
    magn_f = double(0.66326) ;magnification far
    magn_c = double(1.237)   ;magnification close
    m = dblarr(xn)
    for i=0,xn-1 do m[i] = (magn_c-magn_f)/xn*i+magn_f ;calculate the magnification vector from the left side of the paper to the right side of the paper
  ;this for cycle calculates the X RESOLUTION for the whole paper taking the perspective into account
    for i=0,xn-1 do begin
      lxres[i] = (corner_cor[1,1,0]-corner_cor[0,1,0])*m[i]/total(m)
      hxres[i] = (corner_cor[1,0,0]-corner_cor[0,0,0])*m[i]/total(m)
    endfor
    
    ;the Y RESOLUTION
    
    lyres = (corner_cor[1,1,1]-corner_cor[0,1,1])/xn
    hyres = (corner_cor[1,0,1]-corner_cor[0,0,1])/xn
  
    for i=0,xn-1 do begin
      spat_cor_p[i,0,0] = corner_cor[0,1,0]+total(lxres[0:i])    ; fill up the x coordinates for y=0mm
      spat_cor_p[i,yn-1,0] = corner_cor[0,0,0]+total(hxres[0:i]) ; fill up the x coordinates for y=210mm
      spat_cor_p[i,0,1] = (corner_cor[0,1,1]-corner_cor[1,1,1])/(corner_cor[0,1,0]-corner_cor[1,1,0])*(spat_cor_p[i,0,0]-corner_cor[1,1,0])+corner_cor[1,1,1]             ; fill up the y coordinates for y=0mm
      spat_cor_p[i,yn-1,1] = (corner_cor[0,0,1]-corner_cor[1,0,1])/(corner_cor[0,0,0]-corner_cor[1,0,0])*(spat_cor_p[i,yn-1,0]-corner_cor[1,0,0])+corner_cor[1,0,1]           ; fill up the y coordinates for y=210mm
      for j=0,yn-1 do begin
        spat_cor_p[i,j,0] = (spat_cor_p[i,yn-1,0]-spat_cor_p[i,0,0])/yn*j+spat_cor_p[i,0,0] ; fill up the x coordinates between y=0mm and y=210mm
        spat_cor_p[i,j,1] = (spat_cor_p[i,yn-1,1]-spat_cor_p[i,0,1])/yn*j+spat_cor_p[i,0,1] ; fill up the y coordinates between y=0mm and y=210mm
      endfor
    endfor
  
    ; the spat_cor_p matrix is a matrix where the index indicates the spatial position, with [i,j]/res=[x,y] in mm
    
    ;these are the coordinates of the frame of the APD detector
    ;
    ;   [0,5,*]                      [1,5,*]
    ;         ------------------------
    ;         |[0,4,*]        [1,4,*]|
    ;         |[0,3,*]        [1,3,*]|
    ;         ------------------------         <--- APD array
    ;         |[0,2,*]        [1,2,*]|
    ;         |[0,1,*]        [1,1,*]|
    ;         ------------------------
    ;   [0,0,*]                      [1,0,*]
    
    pixcor_f=intarr(2,6,2)
    pixcor_f[*,*,0] = [[367,990],$   ;x
                       [408,965],$
                       [416,981],$
                       [420,983],$
                       [422,997],$
                       [405,1045]] 
    pixcor_f[*,*,1] = [[1367,1413],$ ;y
                       [1339,1389],$
                       [1230,1250],$
                       [1198,1208],$
                       [1086,1059],$
                       [1067,1030]]
                       
    pixcor_f[*,*,0] = [[367,990],$   ;x
                       [408,961],$
                       [416,981],$
                       [420,983],$
                       [429,1001],$
                       [405,1045]] 
    pixcor_f[*,*,1] = [[1367,1413],$ ;y
                       [1330,1386],$
                       [1230,1250],$
                       [1198,1208],$
                       [1078,1054],$
                       [1067,1030]]                       
    spatcor_f = dblarr(2,6,2)
    for i=0,1 do begin
      for j=0,5 do begin
        spatcor_f[i,j,*] = find_pix(pixcor_f[i,j,*],spat_cor_p)
      endfor
    endfor
    if not (keyword_set(silent)) then begin
      print, 'Magnification on the x axis: '+ strtrim((abs(spatcor_f[0,1,0]-spatcor_f[1,1,0])/17.7+abs(spatcor_f[0,4,0]-spatcor_f[1,4,0])/17.7)/2,2)
      print, 'Magnification on the Y axis: '+ strtrim((abs(spatcor_f[0,1,1]-spatcor_f[0,4,1])/8.8+abs(spatcor_f[1,1,1]-spatcor_f[1,4,1])/8.8)/2,2)
    endif
;this it the old calculation method    
;calculate the spatial coordinates from the last calculation for each pixel on the apd array
    spatcor_d = dblarr(8,4,2) ;the spatial coordinates of the detector array 
    pixcor_d = dblarr(8,4,2)  ;the pixel coordinates of the detector array
    
    hps = 0.8   ;half size of the pixel
    gap = 2.3   ;gap between pixels
    gapm = 2.6    ;gap in the middle
    arrl = 17.7 ;length of the pixel array horizontally
    arrh = 8.8  ;height of the pixel array vertically BTW: gap+hps*2+gapm=4.9

  ;First the points are calculated for the frame lines, then the corresponding coordinates determines lines, which determines one
  ;intersection point which is either the center of the pixel or one of its corner
  ;first the centers are calculated then the corners
  frame_tb=dblarr(8,2,2) ;[*,0,*] :bottom ,[*,1,*] :top 
  frame_lr=dblarr(4,2,2) ;[*,0,*] :left ,[*,1,*]   :right
  
  for i=0,7 do begin
    dist=(hps+i*gap)/(2*hps+7*gap)
    frame_tb[i,0,0]=(pixcor_f[1,1,0]-pixcor_f[0,1,0])*dist+pixcor_f[0,1,0]
    frame_tb[i,0,1]=(pixcor_f[1,1,1]-pixcor_f[0,1,1])*dist+pixcor_f[0,1,1]
    frame_tb[i,1,0]=(pixcor_f[1,4,0]-pixcor_f[0,4,0])*dist+pixcor_f[0,4,0]
    frame_tb[i,1,1]=(pixcor_f[1,4,1]-pixcor_f[0,4,1])*dist+pixcor_f[0,4,1]
  endfor
  for j=0,3 do begin
    if j le 1 then dist=(hps+j*gap)/(2*hps+2*gap+gapm) else dist=(hps+(j-1)*gap+gapm)/(2*hps+2*gap+gapm)
    frame_lr[j,0,0]=(pixcor_f[0,4,0]-pixcor_f[0,1,0])*dist+pixcor_f[0,1,0]
    frame_lr[j,0,1]=(pixcor_f[0,4,1]-pixcor_f[0,1,1])*dist+pixcor_f[0,1,1]
    frame_lr[j,1,0]=(pixcor_f[1,4,0]-pixcor_f[1,1,0])*dist+pixcor_f[1,1,0]
    frame_lr[j,1,1]=(pixcor_f[1,4,1]-pixcor_f[1,1,1])*dist+pixcor_f[1,1,1]
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
      pixcor_d[i,j,0]=determ([[determ([[x1,y1],[x2,y2]]),x1-x2],[determ([[x3,y3],[x4,y4]]),x3-x4]])/$
                      determ([[x1-x2,y1-y2],[x3-x4,y3-y4]])
      pixcor_d[i,j,1]=determ([[determ([[x1,y1],[x2,y2]]),y1-y2],[determ([[x3,y3],[x4,y4]]),y3-y4]])/$
                      determ([[x1-x2,y1-y2],[x3-x4,y3-y4]])
    endfor
  endfor
  
  
  ;It is necessary to take the angled view into account with the same method as the A4 paper
;v  m = dblarr(8)
 ; for i=0,7-1 do m[i] = (magn_c-magn_f)/xn*i+magn_f
  
  for i=0,7 do begin
    dist=(hps+i*gap)/(2*hps+7*gap)
    frame_tb[i,0,0]=(spatcor_f[1,1,0]-spatcor_f[0,1,0])*dist+spatcor_f[0,1,0]
    frame_tb[i,0,1]=(spatcor_f[1,1,1]-spatcor_f[0,1,1])*dist+spatcor_f[0,1,1]
    frame_tb[i,1,0]=(spatcor_f[1,4,0]-spatcor_f[0,4,0])*dist+spatcor_f[0,4,0]
    frame_tb[i,1,1]=(spatcor_f[1,4,1]-spatcor_f[0,4,1])*dist+spatcor_f[0,4,1]
  endfor
  for j=0,3 do begin
    if j le 1 then dist=(hps+j*gap)/(2*hps+2*gap+gapm) else dist=(hps+(j-1)*gap+gapm)/(2*hps+2*gap+gapm)
    frame_lr[j,0,0]=(spatcor_f[0,4,0]-spatcor_f[0,1,0])*dist+spatcor_f[0,1,0]
    frame_lr[j,0,1]=(spatcor_f[0,4,1]-spatcor_f[0,1,1])*dist+spatcor_f[0,1,1]
    frame_lr[j,1,0]=(spatcor_f[1,4,0]-spatcor_f[1,1,0])*dist+spatcor_f[1,1,0]
    frame_lr[j,1,1]=(spatcor_f[1,4,1]-spatcor_f[1,1,1])*dist+spatcor_f[1,1,1]
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
      spatcor_d[i,j,0]=determ([[determ([[x1,y1],[x2,y2]]),x1-x2],[determ([[x3,y3],[x4,y4]]),x3-x4]])/$
                      determ([[x1-x2,y1-y2],[x3-x4,y3-y4]])
      spatcor_d[i,j,1]=determ([[determ([[x1,y1],[x2,y2]]),y1-y2],[determ([[x3,y3],[x4,y4]]),y3-y4]])/$
                      determ([[x1-x2,y1-y2],[x3-x4,y3-y4]])
    endfor
  endfor
  
  op_ax = [(spatcor_d[3,1,0]+spatcor_d[4,1,0]+spatcor_d[3,2,0]+spatcor_d[4,2,0])/4.,$
           (spatcor_d[3,1,1]+spatcor_d[4,1,1]+spatcor_d[3,2,1]+spatcor_d[4,2,1])/4.]
    
  spatcor_d[*,*,0]=(spatcor_d[*,*,0]-op_ax[0])*double(fl_cal)/double(focal_length)+op_ax[0]
  spatcor_d[*,*,1]=(spatcor_d[*,*,1]-op_ax[1])*double(fl_cal)/double(focal_length)+op_ax[1]

;The following lines calculates the four coordinates of each pixels corner for the determination of the pixel area
;    ;(necessary for the pixel size determination)
;    ;third index goes from the bottom left corner in counterclockwise

  det_cor_spat_t=dblarr(16,8,2)
  det_cor_spat=dblarr(8,4,4,2)
  
  frame_tb_c=dblarr(16,2,2) ;[*,0,*] :bottom ,[*,1,*] :top 
  frame_lr_c=dblarr(8,2,2) ;[*,0,*] :left ,[*,1,*]   :right
  
  for i=0,15 do begin
    if (i/2*2 eq i) then dist=(i/2*gap)/(2*hps+7*gap) else dist=(i/2*gap+2*hps)/(2*hps+7*gap)
    frame_tb_c[i,0,0]=(spatcor_f[1,1,0]-spatcor_f[0,1,0])*dist+spatcor_f[0,1,0]
    frame_tb_c[i,0,1]=(spatcor_f[1,1,1]-spatcor_f[0,1,1])*dist+spatcor_f[0,1,1]
    frame_tb_c[i,1,0]=(spatcor_f[1,4,0]-spatcor_f[0,4,0])*dist+spatcor_f[0,4,0]
    frame_tb_c[i,1,1]=(spatcor_f[1,4,1]-spatcor_f[0,4,1])*dist+spatcor_f[0,4,1]
  endfor
  
  for j=0,7 do begin
    if (j/2*2 eq j and j le 3) then dist=(j/2*gap)/(2*hps+2*gap+gapm)
    if (j/2*2 ne j and j le 3) then dist=(j/2*gap+2*hps)/(2*hps+2*gap+gapm)
    if (j/2*2 eq j and j ge 4) then dist=((j/2-1)*gap+gapm)/(2*hps+2*gap+gapm)
    if (j/2*2 ne j and j ge 4) then dist=((j/2-1)*gap+gapm+2*hps)/(2*hps+2*gap+gapm)
    
    frame_lr_c[j,0,0]=(spatcor_f[0,4,0]-spatcor_f[0,1,0])*dist+spatcor_f[0,1,0]
    frame_lr_c[j,0,1]=(spatcor_f[0,4,1]-spatcor_f[0,1,1])*dist+spatcor_f[0,1,1]
    frame_lr_c[j,1,0]=(spatcor_f[1,4,0]-spatcor_f[1,1,0])*dist+spatcor_f[1,1,0]
    frame_lr_c[j,1,1]=(spatcor_f[1,4,1]-spatcor_f[1,1,1])*dist+spatcor_f[1,1,1]
  endfor
  for i=0,15 do begin
    for j=0,7 do begin
      x1=frame_tb_c[i,0,0]
      y1=frame_tb_c[i,0,1]
      x2=frame_tb_c[i,1,0]
      y2=frame_tb_c[i,1,1]
      
      x3=frame_lr_c[j,0,0]
      y3=frame_lr_c[j,0,1]
      x4=frame_lr_c[j,1,0]
      y4=frame_lr_c[j,1,1]
      det_cor_spat_t[i,j,0]=determ([[determ([[x1,y1],[x2,y2]]),x1-x2],[determ([[x3,y3],[x4,y4]]),x3-x4]])/$
                      determ([[x1-x2,y1-y2],[x3-x4,y3-y4]])
      det_cor_spat_t[i,j,1]=determ([[determ([[x1,y1],[x2,y2]]),y1-y2],[determ([[x3,y3],[x4,y4]]),y3-y4]])/$
                      determ([[x1-x2,y1-y2],[x3-x4,y3-y4]])
    endfor
  endfor
  
  for i=0,7 do begin
    for j=0,3 do begin
      for k=0,3 do begin
        det_cor_spat[i,j,0,*]=det_cor_spat_t[i*2,j*2,*]
        det_cor_spat[i,j,1,*]=det_cor_spat_t[i*2+1,j*2,*]
        det_cor_spat[i,j,2,*]=det_cor_spat_t[i*2+1,j*2+1,*]
        det_cor_spat[i,j,3,*]=det_cor_spat_t[i*2,j*2+1,*]
      endfor
    endfor
  endfor
  
  det_cor_spat[*,*,*,0]=(det_cor_spat[*,*,*,0]-op_ax[0])*double(fl_cal)/double(focal_length)+op_ax[0]
  det_cor_spat[*,*,*,1]=(det_cor_spat[*,*,*,1]-op_ax[1])*double(fl_cal)/double(focal_length)+op_ax[1]
  
    a=dblarr(32,2)
    b=dblarr(128,2)
    loadct, 5
    Device, Decomposed=0
    corner_cor=[[spatcor_f[0,1,0],spatcor_f[0,4,0],spatcor_f[1,1,0],spatcor_f[1,4,0]],$
                [spatcor_f[0,1,1],spatcor_f[0,4,1],spatcor_f[1,1,1],spatcor_f[1,4,1]]]
    corner_cor[*,0]=(corner_cor[*,0]-op_ax[0])*double(fl_cal)/double(focal_length)+op_ax[0]
    corner_cor[*,1]=(corner_cor[*,1]-op_ax[1])*double(fl_cal)/double(focal_length)+op_ax[1]
     
    for i=0,7 do for j=0,3 do for k=0,3 do b[i*16+j*4+k,*]=det_cor_spat[i,j,k,*]
    plot, b[*,0],b[*,1], psym=4, xstyle=1, ystyle=1    
    for i=0,7 do for j=0,3 do a[i+j*8,*]=spatcor_d[i,j,*]
    oplot, a[*,0],a[*,1], psym=4
    oplot, b[*,0],b[*,1], psym=4, color=50
    oplot, corner_cor[*,0],corner_cor[*,1],psym=4,color=120
    
    save, spatcor_d, spat_cor_p, det_cor_spat, pixcor_d, filename=fname
    spatcor_d_a4_xy=spatcor_d
  endif else begin
    restore, fname
    spatcor_d_a4_xy=spatcor_d
  endelse

  ;print, spatcor_d_a4_xy
  
  ;this calculates the OPTICAL AXIS ON THE PAPER from the middle 4 coordinates
  op_ax = [(spatcor_d_a4_xy[3,1,0]+spatcor_d_a4_xy[4,1,0]+spatcor_d_a4_xy[3,2,0]+spatcor_d_a4_xy[4,2,0])/4,$
           0,$
           (spatcor_d_a4_xy[3,1,1]+spatcor_d_a4_xy[4,1,1]+spatcor_d_a4_xy[3,2,1]+spatcor_d_a4_xy[4,2,1])/4]
  
  ;from now on the real tokamak geometry coordinates will be determined
  
  ;spatcor_d_a4_xy[i,j,k]: k=0: mm/5 distance from the lower left corner of the A4 paper in the x direction,
  ;k=1 is mm/5 distance in the y direction, i,j determines which detector
  
  ;from now on the coordinates are the following: matrix[*,*,3]=[*,*,(0:R,1:z,2:phi)], phi is in radians counterclockwise
  
  nbi_cord_oa_cal_cyl[2] = acos((nbi_cord_oa_cal_cyl[0]^2+mirr_cord_oa_cyl[0]^2-mirr_beam_d^2)/(2*mirr_cord_oa_cyl[0]*nbi_cord_oa_cal_cyl[0]))
  
  if (distance(nbi_cord_oa_cyl,[0,0,0]) eq 0) then nbi_cord_oa_cyl = nbi_cord_oa_cal_cyl
  
  mirr_cord_oa_xyz = xyztocyl(mirr_cord_oa_cyl,/inv) ;the x,y,z coordinates of the mirror
  nbi_cord_oa_cal_xyz = xyztocyl(nbi_cord_oa_cal_cyl,/inv) ;the x,y,z coordinates of the NBI cal at o.a.
  ;nbi_cord_oa_xyz = xyztocyl(nbi_cord_oa_cyl,/inv) ;the x,y,z coordinates of the NBI at o.a.
  
  spatcor_dc_xz = dblarr(8,4,3)
  spatcor_dc_xz[*,*,0] = spatcor_d_a4_xy[*,*,0]-op_ax[0] ;this transforms the origo from the papers lower left corner to the optical axis on the paper
  spatcor_dc_xz[*,*,1] = 0 ;and this also into the coordinate system tied to the paper
  spatcor_dc_xz[*,*,2] = spatcor_d_a4_xy[*,*,1]-op_ax[2]
  ;the coordinates of the corners of the detector pixels
  spatcor_dc_corner_xz = dblarr(8,4,4,3)
  spatcor_dc_corner_xz[*,*,*,0] = det_cor_spat[*,*,*,0]-op_ax[0] ;this transforms the origo from the papers lower left corner to the optical axis on the paper
  spatcor_dc_corner_xz[*,*,*,1] = 0 ;and this also into the coordinate system tied to the paper
  spatcor_dc_corner_xz[*,*,*,2] = det_cor_spat[*,*,*,1]-op_ax[2]  
  
  ;/// The following coordinates are rotated into the NBI's angle, rotated with an alfa angle
  ;two points of the BEAM
  ;
  ;R=1800:
  a_angle = -acos((1800.^2+mirr_cord_oa_cyl[0]^2-2317.^2)/(2.*mirr_cord_oa_cyl[0]*1800.))
  a_point_cyl = double([1800,3,a_angle])
  a_point_xyz = xyztocyl(a_point_cyl,/inv)
  
  ;R=2250:
  b_angle = -acos((2250.^2+mirr_cord_oa_cyl[0]^2-1852.^2)/(2.*mirr_cord_oa_cyl[0]*2250.))
  b_point_cyl = double([2250,3,b_angle])
  b_point_xyz = xyztocyl(b_point_cyl,/inv)
  ;points for geometry calculation
  xa = a_point_xyz[0]
  xb = b_point_xyz[0]
  xm = mirr_cord_oa_xyz[0]
  ya = a_point_xyz[1]
  yb = b_point_xyz[1]
  ym = mirr_cord_oa_xyz[1]
  ;the following few lines calculate the coordinates of the optical axis on the NBI from the NBI's line equation and the o.a.'s R coordinate
  nagyr = 1976.
  nagya = (yb-ya)/(xb-xa)
  coa = nagya^2+1
  cob = 2*nagya*ya-2*nagya^2*xa
  coc = 2*nagya^2*xa^2+ya^2-2*nagya*xa*ya-nagyr^2
  nbi_cord_oa_cal_xyz[0] = (-cob+sqrt(cob^2-4*coa*coc))/(2*coa)
  nbi_cord_oa_cal_xyz[1] = nagya*(nbi_cord_oa_cal_xyz[0]-xa)+ya

  vecnbi = [a_point_xyz[0]-b_point_xyz[0],a_point_xyz[1]-b_point_xyz[1],0] ;the direction vector of the NBI
  vecnbimirr = nbi_cord_oa_cal_xyz[0:1]-mirr_cord_oa_xyz[0:1] ;the direction vector of the NBI's op.ax. and the mirror's op.ax.
    
  vecnbin = vecnbi/distance(vecnbi, /length) ;normalized directon vector of the NBI
  
  ;this calculates the position of the pixels in xyz coordinate
  spatcor_d_cal_xyz = dblarr(8,4,3)
  spatcor_d_cal_cyl = dblarr(8,4,3)
  for i=0,7 do begin
    for j=0,3 do begin
      spatcor_d_cal_xyz[i,j,0:1] = vecnbin[0:1]*spatcor_dc_xz[i,j,0]+nbi_cord_oa_cal_xyz[0:1]
      spatcor_d_cal_xyz[i,j,2] = spatcor_dc_xz[i,j,2]
      spatcor_d_cal_cyl[i,j,*] = xyztocyl(spatcor_d_cal_xyz[i,j,*])
    endfor
  endfor
  
  ;readjust the cylindrical coordinates
  for i=0,7 do begin
    for j=0,3 do begin
      if (spatcor_d_cal_cyl[i,j,2] gt !pi/2) then spatcor_d_cal_cyl[i,j,2]-=!pi/2
      if (spatcor_d_cal_cyl[i,j,2] lt -!pi/2) then spatcor_d_cal_cyl[i,j,2]+=!pi/2
    endfor
  endfor
  
  ;this calculates the position of the pixel's ccorners in xyz coordinate
  spatcor_d_cal_corner_xyz = dblarr(8,4,4,3)
  for i=0,7 do begin
    for j=0,3 do begin
      for k=0,3 do begin
        spatcor_d_cal_corner_xyz[i,j,k,0:1] = vecnbin[0:1]*spatcor_dc_corner_xz[i,j,k,0]+nbi_cord_oa_cal_xyz[0:1]
        spatcor_d_cal_corner_xyz[i,j,k,2] = spatcor_dc_corner_xz[i,j,k,2]
      endfor
    endfor
  endfor
  
  
  
;  print, spatcor_d_cal_cyl ;in CYLINDRICAL
  nbi_cal_mirr_d = distance(nbi_cord_oa_cal_xyz,mirr_cord_oa_xyz)
  nbi_mirr_d     = distance(nbi_cord_oa_xyz,mirr_cord_oa_xyz)
  nbi_nbi_cal_d  = distance(nbi_cord_oa_cal_xyz,nbi_cord_oa_xyz)
  
  vec1 = nbi_cord_oa_cal_xyz - mirr_cord_oa_xyz
  vec2 = nbi_cord_oa_xyz - mirr_cord_oa_xyz
  
;The following section calculates a rotation around an axis
;which is perpendicular to the calibration and Yong Un's axis
;with an angle between the aforementioned vectors (vec1, vec2) 
  vec1 = nbi_cord_oa_cal_xyz - mirr_cord_oa_xyz
  vec2 = nbi_cord_oa_xyz - mirr_cord_oa_xyz
   
  if (keyword_set(trial)) then begin
    vec_rot=[0,0,1]
    alfa=3./180.*!pi
    ;for the trial, the o.a. on the nbi is calculated from a rotation
    nbi_cord_oa_xyz=rot_general(nbi_cord_oa_cal_xyz,vec_rot,mirr_cord_oa_xyz,alfa)
    p0=nbi_cord_oa_xyz
    p1=mirr_cord_oa_xyz
    v0=a_point_xyz
    n = [ya-yb,xb-xa,0]
    s1=(n ## transpose((v0-p0)))/(n ## transpose((p1-p0)))
    nbi_cord_oa_xyz=p0+s1[0]*(p1-p0)
  endif else begin
    vec_rot=cross_prod(vec1,vec2)
    alfa=abs(acos((vec1 ## transpose(vec2))[0]/(distance(vec1,/length)*distance(vec2,/length))))
  endelse
  
  a = dblarr(3)
  spatcor_d_xyz = dblarr(8,4,3)
  spatcor_d_corner_xyz = dblarr(8,4,4,3)
  for i=0,7 do begin
    for j=0,3 do begin
      a[*] = spatcor_d_cal_xyz[i,j,*]
      spatcor_d_xyz[i,j,*] = rot_general(a,vec_rot,mirr_cord_oa_xyz,alfa)
      for k=0,3 do begin
        a[*] = spatcor_d_cal_corner_xyz[i,j,k,*]
        spatcor_d_corner_xyz[i,j,k,*] = rot_general(a,vec_rot,mirr_cord_oa_xyz,alfa)
      endfor
    endfor
  endfor

;This calculates the xyz coordinates for a given 
;optical axis point on the NBI's plane (OLD METHOD)
;Calculation of the optical axis
;  xdp = nbi_cord_oa_xyz[0]
;  ydp = nbi_cord_oa_xyz[1]
;  nbi_cord_oa_xyz[0] = ((ym-ya)*(xb-xa)*(xdp-xm)+xa*(yb-ya)*(xdp-xm)-xm*(ydp-ym)*(xb-xa))/((yb-ya)*(xdp-xm)-(ydp-ym)*(xb-xa))
;  x = nbi_cord_oa_xyz[0]
;  nbi_cord_oa_xyz[1] = (x-xa)/(xb-xa)*(yb-ya)+ya
;  nbi_cord_oa_xyz[2] = 0
;
;  spatcor_d_meas_xyz = dblarr(8,4,3)
;  for i=0,7 do begin
;    for j=0,3 do begin
;      xdp = spatcor_d_xyz[i,j,0]
;      ydp = spatcor_d_xyz[i,j,1]
;      spatcor_d_meas_xyz[i,j,0] = ((ym-ya)*(xb-xa)*(xdp-xm)+xa*(yb-ya)*(xdp-xm)-xm*(ydp-ym)*(xb-xa))/((yb-ya)*(xdp-xm)-(ydp-ym)*(xb-xa))
;      x = spatcor_d_meas_xyz[i,j,0]
;      spatcor_d_meas_xyz[i,j,1] = (x-xa)/(xb-xa)*(yb-ya)+ya
;      spatcor_d_meas_xyz[i,j,2] = spatcor_d_xyz[i,j,2]
;     ;print, (ya-yb)/(xa-xb)-(ya-spatcor_d_meas_xyz[i,j,1])/(xa-spatcor_d_meas_xyz[i,j,0])
;    endfor
;  endfor

;points for geometry calculation
  xa = a_point_xyz[0]
  xb = b_point_xyz[0]
  xm = mirr_cord_oa_xyz[0]
  ya = a_point_xyz[1]
  yb = b_point_xyz[1]
  ym = mirr_cord_oa_xyz[1]  

;This calculates the optical axis for a given rotation (only for trial, before Yong un gives the coordinates)
  spatcor_d_meas_xyz = dblarr(8,4,3)
  for i=0,7 do begin
    for j=0,3 do begin
      p0 = [spatcor_d_xyz[i,j,0],spatcor_d_xyz[i,j,1],spatcor_d_xyz[i,j,2]]
      p1 = mirr_cord_oa_xyz
      v0=a_point_xyz
      n = [ya-yb,xb-xa,0]
      s1=(n ## transpose((v0-p0)))/(n ## transpose((p1-p0)))
      spatcor_d_meas_xyz[i,j,*]=p0+s1[0]*(p1-p0)
      ;print, (ya-yb)/(xa-xb)-(ya-spatcor_d_meas_xyz[i,j,1])/(xa-spatcor_d_meas_xyz[i,j,0])
    endfor
  endfor
  
  ;This transformes the xyz back to CYLINDRICAL
  spatcor_d_meas_cyl = dblarr(8,4,3) ;detector rotated in [R, z, fi]
  for i=0,7 do begin
    for j=0,3 do begin
      spatcor_d_meas_cyl[i,j,*] = xyztocyl(spatcor_d_meas_xyz[i,j,*])
    endfor
  endfor
  ;calculate the coordinates for the corners
  spatcor_d_meas_corner_xyz = dblarr(8,4,4,3)
  for i=0,7 do begin
    for j=0,3 do begin
      for k=0,3 do begin
        p0 = [spatcor_d_corner_xyz[i,j,k,0],spatcor_d_corner_xyz[i,j,k,1],spatcor_d_corner_xyz[i,j,k,2]]
        p1 = mirr_cord_oa_xyz
        v0=a_point_xyz
        n = [ya-yb,xb-xa,0]
        s1=(n ## transpose((v0-p0)))/(n ## transpose((p1-p0)))
        spatcor_d_meas_corner_xyz[i,j,k,*]=p0+s1[0]*(p1-p0)
      endfor
    endfor
  endfor 
  
  
  ;The following lines calculate the measured area for each pixel
  ;calculate the area of two triangles which determines the pixel and add -> voilla
  ;the pixel size should be the size perpendicular to the POV
  pixelsize=dblarr(8,4)
  r=dblarr(4,3)
  for i=0,7 do begin
    for j=0,3 do begin
      angle= acos(((a_point_xyz-b_point_xyz) ## transpose(spatcor_d_meas_xyz[i,j,*]-mirr_cord_oa_xyz))[0]/$
                  (distance((a_point_xyz-b_point_xyz),/length)*distance((spatcor_d_meas_xyz[i,j,*]-mirr_cord_oa_xyz),/length)))   ;angle between NBI and POV
      for k=0,3 do r[k,*]=spatcor_d_meas_corner_xyz[i,j,k,*]
      v1=r[1,*]-r[0,*]
      v2=r[2,*]-r[0,*]
      v3=r[1,*]-r[3,*]
      v4=r[2,*]-r[3,*]
      v12=cross_prod(v1,v2)
      v34=cross_prod(v3,v4)
      pixelsize[i,j]=(sqrt(v12 ## transpose(v12))+sqrt(v34 ## transpose(v34)))/2.*sin(angle)
    endfor
  endfor
  ;print, pixelsize
  
  ;the following section is only for visualisation
  
  if (keyword_set(plot)) then begin
  
    spat_xyz_4plot = dblarr(3,32)
    
    for i=0,2 do begin 
      spat_xyz_4plot[i,0:7] = spatcor_d_cal_xyz[*,0,i]
      spat_xyz_4plot[i,8:15] = spatcor_d_cal_xyz[*,1,i]
      spat_xyz_4plot[i,16:23] = spatcor_d_cal_xyz[*,2,i]
      spat_xyz_4plot[i,24:31] = spatcor_d_cal_xyz[*,3,i]    
    endfor
    
    spat_xyz_4plot2 = dblarr(3,32)
    
    for i=0,2 do begin
      spat_xyz_4plot2[i,0:7] = spatcor_d_meas_xyz[*,0,i]
      spat_xyz_4plot2[i,8:15] = spatcor_d_meas_xyz[*,1,i]
      spat_xyz_4plot2[i,16:23] = spatcor_d_meas_xyz[*,2,i]
      spat_xyz_4plot2[i,24:31] = spatcor_d_meas_xyz[*,3,i]
    endfor
    spat_xyz_4plot_double = dblarr(3,667)
    
    spat_xyz_4plot_double[*,0:31] = spat_xyz_4plot
    spat_xyz_4plot_double[*,32:63] = spat_xyz_4plot2
    
    spat_xyz_4plot_double[*,64] = a_point_xyz
    spat_xyz_4plot_double[*,65] = b_point_xyz
    spat_xyz_4plot_double[*,66] = nbi_cord_oa_cal_xyz
    spat_xyz_4plot_double[*,67] = nbi_cord_oa_xyz
    
    ;trial tokamak for visualisation
    R1 = 1.3*1000
    R2 = 2.3*1000
    ;R2 = 1976.
    
    a1 = (double(findgen(100)))/99.*2*R1-R1
    a2 = (double(findgen(100)))/99.*2*R2-R2
    b1 = sqrt(R1^2 - a1^2)
    b2 = sqrt(R2^2 - a2^2)
    spat_xyz_4plot_double[0,67:166] = a1
    spat_xyz_4plot_double[1,67:166] = b1
    spat_xyz_4plot_double[0,167:266] = a2
    spat_xyz_4plot_double[1,167:266] = b2
    b1 = -sqrt(R1^2 - a1^2)
    b2 = -sqrt(R2^2 - a2^2)
    spat_xyz_4plot_double[0,267:366] = a1
    spat_xyz_4plot_double[1,267:366] = b1
    spat_xyz_4plot_double[0,467:566] = a2
    spat_xyz_4plot_double[1,467:566] = b2
    
    ;trial beam line for visualisation
    
    a3 = double(findgen(100)*8.176272+687.28500)
    x1 = a_point_xyz[0]
    x2 = b_point_xyz[0]
    y1 = a_point_xyz[1]
    y2 = b_point_xyz[1]
    b3 = (a3-x1)/(x2-x1)*(y2-y1)+y1
    spat_xyz_4plot_double[0,567:666] = a3
    spat_xyz_4plot_double[1,567:666] = b3
    
    ;do the plotting
    if keyword_set(postscript) then begin
      hardon, /color
      set_plot_style, 'foile_kg_eps'
    endif
    loadct,39
    Device, Decomposed=0
    erase

    plot,spat_xyz_4plot_double[0,67:666],spat_xyz_4plot_double[1,67:666], linestyle=0, /isotrop,$
         /noerase, xrange=[-2400,2400],yrange=[-2400,2400]
    oplot, spat_xyz_4plot_double[0,0:31],spat_xyz_4plot_double[1,0:31],psym=3, linestyle=0, color=240
    oplot, spat_xyz_4plot_double[0,32:63],spat_xyz_4plot_double[1,32:63],psym=3, linestyle=0, color=80
    oplot, spat_xyz_4plot_double[0,64:65],spat_xyz_4plot_double[1,64:65],psym=3, linestyle=0, color=160
    plots, nbi_cord_oa_cal_xyz[0:1], psym=4, linestyle=0, color=round(11.5*16)
    plots, nbi_cord_oa_xyz[0:1], psym=4, linestyle=0, color=round(11.5*16)
    plots, mirr_cord_oa_xyz[0:1], psym=4, linestyle=0, color=round(10.5*16)
    cursor,x,y,/down
    erase
    plot, spat_xyz_4plot_double[1,0:31],spat_xyz_4plot_double[2,0:31], psym=4, xstyle=1, ystyle=1,$
          xtitle='X coordinate', ytitle='Z coordinate', xcharsize=1.5, ycharsize=1.5,$
          xrange=[min(spat_xyz_4plot_double[1,0:31])*1.01,max(spat_xyz_4plot_double[1,0:31])*0.99],yrange=[min(spat_xyz_4plot_double[2,0:31])*1.1,max(spat_xyz_4plot_double[2,0:31])*1.1],$
          /isotrop
    if keyword_set(postscript) then hardfile, 'scheme.ps'
    ;iplot, spat_xyz_4plot_double, linestyle=6, SYM_THICK=2, SYM_INDEX=2, xrange=[-2500,2500],yrange=[-2500,2500],zrange=[-50,50]
    
  endif
  
  ;the data has to be mirrored for the appropriate indexing for the naming of the channels
  tempdetcor=spatcor_d_meas_xyz
  tempcorncor=spatcor_d_meas_corner_xyz
  tempdetcorcyl=spatcor_d_meas_cyl
  for i=0,7 do begin
    spatcor_d_meas_cyl[i,*,*]=tempdetcor[7-i,*,*]
    spatcor_d_meas_corner_xyz[i,*,*,*]=tempcorncor[7-i,*,*,*]
    spatcor_d_meas_cyl[i,*,*]=tempdetcorcyl[7-i,*,*]
  endfor
  spatcor_d_meas_corner_cyl=dblarr(8,4,4,3)
  for i=0,7 do for j=0,3 do for k=0,3 do spatcor_d_meas_corner_cyl[i,j,k,*]=xyztocyl(spatcor_d_meas_corner_xyz[i,j,k,*]) 
  pixarea=pixelsize
  if not keyword_set(xyz) then begin
    detcorncord=spatcor_d_meas_corner_cyl
    detpos=spatcor_d_meas_cyl
  endif else begin
    detcorncord=spatcor_d_meas_corner_xyz
    detpos=spatcor_d_meas_xyz
  endelse
  if not (keyword_set(silent)) then print, 'Calculation for shot '+strtrim(shot,2)+' done!'
  ;stop
end