pro find_apd_leds_calib, shot, n_box
  image_size=[1312.,1082.]
  default, n_box, 200.
  default, datapath, '~/Data/'
  filename=dir_f_name(datapath,dir_f_name(i2str(shot),i2str(shot)+'_CMOS_data_calib.sav'))
  if file_test(filename) then begin
     restore, filename
  endif else begin
     print, 'Calibration file cannot be found!'
     return
  endelse
  ;Finding the 5 LEDs on the image -> approximate place 
  image=smooth(reform(meas[0,*,*]),10)
  led_coord=lonarr(1,2)
  n_found=0
  for i=0,round(image_size[0]/n_box)-2 do begin
     for j=0, round(image_size[1]/n_box)-2 do begin
        box=image[i*n_box:(i+1)*n_box-1,j*n_box:(j+1)*n_box-1]
        n_ind=n_elements(where(box gt 3200.))
        
        if n_ind gt 16. then begin
           m=max(box)
           ind=where(box eq m)
           mid_ind=ind[round(n_elements(ind)/2)] ;middle of the elements
           x_ind=(double(mid_ind)/long(n_box)-long(mid_ind)/long(n_box))*n_box
           y_ind=long(mid_ind)/long(n_box)
           x_ind_orig=x_ind+i*n_box
           y_ind_orig=y_ind+j*n_box
           box_new=image[x_ind_orig-n_box/2:x_ind_orig+n_box/2-1,y_ind_orig-n_box/2:y_ind_orig+n_box/2-1]
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
           n_found+=1
           led_coord[n_found-1,*]=[x_ind_orig+round(x_weight)-n_box/2,y_ind_orig+round(y_weight)-n_box/2]
           temp=led_coord
           led_coord=dblarr(n_found+1,2)
           led_coord[0:n_found-1,*]=temp
;           plot, [0,n_box], [0,n_box], /xstyle, /ystyle, /iso
;           otv, box_new/16.
;           plots, x_weight, y_weight, psym=4, color=0
        endif
     endfor
  endfor
  device, decomposed=0
  plot, [0,1312], [0,1082], /xstyle, /ystyle, /iso
  otv, reform(image)/16
  for i=0,n_elements(led_coord[*,0])-1 do begin
     plots, led_coord[i,0],led_coord[i,1], psym=4, color=0
  endfor
end
