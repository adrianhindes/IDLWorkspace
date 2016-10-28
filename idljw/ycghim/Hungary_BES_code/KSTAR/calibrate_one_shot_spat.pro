pro calibrate_one_shot_spat, shot, timerange=timerange, fourcord=fourcord, noweight=noweight, fromimage=fromimage,$
                             datapath=datapath, image_file=image_file, direction=direction, overwrite=overwrite 

;*******************************************************
;**            calibrate_one_shot_spat                **
;*******************************************************
;* This procedure was written in order to ease the     *
;* spatial calibration which needs to be performed for *
;* only one shot.                                      *
;* INPUTs:                                             *
;*   shot: shotnumber                                  *
;*   fourcord: the four pixel coordinates of the       *
;*     fiducial points on the wall [4,2] vector        *
;*     as [[xt,xb,xl,xr],[yt,yb,yl,yr]] t:top b:bottom *
;*   datapath: optional, the path for the BES data     *
;*   image_file: the path for the image file in .sav   *
;*     format. This contains the back illuminated      *
;*     detector image. The image inside needs to be an *
;*     data[*,*] formatted array.                      *
;*   direction: 0:Edge 1:Core1(middle) 2:Core2 (lower) *
;*     default: 0                                      *
;*   nbi_w: weight factors for the nbi depending upon  *
;*     the energy and the power of the NBI             *
;*     default: [0,1,0]                                *
;*   /fromimage: calibrate the shot from an image file *
;*     default: 0                                      *
;*   /overwrite: overwrites the previous calibration   *
;*   
;* OUTPUTs:                                            *
;*  Creates a .sav and .cal file with the calibration  *
;*  data. HDF5 is possible, bot it is not working yet. *
;* KNOWN BUGS:                                         *
;*   
;*******************************************************

default, datapath, local_default('datapath')
default, local_datapath, local_default('local_datapath')
default, window_size, [800,650]
default, direction, 0
default, overwrite, 0
default, fromimage, 0

if not keyword_set(noweight) then begin
  nbi_w=calculate_nbi_w(shot, timerange=timerange, fourcord=fourcord)
endif else begin
  default, nbi_w, [0,1,0]
endelse


if not defined(fourcord) then begin ;this image is for shots after #9110
  fourcord=lonarr(4,2)
  fourcord[0,*]=[660,665]
  fourcord[1,*]=[688,763]
  fourcord[2,*]=[624,722]
  fourcord[3,*]=[724,706]
endif

if keyword_set(fromimage) then begin ;If only the calibration image is present eg. before shot #9110
  restore, image_file
  image_res=[n_elements(data[*,0]),n_elements(data[0,*])]
  
  window, xsize=window_size, ysize=window_size, retain=2
  plot, [0,image_res[0]],[0,image_res[1]],/nodata, xstyle=1, ystyle=1
  corner_pos=lonarr(4,2)
  otv, smooth(data/8<100,5)*5
  print, 'Click on the inner corner of the APD in the following order (bl,br,tr,tl)'
  for i=0,3 do begin
    cursor, x, y, /down, /data
    corner_pos[k,0]=x
    corner_pos[i,1]=y
    print, x, y
  endfor
endif else begin ;if back illuminated detector images are present
  load_config_parameter, shot, 'Optics', 'APDCAMPosition', output_struct=apdpos, errormess=e3
  if e3 ne ''  then begin
    print, 'No apd rotation position available for shot '+strtrim(shot,2)
    return
  endif
  if double(apdpos.value) eq 0 then begin
    print, 'No apd rotation position available for shot '+strtrim(shot,2)
    return
  endif
  apdpos=double(apdpos.value)
  if apdpos eq 30000 then filename='mirror_positions.sav'
  if apdpos eq 12150 then filename='mirror_positions_vertical.sav'
  
  restore, filename
  ;interpolating the mirror_calibration data for a larger set of setting
  n_rad_new = 36
  n_vert_new = 11
  rad_res_new = 2000
  vert_res_new = 5000
  
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

;loading the parameters from the config file

  load_config_parameter, shot, 'Optics', 'MirrorPosition',   output_struct=radpos,  errormess=e1
  if e1 eq '' then begin
    radpos=double(radpos.value)
    vertpos=5000
  endif else begin
  
    load_config_parameter, shot, 'Optics', 'RadialMirrorPosition',   output_struct=radpos,  errormess=e1
    if e1 ne '' then begin
      print, 'No radial position available for shot '+strtrim(shot,2)
      return
    endif
    if double(radpos.value) eq 0 then begin
      print, 'No radial position available for shot '+strtrim(shot,2)
      return
    endif
    radpos=double(radpos.value)
    
    load_config_parameter, shot, 'Optics', 'VerticalMirrorPosition', output_struct=vertpos, errormess=e2
    if e2 ne ''  then begin
      print, 'No vertical position available for shot '+strtrim(shot,2)
      return
    endif
    vertpos=double(vertpos.value)
  endelse
  
  radpos_ind=where(rad_pos eq radpos)
  vertpos_ind=where(vert_pos eq vertpos)
  if radpos_ind eq -1 or vertpos_ind eq -1 then begin
    print, 'The radial position is not in the database!'
    return
  endif
  corner_pos=reform(corner_pos_new[vertpos_ind,radpos_ind,*,*])
endelse

load_config_parameter, shot, 'Optics', 'APDCAMFilter',           output_struct=filter,  errormess=e4
if e4 ne '' then begin
  print, 'No filter data was provided. Deuterium filter is assumed!'
  lithium=0
endif
if (e4 eq '' and filter.value eq 'Lithium') then lithium=1 else lithium=0

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

corner_pos_4x8=dblarr(4,8,2)
for k=0,1 do begin
  corner_pos_4x8[*,*,k]=interpolate(reform(corner_pos[*,*,k]),corner_ind_x, corner_ind_y, /grid)
endfor

calc_nbi_oa, shot=shot, oa_pic=image_res/2, direction=direction, fourcord=fourcord,$
             oa_nbi=oa_nbi, coeff=coeff, lithium=lithium, geom_coord=geom_coord, nbi_w=nbi_w
             
spat_coord_xyz=dblarr(4,8,3)

x=corner_pos_all[*,*,0]
xy=corner_pos_all[*,*,0]*corner_pos_all[*,*,1]
y=corner_pos_all[*,*,1]

spat_coord_xyz[*,*,0]=coeff[0,0]*x + coeff[0,1]*xy + coeff[0,2]*y + coeff[0,3]
spat_coord_xyz[*,*,1]=coeff[1,0]*x + coeff[1,1]*xy + coeff[1,2]*y + coeff[1,3]
spat_coord_xyz[*,*,2]=coeff[2,0]*x + coeff[2,1]*xy + coeff[2,2]*y + coeff[2,3]

spat_coord_rzt=dblarr(n_vert_new,n_rad_new,4,8,3)
nvec_1=geom_coord.m_port_middle_cat/length(geom_coord.m_port_middle_cat)
for i=0,n_vert_new-1 do begin
  for j=0,n_rad_new-1 do begin
    for k=0,3 do begin
      for l=0,7 do begin
        spat_coord_rzt[i,j,k,l,0]=sqrt(spat_coord_xyz[i,j,k,l,0]^2+spat_coord_xyz[i,j,k,l,1]^2)
        spat_coord_rzt[i,j,k,l,1]=spat_coord_xyz[i,j,k,l,2]
        nvec_2=reform(spat_coord_xyz[i,j,k,l,0:1])/length(reform(spat_coord_xyz[i,j,k,l,0:1]))
        nvec_2=[nvec_2[0],nvec_2[1],0]
        cvec=(cross_prod(nvec_1,nvec_2))
        dir=-(cvec/length(cvec))[2]
        spat_coord_rzt[i,j,k,l,2]=acos((transpose(nvec_2) # nvec_1))*dir
      endfor
    endfor
  endfor
endfor

detpos=spat_coord_rzt
 
if keyword_set(fromimage) then begin
  filename_sav=dir_f_name(datapath,strtrim(shot,2)+'.spat.sav')
endif else begin
  filename_sav=dir_f_name(local_datapath,strtrim(shot,2)+'.spat.sav')
endelse
if file_test(filename_sav) and not overwrite then begin
  print, 'The calibration sav file exists for shot '+strtrim(shot,2)+'! If you want to overwrite use /overwrite switch!'
  return
endif else begin
  save, detpos, filename=dir_f_name(datapath,dir_f_name(strtrim(shot,2),strtrim(shot,2)+'.spat.sav'))
endelse

if keyword_set(fromimage) then begin
  filename_cal=dir_f_name(datapath,dir_f_name(strtrim(shot,2),strtrim(shot,2)+'.spat.cal'))
endif else begin
  filename_cal=dir_f_name(local_datapath,dir_f_name(strtrim(shot,2),strtrim(shot,2)+'.spat.cal'))
endelse

if overwrite then begin
  ;read, 'Do you want to delete and make a new calibration table for shot '+strtrim(shot,2)+'? (0:no,1:yes)',bl
  if (file_test(filename_cal)) then begin
    if (strupcase(!version.os) eq 'WIN32') then cmd = 'del '+filename_cal
    if (strupcase(!version.os) eq 'LINUX') then cmd = 'rm -f '+filename_cal
    spawn,cmd
  endif
endif else begin
  if (file_test(filename_cal)) then begin
    print, 'Calibration file for shot '+strtrim(shot,2)+' exists. If you want to overwrite use /overwrite switch!'
    return
  endif
endelse

openw,unit_w,filename_cal,/get_lun,error=error
if (error eq 0) then begin
    channels = strarr(4,8)
  txt = ''
  for i=0,3 do begin
    for j=0,7 do begin
      channels[i,j] = 'BES-'+i2str(i+1)+'-'+i2str(j+1)
      txt = txt+' '+channels[i,j]
    endfor
  endfor
  printf,unit_w,txt
  
  txt_new = i2str(shot)+' R '
  for i=0,3 do begin
    for j=0,7 do begin
      txt_new = txt_new+' '+string(float(detpos[i,j,0]),format='(F12)')
    endfor
  endfor
  printf,unit_w,txt_new
  
  txt_new = i2str(shot)+' Phi '
  for i=0,3 do begin
    for j=0,7 do begin
      txt_new = txt_new+' '+string(float(detpos[i,j,2]),format='(F12)')
    endfor
  endfor
  printf,unit_w,txt_new
  
  txt_new = i2str(shot)+' z '
  for i=0,3 do begin
    for j=0,7 do begin
      txt_new = txt_new+' '+string(float(detpos[i,j,1]),format='(F12)')
    endfor
  endfor
  printf,unit_w,txt_new
  print, 'Calibration file is written:  '+filename_cal+' !'
  close,unit_w & free_lun,unit_w
endif else begin
  print, 'Error opening file for write!'
  close,unit_w & free_lun,unit_w
endelse

;generating a HDF5 calibration file

fname=dir_f_name(datapath,dir_f_name(strtrim(shot,2),strtrim(shot,2)+'.spat.h5'))
calib_data=dblarr(32,4,8,3)
ch_name=strarr(32)
ch_file_name=strarr(32)

;HDF5 filewrite

for i=1,4 do begin
  for j=1,8 do begin
    channel='BES-'+strtrim(i,2)+'-'+strtrim(j,2)
    ch_name[(i-1)*3+(j-1)]=channel
    if (i-1)*3+(j-1) lt 10 then begin
      ch_file_name='Channel0'+strtrim((i-1)*3+(j-1),2)+'.dat'
    endif else begin
      ch_file_name='Channel'+strtrim((i-1)*3+(j-1),2)+'.dat'
    endelse
    calib_data[(i-1)*3+(j-1),i-1,j-1,*]=detpos[i-1,j-1,*]
  endfor
endfor

;struct={name:shot,calib_data:calib_data,ch_name:ch_name,ch_file_name:ch_file_name,comment:'Spatial calibration data of the shot'}
;fileid=h5f_create(fname)
;datatypeID=h5t_idl_create(struct)
;dataspaceID=h5s_create_simple(1)
;datasetid=h5d_create(fileid,shot,datatypeid,dataspaceid)
;h5d_write,datasetid,struct
;h5f_close,fileid

print, 'Calibration for '+strtrim(shot,2)+' shot is done!'
end