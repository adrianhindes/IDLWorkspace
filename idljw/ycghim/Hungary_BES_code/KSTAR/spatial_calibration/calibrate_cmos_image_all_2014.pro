pro calibrate_cmos_image_all_2014
  restore, 'calibration.image.database.2014.sav'
  n=n_elements(database)
  spat_database={radpos:long(1),vertpos:long(1),apdpos:long(1),spat_coord:dblarr(4,16,3),li_filter:long(0)}
  spat_database=replicate(spat_database,2*n)
  spat_database[n:2*n-1].li_filter=1
  led_coord=dblarr(n,6,2)
  fourcord=dblarr(4,2)
  fourcord[0,*]=[553,721] ; top
  fourcord[1,*]=[595,828] ; bottom
  fourcord[2,*]=[526,792] ;left
  fourcord[3,*]=[624,756] ;right
  
  filename_spat_database='spatial_coordinate_database_2014.sav'
  for j1=0,1 do begin
    for i1=0,n-1 do begin
      if not file_test(filename_spat_database) then begin 
        otv, reverse(database[i1].image,2)/16, /plot
        print, "Click on the center of the LEDs in the following order (tl tm tr bm br)"
  
        for i=0,4 do begin
           cursor, x, y, /down
           n_box=200.
           box_new=(reverse(database[i1].image,2))[x-n_box/2:x+n_box/2-1,y-n_box/2:y+n_box/2-1]
           if max(box_new) eq 4095 then begin
             box_new=box_new-round(mean(box_new))-sqrt(variance(box_new))*2>0
             x_weight=0
             y_weight=0
             
             intensity=total(double(box_new))
             for i2=0.,n_box-2 do begin
                for j2=0.,n_box-2 do begin
                   x_weight+=double(box_new[i2,j2])*i2/intensity
                   y_weight+=double(box_new[i2,j2])*j2/intensity
                endfor
             endfor
             
             led_coord[i1,i,*]=[x+round(x_weight)-n_box/2,y+round(y_weight)-n_box/2]
           endif else begin
              led_coord[i1,i,*]=[x,y]
           endelse 
           plots, led_coord[i1,i,0], led_coord[i1,i,1], psym=4, color=80
         endfor
       
         led_coord[i1,4:5,*]=led_coord[i1,3:4,*]
         led_coord[i1,3,0]=led_coord[i1,0,0]-((led_coord[i1,1,0]-led_coord[i1,4,0])+(led_coord[i1,2,0]-led_coord[i1,5,0]))/2
         led_coord[i1,3,1]=led_coord[i1,0,1]-((led_coord[i1,2,1]-led_coord[i1,5,1])+(led_coord[i1,1,1]-led_coord[i1,4,1]))/2
       endif else begin
          if j1 eq 0 and i1 eq 0 then begin
            restore, filename_spat_database
            n=n_elements(database)
            spat_database={radpos:long(1),vertpos:long(1),apdpos:long(1),spat_coord:dblarr(4,16,3),li_filter:long(0)}
            spat_database=replicate(spat_database,2*n)
            spat_database[n:2*n-1].li_filter=1
          endif
       endelse
        
       hldy = 10.9-5.6            ;Distance from LED middle to detector side
       hps = 0.8                  ;half size of the pixel
       gap = 2.3                  ;gap between pixels
       gap_x = 1.7                ;gap between side of the detector and pixel middle in x direction
       gap_y = 2.0                ;gap between side of the detector and pixel middle in y direction
       gapm_y = 2.6               ;gap in the middle
       arrl = 17.7                ;length of the pixel array horizontally
       arrh = 8.8                 ;height of the pixel array vertically BTW: gap+hps*2+gapm=4.9
       
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
       ledpos[0,0,*]=led_coord[i1,0,*]
       ledpos[0,1,*]=led_coord[i1,2,*]
       ledpos[1,0,*]=led_coord[i1,3,*]
       ledpos[1,1,*]=led_coord[i1,5,*]
       
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
  
       if j1 then lithium=1 else lithium=0
       
       calc_nbi_oa, oa_pic=[1312,1082]/2, direction=0, fourcord=fourcord, $
                    oa_nbi=oa_nbi, coeff=coeff, lithium=lithium, geom_coord=geom_coord,$
                    nbi_w=nbi_w
                    if lithium then stop
       if j1 then coeff_li=coeff else coeff_d=coeff 
       
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
       wait, 1
       spat_database[j1*n+i1].spat_coord=spat_cord_rzt
       spat_database[j1*n+i1].radpos=database[i1].radpos
       spat_database[j1*n+i1].vertpos=database[i1].vertpos
       spat_database[j1*n+i1].apdpos=database[i1].apdpos
       spat_database[j1*n+i1].li_filter=j1
       
    endfor
  endfor
save, spat_database, led_coord, fourcord, coeff_d, coeff_li,  filename=filename_spat_database
stop
end
