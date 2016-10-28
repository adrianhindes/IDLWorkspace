pro calibrate_cmos_image_oneshot, shot=shot, lithium=lithium, direction=direction, vertical=vertical, fourcord=fourcord, $
                                  ps=ps, visual=visual, all=all, save=save, nbi_w=nbi_w,$
                                  spat_cord_rzt=spat_cord_rzt

;*************************************************
;**         calibrate_cmos_image_oneshot        **
;*************************************************
;* This calibration is only good for shots       *
;* after 9110. Do not use this for shots         *
;* before this.                                  *
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
  
  default, shot, 11104
  default, save, 0
  default, vertical,0
  default, calib_file_name, i2str(shot)+'_CMOS_data_calib.sav'
  default, datapath, dir_f_name(local_default('datapath'),i2str(shot))
  ;The following fourcord was read from the file 11104_CMOS_data.sav file
  loadct, 0
  image_size=[1312,1082]
  if not defined(fourcord) then begin
     fourcord=lonarr(4,2)
     if shot lt (10000) then begin
        fourcord[0,*]=[660,665] ;top
        fourcord[1,*]=[688,763] ;bottom
        fourcord[2,*]=[624,722] ;left
        fourcord[3,*]=[724,706] ;right
     endif else begin           ;The following fourcord was read from the file 11104_CMOS_data.sav file, image reversed
        fourcord[0,*]=[553,721] ; top
        fourcord[1,*]=[595,828] ; bottom
        fourcord[2,*]=[526,792] ;left
        fourcord[3,*]=[624,756] ;right
     endelse
  endif

  if shot lt 10000 then begin
     otv, reform(meas[0,*,*]), /plot
;     plot, [0,image_size[0]],[0,image_size[1]],/nodata, xstyle=1, ystyle=1
     if not v then begin
        print, 'Click on the inner corner of the APD in the following order (bl,br,tr,tl)'
     endif else begin
        print, 'Click on the inner corner of the APD in the following order (br,tr,tl,bl)'
     endelse
     corner_pos=dblarr(4,2)
     for k=0,3 do begin
        cursor, x, y, /down, /data
        corner_pos[k,0]=x
        corner_pos[k,1]=y
        print, x, y
     endfor


     hps = 0.8                  ;half size of the pixel
     gap = 2.3                  ;gap between pixels
     gapm = 2.6                 ;gap in the middle
     arrl = 17.7                ;length of the pixel array horizontally
     arrh = 8.8                 ;height of the pixel array vertically BTW: gap+hps*2+gapm=4.9
     
     corner_ind_x=dblarr(8)
     corner_ind_y=dblarr(4)
     
     for i=0,7 do begin
        corner_ind_x[i]=(hps+i*gap)/(2*hps+7*gap)
     endfor
     
     for j=0,3 do begin
        if j le 1 then dist=(hps+j*gap)/(2*hps+2*gap+gapm) else dist=(hps+(j-1)*gap+gapm)/(2*hps+2*gap+gapm)
        corner_ind_y[j]=dist
     endfor
     
     corner_pos=dblarr(4,8,2)
     
     for k=0,1 do begin
        corner_pos_all[*,*,k]=transpose(interpolate(reform(corner_pos_new[*,*,k]),corner_ind_x, corner_ind_y, /grid))
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
     spat_cord_rz=dblarr(4,8,2)
     spat_cord_xyz=dblarr(4,8,3)
     x=corner_pos_all[*,*,0]
     xy=corner_pos_all[*,*,0]*corner_pos_all[*,*,1]
     y=corner_pos_all[*,*,1]
     
     spat_cord_xyz[*,*,0]=coeff[0,0]*x + coeff[0,1]*xy + coeff[0,2]*y + coeff[0,3]
     spat_cord_xyz[*,*,1]=coeff[1,0]*x + coeff[1,1]*xy + coeff[1,2]*y + coeff[1,3]
     spat_cord_xyz[*,*,2]=coeff[2,0]*x + coeff[2,1]*xy + coeff[2,2]*y + coeff[2,3]
     
     spat_cord_rz[*,*,0]=sqrt((spat_cord_xyz[*,*,1])^2+(spat_cord_xyz[*,*,0])^2)
     spat_cord_rz[*,*,1]=spat_cord_xyz[*,*,2]
     
                                ;The following section calculates the toroidal angle from the M-port's center
     
     spat_cord_rzt=dblarr(4,8,3)
     nvec_1=geom_coord.m_port_middle_cat/length(geom_coord.m_port_middle_cat)
     for k=0,3 do begin
        for l=0,7 do begin
           spat_cord_rzt[k,l,0]=sqrt(spat_cord_xyz[k,l,0]^2+spat_cord_xyz[k,l,1]^2)
           spat_cord_rzt[k,l,1]=spat_cord_xyz[k,l,2]
           nvec_2=reform(spat_cord_xyz[k,l,0:1])/length(reform(spat_cord_xyz[k,l,0:1]))
           nvec_2=[nvec_2[0],nvec_2[1],0]
           cvec=(cross_prod(nvec_1,nvec_2))
           dir=-(cvec/length(cvec))[2]
           spat_cord_rzt[k,l,2]=acos((transpose(nvec_2) # nvec_1))*dir
        endfor
     endfor
     
     
  endif else begin              ;If shot gt 10000 then ...
     calib_file=dir_f_name(local_default('datapath'),dir_f_name(i2str(shot),i2str(shot)+'_CMOS_data_calib.sav'))
     if file_test(calib_file) then begin
        led_coord=find_apd_leds_calib(shot,150)
        if n_elements(led_coord[*,0]) ne 5 then begin
           print, 'lofasz'
           led_coord=find_apd_leds_calib(shot,200)
        endif
        
        bl=''
        read, 'Are the LEDs identified? (y/n)', bl
        
        if bl ne 'y' then begin
           restore, calib_file
           otv, reverse(reform(meas[0,*,*]),2)/16, /plot
           print, "Click on the center of the LEDs in the following order (tl tm tr bm br)"
           led_coord=dblarr(6,2)
           for i=0,4 do begin
              cursor, x, y, /down
              led_coord[i,*]=[x,y]
           endfor
        endif else begin
           led_coord_new=dblarr(6,2)
           led_coord_new[0,*]=led_coord[0,*]
           led_coord_new[1,*]=led_coord[2,*]
           led_coord_new[2,*]=led_coord[4,*]
           led_coord_new[3,*]=led_coord[1,*]
           led_coord_new[4,*]=led_coord[3,*]
           led_coord=led_coord_new
        endelse   
        
        led_coord[4:5,*]=led_coord[3:4,*]
        led_coord[3,0]=led_coord[0,0]-((led_coord[1,0]-led_coord[4,0])+(led_coord[2,0]-led_coord[5,0]))/2
        led_coord[3,1]=led_coord[0,1]-((led_coord[2,1]-led_coord[5,1])+(led_coord[1,1]-led_coord[4,1]))/2
        
        hldy = 10.9-5.6         ;Distance from LED middle to detector side
        hps = 0.8               ;half size of the pixel
        gap = 2.3               ;gap between pixels
        gap_x = 1.7             ;gap between side of the detector and pixel middle in x direction
        gap_y = 2.0             ;gap between side of the detector and pixel middle in y direction
        gapm_y = 2.6            ;gap in the middle
        arrl = 17.7             ;length of the pixel array horizontally
        arrh = 8.8              ;height of the pixel array vertically BTW: gap+hps*2+gapm=4.9
        
        ind_x=dblarr(16)
        ind_y=dblarr(4)
        full_dist_x=(gap_x+7*gap+gap_x*2+7*gap+gap_x)
        for i=0,15 do begin
          if i lt 8 then begin
            ind_x[i]=(gap_x+i*gap)/full_dist_x
          endif else begin
            ind_x[i]=(gap_x+(i-1)*gap+gap_x*2)/full_dist_x
          endelse
        endfor
        
        full_dist_y=(hldy+gap_y+gap+gapm_y+gap+gap_y+hldy)
        for j=0,3 do begin
           if j le 1 then dist=(hldy+gap_y+j*gap)/full_dist_y else dist=(hldy+gap_y+(j-1)*gap+gapm_y)/full_dist_y
           ind_y[j]=dist
        endfor
        
        corner_pos=dblarr(4,16,2)
        
        ledpos=dblarr(2,2,2)
        ledpos[0,0,*]=led_coord[0,*]
        ledpos[0,1,*]=led_coord[2,*]
        ledpos[1,0,*]=led_coord[3,*]
        ledpos[1,1,*]=led_coord[5,*]
        
        for k=0,1 do begin
           corner_pos[*,*,k]=interpolate(reform(ledpos[*,*,k]),ind_y, ind_x, /grid)
        endfor        
        corner_pos=reverse(reverse(corner_pos, 2),1)
        loadct, 5
        for i=0,3 do begin
          for j=0,15 do begin
            plots, corner_pos[i,j,0], corner_pos[i,j,1], psym=4, color=(i*16+j)*5, thick=2
          endfor
        endfor
        
       calc_nbi_oa, oa_pic=[1312,1082]/2, direction=0, fourcord=fourcord, $
                    oa_nbi=oa_nbi, coeff=coeff, lithium=lithium, geom_coord=geom_coord,$
                    nbi_w=nbi_w
                    
       spat_cord_rz=dblarr(4,16,2)
       spat_cord_xyz=dblarr(4,16,3)
       x=corner_pos[*,*,0]
       xy=corner_pos[*,*,0]*corner_pos[*,*,1]
       y=corner_pos[*,*,1]

       spat_cord_xyz[*,*,0]=coeff[0,0]*x + coeff[0,1]*xy + coeff[0,2]*y + coeff[0,3]
       spat_cord_xyz[*,*,1]=coeff[1,0]*x + coeff[1,1]*xy + coeff[1,2]*y + coeff[1,3]
       spat_cord_xyz[*,*,2]=coeff[2,0]*x + coeff[2,1]*xy + coeff[2,2]*y + coeff[2,3]
       
       spat_cord_rz[*,*,0]=sqrt((spat_cord_xyz[*,*,1])^2+(spat_cord_xyz[*,*,0])^2)
       spat_cord_rz[*,*,1]=spat_cord_xyz[*,*,2]
       
                                    ;The following section calculates the toroidal angle from the M-port's center
       
       spat_cord_rzt=dblarr(4,16,3)
       nvec_1=geom_coord.m_port_middle_cat/length(geom_coord.m_port_middle_cat)
       for k=0,3 do begin
          for l=0,15 do begin
             spat_cord_rzt[k,l,0]=sqrt(spat_cord_xyz[k,l,0]^2+spat_cord_xyz[k,l,1]^2)
             spat_cord_rzt[k,l,1]=spat_cord_xyz[k,l,2]
             nvec_2=reform(spat_cord_xyz[k,l,0:1])/length(reform(spat_cord_xyz[k,l,0:1]))
             nvec_2=[nvec_2[0],nvec_2[1],0]
             cvec=(cross_prod(nvec_1,nvec_2))
             dir=-(cvec/length(cvec))[2]
             spat_cord_rzt[k,l,2]=acos((transpose(nvec_2) # nvec_1))*dir
          endfor
       endfor
          
       
    endif else begin
       print, 'No calibration file was found. Returning...'
       return
    endelse
  endelse
  stop
end 
