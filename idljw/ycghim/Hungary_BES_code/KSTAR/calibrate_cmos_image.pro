pro calibrate_cmos_image, lithium=lithium, direction=direction, vertical=vertical, fourcord=fourcord, $
                          ps=ps, visual=visual, all=all, save=save, nbi_w=nbi_w

;*************************************************
;**         calibrate_cmos_image                **
;*************************************************
;* This calibration is only good for shots       *
;* over 9110. Do not use this for shots          *
;* below this.                                   *
;*************************************************
;*                                               *
;*INPUTs:                                        *
;*  /lithium: if set, it calculates for the      *
;*    lithium beam.                              *
;*  direction: only used, if the front mirror    *
;*    was set to core. 0: edge measurement       *
;*                     1: I port mid             *
;*                     2: I port lower           *
;*  /vertical: the apd was rotated to vertical   *
;*  fourcord: the four coordinates of the        *
;*    fiducial points on the wall in pixels      *
;*                                               *
;*  /ps: create a postscript file from /visual   *
;*  /visual: create a plot for checking the      *
;*     geometry                                  *
;*  /save: save the results to a .sav file       *
;*  /all: do the calibration for all             *
;*        lithium/deuterium, horizontal/vertical *
;*        setting                                *
;*************************************************

  default, save, 0
  default, vertical,0
  default, calib_file_name, 'final.calibration.sav'
  default, directory, 'D:\KFKI\Measurements\KSTAR\Measurement'

if keyword_set(all) then begin
  calibrate_cmos_image, /lithium, /save
  restore, '2013_calibration_a9110_Li.sav'
  data_li_hori=data
  
  calibrate_cmos_image, /save
  restore, '2013_calibration_a9110_Da.sav'
  data_da_hori=data
  
  calibrate_cmos_image, /lithium, /vertical, /save
  restore, '2013_calibration_a9110_Li_vertical.sav'
  data_li_vert=data
  
  calibrate_cmos_image, /vertical, /save
  restore, '2013_calibration_a9110_Da_vertical.sav'
  data_da_vert=data
  
  save, data_da_hori, data_da_vert, data_li_hori, data_li_vert, filename='calibration_2013_a9110.sav'
  return
endif
  
  if not defined(fourcord) then begin
    fourcord=lonarr(4,2)
    fourcord[0,*]=[660,665]
    fourcord[1,*]=[688,763]
    fourcord[2,*]=[624,722]
    fourcord[3,*]=[724,706]
  endif
  if keyword_set(vertical) then begin
    filename='mirror_positions_vertical.sav'
  endif else begin
    filename='mirror_positions.sav'
  endelse

  cd, directory
  if file_test(filename) then begin
    restore, filename
    n_rad  = n_elements(rad_pos)
    n_vert = n_elements(vert_pos)
  endif else begin
    restore, calib_file_name
    v=vertical
    n_rad  = n_elements(rad_pos)
    n_vert = n_elements(vert_pos)
    window, xsize=800, ysize=650, retain=2
    plot, [0,1312],[0,1082],/nodata, xstyle=1, ystyle=1
    corner_pos=lonarr(n_vert,n_rad,4,2)
    for i=0,n_vert-1 do begin
      for j=3,n_rad-1 do begin
        otv, smooth(data[i,j,v].image/8<100,5)*5
        if not v then begin
          print, 'Click on the inner corner of the APD in the following order (bl,br,tr,tl)'
        endif else begin
          print, 'Click on the inner corner of the APD in the following order (br,tr,tl,bl)'
        endelse
        for k=0,3 do begin
          cursor, x, y, /down, /data
          corner_pos[i,j,k,0]=x
          corner_pos[i,j,k,1]=y
          print, x, y
        endfor
      endfor
    endfor
    apd_rot_pos=apd_rot[v]
      
    ;Corner positions are not available for 20000 position, thus it needs to be !!extrapolated!!
    p=dblarr(6,4,2,2)
    pm=dblarr(4,2,2)
    for i=0,5 do begin
      for j=0,3 do begin
        for k=0,1 do begin
           slope=(corner_pos[i,3,j,k]-corner_pos[i,4,j,k])/(rad_pos[3]-rad_pos[4])
           p[i,j,k,*]=mpfitfun('linear_fit',rad_pos[3:7],reform(corner_pos[i,3:7,j,k]),0.01,[corner_pos[i,3,j,k],slope])
           for l=0,2 do corner_pos[i,l,j,k]=p[i,j,k,0]+p[i,j,k,1]*rad_pos[l]
        endfor
      endfor
    endfor
    
    save, corner_pos, rad_pos, vert_pos, apd_rot_pos, filename=filename
  endelse
    
  n_rad_new = 36
  n_vert_new = 11
  rad_res_new=2000
  vert_res_new=5000
  
  ;2nd order surface fitting on both x and y coordinates
  
  vert_pos_new   = dindgen(n_vert_new)*vert_res_new
  rad_pos_new    = dindgen(n_rad_new)*rad_res_new
  
  vert_pos_ind = dindgen(n_vert_new)/double(n_vert_new-1)*5
  rad_pos_ind  = dindgen(n_rad_new)/double(n_rad_new-1)*7
  corner_pos_new = dblarr(n_vert_new,n_rad_new,4,2)
  for k=0,3 do begin
    for l=0,1 do begin
      corner_pos_new[*,*,k,l]=interpolate(reform(corner_pos[*,*,k,l]), vert_pos_ind, rad_pos_ind, /grid)
    endfor
  endfor
  
  temp=corner_pos_new
  corner_pos_new=dblarr(n_vert_new,n_rad_new,2,2,2)
  
  corner_pos_new[*,*,0,0,*]=temp[*,*,0,*]
  corner_pos_new[*,*,0,1,*]=temp[*,*,3,*]
  corner_pos_new[*,*,1,0,*]=temp[*,*,1,*]
  corner_pos_new[*,*,1,1,*]=temp[*,*,2,*]
  
  hps = 0.8   ;half size of the pixel
  gap = 2.3   ;gap between pixels
  gapm = 2.6    ;gap in the middle
  arrl = 17.7 ;length of the pixel array horizontally
  arrh = 8.8  ;height of the pixel array vertically BTW: gap+hps*2+gapm=4.9
  
  corner_ind_x=dblarr(8)
  corner_ind_y=dblarr(4)
  
  for i=0,7 do begin
    corner_ind_x[i]=(hps+i*gap)/(2*hps+7*gap)
  endfor
  
  for j=0,3 do begin
    if j le 1 then dist=(hps+j*gap)/(2*hps+2*gap+gapm) else dist=(hps+(j-1)*gap+gapm)/(2*hps+2*gap+gapm)
    corner_ind_y[j]=dist
  endfor
  
  corner_pos_all=dblarr(n_vert_new,n_rad_new,4,8,2)
  
  for i=0,n_elements(vert_pos_new)-1 do begin
    for j=0,n_elements(rad_pos_new)-1 do begin
      for k=0,1 do begin
        corner_pos_all[i,j,*,*,k]=transpose(interpolate(reform(corner_pos_new[i,j,*,*,k]),corner_ind_x, corner_ind_y, /grid))
      endfor
    endfor
  endfor
calc_nbi_oa, oa_pic=[1312,1082]/2, direction=0, fourcord=fourcord, $
             oa_nbi=oa_nbi, coeff=coeff, lithium=lithium, geom_coord=geom_coord,$
             nbi_w=nbi_w


if keyword_set(lithium) then begin
  save, fourcord, oa_nbi, coeff, filename='spat_cal_factors_Li.sav'
endif else begin
  save, fourcord, oa_nbi, coeff, filename='spat_cal_factors_Da.sav' 
endelse

;[r,z]
  spat_cord_rz=dblarr(n_vert_new,n_rad_new,4,8,2)
  spat_cord_xyz=dblarr(n_vert_new,n_rad_new,4,8,3)
if keyword_set(lineat) then begin
  for i=0,1 do spat_cord_rz[*,*,*,*,i]=pix2cord_p[i,0]+pix2cord_p[i,1]*corner_pos_all[*,*,*,*,i]
endif else begin
  x=corner_pos_all[*,*,*,*,0]
  xy=corner_pos_all[*,*,*,*,0]*corner_pos_all[*,*,*,*,1]
  y=corner_pos_all[*,*,*,*,1]
 
  spat_cord_xyz[*,*,*,*,0]=coeff[0,0]*x + coeff[0,1]*xy + coeff[0,2]*y + coeff[0,3]
  spat_cord_xyz[*,*,*,*,1]=coeff[1,0]*x + coeff[1,1]*xy + coeff[1,2]*y + coeff[1,3]
  spat_cord_xyz[*,*,*,*,2]=coeff[2,0]*x + coeff[2,1]*xy + coeff[2,2]*y + coeff[2,3]

  spat_cord_rz[*,*,*,*,0]=sqrt((spat_cord_xyz[*,*,*,*,1])^2+(spat_cord_xyz[*,*,*,*,0])^2)
  spat_cord_rz[*,*,*,*,1]=spat_cord_xyz[*,*,*,*,2]
endelse

;The following section calculates the toroidal angle from the M-port's center

spat_cord_rzt=dblarr(n_vert_new,n_rad_new,4,8,3)
nvec_1=geom_coord.m_port_middle_cat/length(geom_coord.m_port_middle_cat)
for i=0,n_vert_new-1 do begin
  for j=0,n_rad_new-1 do begin
    for k=0,3 do begin
      for l=0,7 do begin
        spat_cord_rzt[i,j,k,l,0]=sqrt(spat_cord_xyz[i,j,k,l,0]^2+spat_cord_xyz[i,j,k,l,1]^2)
        spat_cord_rzt[i,j,k,l,1]=spat_cord_xyz[i,j,k,l,2]
        nvec_2=reform(spat_cord_xyz[i,j,k,l,0:1])/length(reform(spat_cord_xyz[i,j,k,l,0:1]))
        nvec_2=[nvec_2[0],nvec_2[1],0]
        cvec=(cross_prod(nvec_1,nvec_2))
        dir=-(cvec/length(cvec))[2]
        spat_cord_rzt[i,j,k,l,2]=acos((transpose(nvec_2) # nvec_1))*dir
      endfor
    endfor
  endfor
endfor



description={spat_cord:'Spatial coordinates of the detector pixels [R,z,theta]',$
             pix2cord_p:'Pixel to spatial coordinate transformation coefficients',$
             coeff:'Pixel to spatial coordinate bilinear coefficients x=c00*px+c01*px*py+c02*py+c03, y=c10*px+...',$
             vert_pos:'Vertical stepmotor positions',$
             rad_pos:'Radial positions: [40000-70000]',$
             info:'The positions are in the coordinate system of the KSTAR CATIA model. These should be rotated into the correct geometry used for the analysis',$
             software:'Created by calibrate_cmos_image.pro'}

oa_nbi=dblarr(n_rad_new,2)
i=10
for j=0,n_rad_new-1 do begin
  oa_nbi[j,0]=rad_pos_new[j]
  oa_nbi[j,1]=(spat_cord_rzt[i,j,2,3,0]+spat_cord_rzt[i,j,3,3,0]+spat_cord_rzt[i,j,2,4,0]+spat_cord_rzt[i,j,3,4,0])/4.
endfor

x=oa_nbi[*,0]
y=oa_nbi[*,1]

p=mpfitfun('linear_fit',x[20:35],y[20:35],0.01,[y[20],5e-3])
oa_nbi[0:20,1]=p[0]+p[1]*oa_nbi[0:20,0]

data={spat_cord:spat_cord_rzt, coeff:coeff, vert_pos:vert_pos_new, $
      rad_pos:rad_pos_new, oa_nbi:oa_nbi, description:description}
      
if keyword_set(vertical) then begin
  if keyword_set(lithium) then begin
    if keyword_set(save) then save, data, filename='2013_calibration_a9110_Li_vertical.sav'
  endif else begin
    if keyword_set(save) then save, data, filename='2013_calibration_a9110_Da_vertical.sav'
  endelse
endif else begin      
  if keyword_set(lithium) then begin
    if keyword_set(save) then save, data, filename='2013_calibration_a9110_Li.sav'
  endif else begin
    if keyword_set(save) then save, data, filename='2013_calibration_a9110_Da.sav'
  endelse
endelse

if keyword_set(visual) then begin
  
  mirror_center = [66.5,2732.4,-253] ;from somewhere [where M-port center is at °0 toroidal angle]
  
   a_point_nbi_xyz=geom_coord.a_point_nbi_cat
   b_point_nbi_xyz=geom_coord.b_point_nbi_cat
   a_point_li_xyz=geom_coord.a_point_li_cat
   b_point_li_xyz=geom_coord.b_point_li_cat
   principal_ray_point=geom_coord.principal_ray_point
   
  ;trial tokamak for visualisation
  R1 = 1.3*1000
  R2 = 2.3*1000
  ;R2 = 1976.
  n_sep=1000.
  sep_out = dblarr(2,n_sep)
  sep_in = dblarr(2,n_sep)
  fi = dindgen(n_sep)/n_sep*2*!pi
  sep_in[0,*]=r1*cos(fi)
  sep_in[1,*]=r1*sin(fi)
  sep_out[0,*]=r2*cos(fi)
  sep_out[1,*]=r2*sin(fi)
  
  device, decomposed=0
  loadct, 5
  erase
  plot,sep_in[0,*],sep_in[1,*], /isotrop,$
           /noerase, xrange=[-2400,2400],yrange=[-2400,2400], thick=3, charsize=2,$
           xtitle='x [mm]', ytitle='y [mm]', title='Beam geometry', position=[0.05,0.05,1,0.9]
  oplot,sep_out[0,*],sep_out[1,*], thick=3
  oplot, [a_point_nbi_xyz[0],b_point_nbi_xyz[0]],$
         [a_point_nbi_xyz[1],b_point_nbi_xyz[1]], color=120
  
  oplot, [a_point_li_xyz[0],b_point_li_xyz[0]],$
         [a_point_li_xyz[1],b_point_li_xyz[1]], color=160
  
  plots, reform(spat_cord_xyz[*,*,*,*,0],1,n_elements(spat_cord_xyz[*,*,*,*,0])),$
         reform(spat_cord_xyz[*,*,*,*,1],1,n_elements(spat_cord_xyz[*,*,*,*,1])),psym=4, color=160 
  plots, principal_ray_point[0:1], psym=4, color=200
  stop
  rpos=66000
  zpos=10000

  rad_ind=where(data.rad_pos eq rpos)
  vert_ind=where(data.rad_pos eq zpos)
  if rad_ind[0] eq -1 then begin
    print, 'The radial coordinate is not in the database!'
    return
    endif
  if vert_ind[0] eq -1 then begin
    print, 'The vertical coordinate is not in the database!'
    return
  endif

  det_pos=reform(data.spat_cord[vert_ind,rad_ind,*,*,*])

  default,nlevels,100
  default,rrange,[1.3,2.4]
  default,zrange,[-1.1,1.1]
  default, shot, 9411
  default, time, 3.55
  device, decomposed=0
  flux = get_kstar_efit(shot,time,errormess=errormess,/silent)
  if (errormess ne '') then begin
    if (not keyword_set(silent)) then print,errormess
    return
  endif

    contour,flux.psi,flux.r,flux.z,xrange=rrange,xstyle=1,xtitle='R [m]',nlevels=nlevels,$
            yrange=zrange,ystyle=1,ytitle='Z [m]',isotropic=isotropic,thick=thick,xthick=thick,$
            ythick=thick,charthick=thick,charsize=charsize,/noerase,title=i2str(shot)+'  '+string(time,format='(F5.2)')+'s',/nodata,$
            position=[0.66,0.05,0.9,0.9]
    
    contour,flux.psi,flux.r,flux.z,nlevels=nlevels,thick=thick,/noerase,/over
    for i=0,3 do begin
      for j=0,7 do begin
        plots, det_pos[i,j,0]/1e3,det_pos[i,j,1]/1e3, psym=4, color=120
      endfor
    endfor  
  
endif
end 
