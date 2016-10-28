pro MSE_apply_LUT, shotno, index

; get the data  
  s = read_mse_process_settings( shotno )
    
  theta = read_segmented_images(s.tree, shotno, '.demod:theta', index ) ; the polarization angle images
  
  theta_cal = read_segmented_images(s.tree, s.cal_shot, '.demod:theta') ; equivalent cal images
  theta_in = theta_cal.time   ; the polarizer angles    ; the polarizer angle is carried by the timebase
  

; apply the look up table
theta0 = theta.images
  ProgressBar = Obj_New("cgProgressBar", /Start, title='Applying LUT')
  for i=0, theta.nx-1 do begin &$
    if i mod 10 eq 0 then ProgressBar -> Update, float(i)/(theta.nx-1)*100 &$
    print,'Column:',i &$
    for j=0, theta.ny-1 do begin &$
      theta0[i,j,*] = interpol( theta_in, reform(theta_cal.images[i,j,*]), reform(theta.images[i,j,*]) ) &$
    end &$
  end
  ProgressBar -> Destroy

; delete any pre-existing image sequence node and then create again
mdsedit, s.tree, shotno
  mdstcl,'delete node .demod:theta0/noconfirm'
mdswrite, s.tree, shotno

wait,1.
mdsedit, s.tree, shotno
  find_or_create_node, '.demod:theta0'
mdswrite, s.tree, shotno

print,'Writing calibrated images to .demod:theta0'
mdsopen, s.tree, shotno
for k = 0, theta.n_images - 1 do put_image_seg, '.demod:theta0', theta0[*,*,k], theta.time[k] 
mdsclose, s.tree, shotno

end
