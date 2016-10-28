pro apd_calib_2, shot=shot, focal_length=focal_length, plot=plot, trial=trial,$
                 pixarea=pixarea, detpos=detpos
  
  ;//////////////////////////////////////////////////////////
  ;                  APDCAM spatial calibration
  ;//////////////////////////////////////////////////////////
  ;This procedure takes the shot number and gives back the
  ;radial and zeta coordinates of the line of site of the
  ;APD detectors in the plasma.
  ;
  ;INPUT:
  ;      shot: the shot number the calibration is used for
  ;      focal_length: the focal length of the lens in front of the APDCAM
  ;      trial: only for debugging, if real measurement data is used, then it should be 0
  ;      plot: plot the usable area where the pixels are with the NBI's line
  ;      
  ;OUTPUT
  ;      detpos: [4,8,3] array of the detectors and its spatial
  ;        coordinates in xyz, the origo is the center of the tokamak,
  ;        x is pointing at the mirrors optical axis at z=0
  ;        the coordinates are in mm
  ;      pixarea: [4,8], the detected area in mm^2
  ;//////////////////////////////////////////////////////////
  
    ;coordinates of the optical axis on the mirror and on the wall
    
  default,mirr_cord_oa_cyl,double([2833,-250,0])    ;from A. Kovacsik OK!
  default,nbi_cord_oa_cyl, double([0,0,0])    ;from Yong Un NBI coordinate at optical axis during measurement
  default,plane_mirr_d,2317
  default,focal_length,50 ;focal length of the objective in mm in front of the APDCAM
  default,plot, 1
  default,trial,1
  
  nbi_cord_oa_cal_cyl = double([1976,3,0]) ; NBI at optical axis  at the calibration measurement coordinate in CYLINDRICAL
  mirr_beam_d = double(2043)
  fl_cal=80 ;the focal length of the objective at the calibration.
  
  cd, '/media/disk/KFKI/Measurements/KSTAR/Measurement'
  ; do the calibration, if the cal file is not present
  if not (file_test('cal/spat_cal_'+strtrim(focal_length,2)+'mm.sav')) then begin  
    calibration, output=spatcor_d
  endif else begin
    restore, 'cal/spat_cal_'+strtrim(focal_length,2)+'mm.sav'
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
  nbi_cord_oa_xyz = xyztocyl(nbi_cord_oa_cyl,/inv) ;the x,y,z coordinates of the NBI at o.a.
  
  spatcor_dc_xz = dblarr(8,4,3)
  spatcor_dc_xz[*,*,0] = spatcor_d_a4_xy[*,*,0]-op_ax[0] ;this transforms the origo from the papers lower left corner to the optical axis on the paper
  spatcor_dc_xz[*,*,1] = 0 ;and this also into the coordinate system tied to the paper
  spatcor_dc_xz[*,*,2] = spatcor_d_a4_xy[*,*,1]-op_ax[2]
  
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
  nagya = (yb-ya)/(xb-xa)
  coa = nagya^2+1
  cob = 2*nagya*ya-2*nagya^2*xa
  coc = 2*nagya^2*xa^2+ya^2-2*nagya*xa*ya-1976.^2
  nbi_cord_oa_cal_xyz[0] = (-cob+sqrt(cob^2-4*coa*coc))/(2*coa)
  nbi_cord_oa_cal_xyz[1] = nagya*(nbi_cord_oa_cal_xyz[0]-xa)+ya

  vecnbi = [a_point_xyz[0]-b_point_xyz[0],a_point_xyz[1]-b_point_xyz[1],0] ;the direction vector of the NBI
  vecnbimirr = nbi_cord_oa_cal_xyz[0:1]-mirr_cord_oa_xyz[0:1] ;the direction vector of the NBI's op.ax. and the mirror's op.ax.
    
  vecnbin = vecnbi/veclength(vecnbi) ;normalized directon vector of the NBI
  spatcor_d_cal_xyz = dblarr(8,4,3)
  spatcor_d_cal_cyl = dblarr(8,4,3)
  
  ;this calculates the position of the pixels in xyz coordinate
  for i=0,7 do begin
    for j=0,3 do begin
      spatcor_d_cal_xyz[i,j,0:1] = vecnbin[0:1]*spatcor_dc_xz[i,j,0]+nbi_cord_oa_cal_xyz[0:1]
      spatcor_d_cal_xyz[i,j,2] = spatcor_dc_xz[i,j,2]
      spatcor_d_cal_cyl[i,j,*] = xyztocyl(spatcor_d_cal_xyz[i,j,*])
    endfor
  endfor
  
  for i=0,7 do begin
    for j=0,3 do begin
      if (spatcor_d_cal_cyl[i,j,2] gt !pi/2) then spatcor_d_cal_cyl[i,j,2]-=!pi/2
      if (spatcor_d_cal_cyl[i,j,2] lt -!pi/2) then spatcor_d_cal_cyl[i,j,2]+=!pi/2
    endfor
  endfor
  
;  print, spatcor_d_cal_cyl ;in CYLINDRICAL
  nbi_cal_mirr_d = distance(nbi_cord_oa_cal_xyz,mirr_cord_oa_xyz)
  nbi_mirr_d     = distance(nbi_cord_oa_xyz,mirr_cord_oa_xyz)
  nbi_nbi_cal_d  = distance(nbi_cord_oa_cal_xyz,nbi_cord_oa_xyz)
  
  vec1 = nbi_cord_oa_cal_xyz - mirr_cord_oa_xyz
  vec2 = nbi_cord_oa_xyz - mirr_cord_oa_xyz
  
  ;alfa = acos((nbi_cal_mirr_d^2+nbi_mirr_d^2-nbi_nbi_cal_d^2)/(2*nbi_cal_mirr_d*nbi_mirr_d)) ;this gives the angle's magnitude without its sign
  
  if (keyword_set(trial)) then alfa=-3./180.*!pi else alfa = atan(vec1[1]/vec1[0])-atan(vec2[1]/vec2[0])  ; in theory, this gives signed angle compared to the calibration axis.
                                                                                                                        ; Since the angle is always lower than 5° the nature of tangent
                                                                                                                        ; won't cause a problem
  print, alfa ;the angle between calibration and the actual measurement's optical axis
  spatcor_d_xyz = dblarr(8,4,3)
  a = dblarr(3)

  for i=0,7 do begin
    for j=0,3 do begin
      a[*] = spatcor_d_cal_xyz[i,j,*]
      spatcor_d_xyz[i,j,*] = rot_z(a, mirr_cord_oa_xyz, alfa) ;perform the rotation
    endfor
  endfor

  ;This calculates the xyz coordinates for a given optical axis point on the NBI's plane
  spatcor_d_meas_xyz = dblarr(8,4,3)
  for i=0,7 do begin
    for j=0,3 do begin
      xdp = spatcor_d_xyz[i,j,0]
      ydp = spatcor_d_xyz[i,j,1]
      spatcor_d_meas_xyz[i,j,0] = ((ym-ya)*(xb-xa)*(xdp-xm)+xa*(yb-ya)*(xdp-xm)-xm*(ydp-ym)*(xb-xa))/((yb-ya)*(xdp-xm)-(ydp-ym)*(xb-xa))
      x = spatcor_d_meas_xyz[i,j,0]
      spatcor_d_meas_xyz[i,j,1] = (x-xa)/(xb-xa)*(yb-ya)+ya
      spatcor_d_meas_xyz[i,j,2] = spatcor_d_xyz[i,j,2]
    endfor
  endfor
  
  ;This calculates the optical axis for a given rotation (only for trial, before Yong un gives the coordinates)
  nbi_cord_oa_xyz=rot_z(nbi_cord_oa_cal_xyz, mirr_cord_oa_xyz, alfa)
  xdp = nbi_cord_oa_xyz[0]
  ydp = nbi_cord_oa_xyz[1]
  nbi_cord_oa_xyz[0] = ((ym-ya)*(xb-xa)*(xdp-xm)+xa*(yb-ya)*(xdp-xm)-xm*(ydp-ym)*(xb-xa))/((yb-ya)*(xdp-xm)-(ydp-ym)*(xb-xa))
  x = nbi_cord_oa_xyz[0]
  nbi_cord_oa_xyz[1] = (x-xa)/(xb-xa)*(yb-ya)+ya
  
  ;This transformes the xyz back to CYLINDRICAL
  spatcor_d_meas_cyl = dblarr(8,4,3) ;detector rotated in [R, z, fi]
  for i=0,7 do begin
    for j=0,3 do begin
      spatcor_d_meas_cyl[i,j,*] = xyztocyl(spatcor_d_meas_xyz)
    endfor
  endfor  
  pixelsize=dblarr(8,4)
  for i=0,7 do begin
    for j=0,3 do begin
      if i le 3 then begin
        if j le 1 then begin
          pixelsize[i,j]=distance(spatcor_d_meas_xyz[i,j,0:1],spatcor_d_meas_xyz[i+1,j,0:1])/2.3*$
                         distance(spatcor_d_meas_xyz[i,0,0:2],spatcor_d_meas_xyz[i,1,0:2])/2.3
        endif else begin
          pixelsize[i,j]=distance(spatcor_d_meas_xyz[i,j,0:1],spatcor_d_meas_xyz[i+1,j,0:1])/2.3*$
                         distance(spatcor_d_meas_xyz[i,2,0:2],spatcor_d_meas_xyz[i,3,0:2])/2.3
        endelse
      endif else begin
        if j le 1 then begin
          pixelsize[i,j]=distance(spatcor_d_meas_xyz[i-1,j,0:1],spatcor_d_meas_xyz[i,j,0:1])/2.3*$
                         distance(spatcor_d_meas_xyz[i,0,0:2],spatcor_d_meas_xyz[i,1,0:2])/2.3
        endif else begin
          pixelsize[i,j]=distance(spatcor_d_meas_xyz[i-1,j,0:1],spatcor_d_meas_xyz[i,j,0:1])/2.3*$
                         distance(spatcor_d_meas_xyz[i,2,0:2],spatcor_d_meas_xyz[i,3,0:2])/2.3
        endelse
      endelse
    endfor
  endfor
  
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
    ;spat_xyz_4plot_double[*,67] = nbi_cord_oa_xyz
    
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
    
    loadct,39
    Device, Decomposed=0
    erase
    plot,spat_xyz_4plot_double[0,67:666],spat_xyz_4plot_double[1,67:666], psym=3, linestyle=0, /isotrop,$
         /noerase, xrange=[-2400,2400],yrange=[-2400,2400]
    oplot, spat_xyz_4plot_double[0,0:31],spat_xyz_4plot_double[1,0:31],psym=3, linestyle=0, color=240
    oplot, spat_xyz_4plot_double[0,32:63],spat_xyz_4plot_double[1,32:63],psym=3, linestyle=0, color=80
    oplot, spat_xyz_4plot_double[0,64:65],spat_xyz_4plot_double[1,64:65],psym=3, linestyle=0, color=160
    plots, nbi_cord_oa_cal_xyz[0:1], psym=4, linestyle=0, color=round(11.5*16)
    plots, nbi_cord_oa_xyz[0:1], psym=4, linestyle=0, color=round(11.5*16)
    plots, nbi_cord_oa_xyz[0:1], psym=4, linestyle=0, color=round(11.5*16)
    plots, mirr_cord_oa_xyz[0:1], psym=4, linestyle=0, color=round(10.5*16)
    stop
    
    ;iplot, spat_xyz_4plot_double, linestyle=6, SYM_THICK=2, SYM_INDEX=2, xrange=[-2500,2500],yrange=[-2500,2500],zrange=[-50,50]
    
  endif
  
  detpos=spatcor_d_meas_xyz
  pixarea=pixelsize
  
end

function rot_z, input, point, angle

;///////////////////////////////////////////
; rot_z: rotation around z axis at a given
;        coordinate (point) with alfa angle
;///////////////////////////////////////////
;INPUT:
;       input: coordinate which has to be rotated (3 coordinate vector)
;       point: the rotation is around the z axis
;              going through this point (3 coordinate vector)
;       angle: the angle of the rotation (+ is countercw. and in radians)
;OUTPUT:
;       output:coordinate of the rotated point

  rotm = [[cos(angle), -sin(angle), 0],[sin(angle), cos(angle), 0],[0, 0, 1]]
  transinp = input-point

  output = (rotm ## transinp) + point
  return, output
  
end
  
function xyztocyl, input, inv=inv

;////////////////////////////////////////////////////////////
;                       xyztocyl
;////////////////////////////////////////////////////////////
;This routine returns the cylindrical coordinates
;of a given xyz points and can also do inverse
;transformation
;INPUT:
;       input: xyz or R,z,phi coordinate array
;       /cyltoxyz: set if one wants to do inverse
;OUTPUT:
;       output: R,z,phi or xyz coordinate array, respectively
;////////////////////////////////////////////////////////////

output=dblarr(3)
  if not keyword_set(inv) then begin
    output[0] = sqrt(input[0]^2+input[1]^2+input[2]^2)
    output[1] = input[2]
    output[2] = atan(input[1]/input[0])
  endif else begin
    output[0] = input[0]*cos(input[2])
    output[1] = input[0]*sin(input[2])
    output[2] = input[1]
  endelse
  return, output
  
end

function distance, input1,input2

;////////////////////////////////////////////////////////////
;                      distance
;////////////////////////////////////////////////////////////
;This function gives the distance between to points
;INPUT:
;       input1: a point
;       input2: another point
;OUTPUT:
;       output: the distance between the two points
;////////////////////////////////////////////////////////////

  if (n_elements(input1) ne n_elements(input2)) then return, -1
  output = 0
  for i=0,n_elements(input1)-1 do output += (input1[i]-input2[i])^2
  output = sqrt(output)
  return, output
  
end

function veclength, input

;////////////////////////////////////////////////////////////
;                      distance
;////////////////////////////////////////////////////////////
;This function gives the length of a vector
;INPUT:
;       input: a vector
;
;OUTPUT:
;       output: length of the vector
;////////////////////////////////////////////////////////////

  output=0
  for i=0,n_elements(input)-1 do output += input[i]^2
  output = sqrt(output)
  return, output
  
end

pro calibration, output=output

;////////////////////////////////////////////////////////////
;                      calibration
;////////////////////////////////////////////////////////////
;This procedure performs the calibration from the data gathered
;from the A4 paper 
;INPUT:
;  
;OUTPUT:
;       output: the spatial coordinates of the detectors on the paper
;////////////////////////////////////////////////////////////

  default,mirr_cord_oa_cyl,double([2300,-183,0])    ;from A. Kovacsik 
  default,wall_cord_oa_cyl,double([10,10,10]) ;from Yong Un
  default,nbi_cord_oa_cyl, double([0,0,0])    ;from Yong Un NBI coordinate at optical axis during measurement
  default,plane_mirr_d,2317
  default,focal_length,50 ;focal length of the objective in mm in front of the APDCAM
  default,plot, 1
  
  nbi_cord_oa_cal_cyl = double([1976,3,0]) ; NBI at optical axis  at the calibration measurement coordinate in CYLINDRICAL
  mirr_beam_d = double(2043)
  
  fl_cal = 80 ;the focal length of the objective at the calibration.
  cd, '/media/disk/KFKI/Measurements/KSTAR/Measurement'

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
      spat_cor_p[i,0,1] = corner_cor[0,1,1]+lyres*i              ; fill up the y coordinates for y=0mm
      spat_cor_p[i,yn-1,1] = corner_cor[0,0,1]+hyres*i           ; fill up the y coordinates for y=210mm
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
                     
    spatcor_f = dblarr(2,6,2)
    for i=0,1 do begin
      for j=0,5 do begin
        spatcor_f[i,j,*] = find_pix(pixcor_f[i,j,*],spat_cor_p)
      endfor
    endfor
    
    print, 'Magnification on the x axis: '+ strtrim((abs(spatcor_f[0,1,0]-spatcor_f[1,1,0])/17.7+abs(spatcor_f[0,4,0]-spatcor_f[1,4,0])/17.7)/2,2)
    print, 'Magnification on the Y axis: '+ strtrim((abs(spatcor_f[0,1,1]-spatcor_f[0,4,1])/8.8+abs(spatcor_f[1,1,1]-spatcor_f[1,4,1])/8.8)/2,2)
  
    ;calculate the coordinates for each pixel on the apd array
    spatcor_d = dblarr(8,4,2) ;the spatial coordinates of the detector array 
    pixcor_d = dblarr(8,4,2)  ;the pixel coordinates of the detector array
    
    hps = 0.8   ;half size of the pixel
    gap = 2.3   ;gap between pixels
    gapm = 1.    ;gap in the middle
    arrl = 17.7 ;length of the pixel array horizontally
    arrh = 8.8  ;height of the pixel array vertically BTW: gap+hps*2+gapm=4.9
    radang = (atan(double(pixcor_f[1,1,1]-pixcor_f[1,4,1])/double(pixcor_f[1,4,0]-pixcor_f[1,1,0]))+(atan(double(pixcor_f[0,1,1]-pixcor_f[0,4,1])/double(pixcor_f[0,4,0]-pixcor_f[0,1,0]))))/2 ;angle of the tilt
    angcorrx = arrh/(double(pixcor_f[1,1,1]-pixcor_f[1,4,1])/tan(radang)) ; y distance in mm have to be divided by this to take into account the tilted angle
    angcorry = sin(radang)
    
    for i=0,3 do begin
      for j=0,7 do begin
        if i le 1 then begin
          pixcor_d[j,i,0] = (hps+j*gap+hps/tan(radang))*(pixcor_f[1,1,0]-pixcor_f[0,1,0])/arrl+pixcor_f[0,1,0]+i*gap/angcorrx
          pixcor_d[j,i,1] = pixcor_f[1,1,1]-(hps+i*gap)/arrh*(pixcor_f[1,1,1]-pixcor_f[1,4,1])*angcorry
        endif else begin
          pixcor_d[j,i,0] = (hps+j*gap+hps/tan(radang))/arrl*(pixcor_f[1,1,0]-pixcor_f[0,1,0])+pixcor_f[0,1,0]+(i*gap+gap+hps*2+gapm)/angcorrx
          pixcor_d[j,i,1] = pixcor_f[1,1,1]-(hps+gap+hps*2+gapm+(i-2)*gap)/arrh*(pixcor_f[1,1,1]-pixcor_f[1,4,1])*angcorry
        endelse
        pixcor_d[j,i,*] = fix(pixcor_d[j,i,*])
        spatcor_d[j,i,*] = find_pix(pixcor_d[j,i,*],spat_cor_p)*double(focal_length)/double(fl_cal) ;these are the coordinates of the detector pixels in the voordinate system tied to the paper
      endfor
    endfor
    
    save, spatcor_d, spat_cor_p, filename='cal/spat_cal_'+strtrim(focal_length,2)+'mm.sav'
    output = spatcor_d
end
