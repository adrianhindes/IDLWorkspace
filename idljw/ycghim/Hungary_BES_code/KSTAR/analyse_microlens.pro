pro analyse_microlens

; filenames HAVE TO be replaced with your own
name='test_reverse_'
;name='microlens_01'
restore, 'D:\KFKI\Measurements\KSTAR\Microlens\data\Homogenous.source\new\'+name+'nolens.sav'
image_wo_lens=im
    loadct, 5
for z=0,3 do begin
  case z of
    0: str='red'
    1: str='blue'
    2: str='black'
    3: str='orig'
  end
  restore, 'D:\KFKI\Measurements\KSTAR\Microlens\data\Homogenous.source\new\'+name+str+'.sav'
  image_w_lens=im
  
  
    plotrange_x=[-22,22]
    plotrange_y=[-17,17]
    nx_new = 640
    ny_new = 480
  ;  refpoint_x_scaled = (float(calibration_x)-plotrange_x[0])/(plotrange_x[1]-plotrange_x[0])*nx_new
  ;  refpoint_y_scaled = (float(calibration_y)-plotrange_y[0])/(plotrange_y[1]-plotrange_y[0])*ny_new
  ;  POLYWARP, calib_screen_x, calib_screen_y, refpoint_x_scaled, refpoint_y_scaled, 1, KX, KY
  ;  im_scaled = POLY_2D(reform(im), KX, KY,missing=0,1,nx_new,ny_new)
  ;  ;plot,[0,nx-1],[0,ny-1],/nodata,xrange=[0,nx-1],xstyle=1,yrange=[0,ny-1],ystyle=1,/iso
    nx = nx_new
    ny = ny_new
  ;  hscale = findgen(nx)/(nx-1)*(plotrange_x[1]-plotrange_x[0])+plotrange_x[0]
  ;  vscale = findgen(ny)/(ny-1)*(plotrange_y[1]-plotrange_y[0])+plotrange_y[0]
  ;  ;plot, plotrange_x, plotrange_y, /nodata, xstyle=1, ystyle=1
  ;  ;otv,float(im_scaled-min(im_scaled))/(max(im_scaled)-min(im_scaled))*250
    xrange=[0,nx-1]
    yrange=[0,ny-1]
    device, decomposed=0 
    plot,[0,nx-1],[0,ny-1],/nodata,xrange=xrange,xstyle=1,yrange=yrange,ystyle=1,/iso
    
    
    otv,float(image_w_lens-min(image_w_lens))/(max(image_w_lens)-min(image_w_lens))*250
    print, max(image_w_lens)
    
  ;  print,'Click on corners of the lens with left mouse button: LL, LR, UR, UL'
  ;  print,' Click with right button when finished.'
  ;  digxyadd,lens_corn_x,lens_corn_y,/data
  ;  if (n_elements(lens_corn_x lt 4)) then begin
  ;    print,'Not enough points.'
  ;    return
  ;  endif
    
    ;det_corn_x=[268.19173,433.77741,433.77741,266.43018]
    ;det_corn_y=[119.30721,119.30721,202.51585,201.19508]
    det_corn_x=calib_screen_x
    det_corn_y=calib_screen_y
    ;[LL, LR, UR, UL]
  
    ndet_corn_x=dblarr(2)
    ndet_corn_x[0]=(det_corn_x[0]+det_corn_x[3])/2.
    ndet_corn_x[1]=(det_corn_x[1]+det_corn_x[2])/2.
    ndet_corn_y=dblarr(2)
    ndet_corn_y[0]=(det_corn_y[0]+det_corn_y[1])/2.
    ndet_corn_y[1]=(det_corn_y[2]+det_corn_y[3])/2.
    
    ;Calculate the corners of the lenses (equidistant)
    corner=dblarr(4,8,4,2)
    for i=0,3 do begin
      for j=0,7 do begin
        corner[i,j,0,0]=(ndet_corn_x[1]-ndet_corn_x[0])/8.*j+ndet_corn_x[0]
        corner[i,j,1,0]=(ndet_corn_x[1]-ndet_corn_x[0])/8.*(j+1)+ndet_corn_x[0]
        corner[i,j,2,0]=(ndet_corn_x[1]-ndet_corn_x[0])/8.*(j+1)+ndet_corn_x[0]
        corner[i,j,3,0]=(ndet_corn_x[1]-ndet_corn_x[0])/8.*j+ndet_corn_x[0]
        
        corner[i,j,0,1]=(ndet_corn_y[1]-ndet_corn_y[0])/4.*i+ndet_corn_y[0]
        corner[i,j,1,1]=(ndet_corn_y[1]-ndet_corn_y[0])/4.*i+ndet_corn_y[0]
        corner[i,j,2,1]=(ndet_corn_y[1]-ndet_corn_y[0])/4.*(i+1)+ndet_corn_y[0]
        corner[i,j,3,1]=(ndet_corn_y[1]-ndet_corn_y[0])/4.*(i+1)+ndet_corn_y[0]
        for k=0,3 do begin
          plots, corner[i,j,k,0], corner[i,j,k,1], color=200, psym=3
        endfor
      endfor
    endfor
    
    ;calculate the corners of the detector's place, 0.35mm is the width of the frame,
    ;1.6mm is the size of the detector, 2.3mm is the distance between two detector's centre
    det_corner=dblarr(4,8,4,2)
    for i=0,3 do begin
      for j=0,7 do begin
        det_corner[i,j,0,0]=round((corner[i,j,1,0]-corner[i,j,0,0])/2.3*0.35+corner[i,j,0,0])
        det_corner[i,j,1,0]=round((corner[i,j,1,0]-corner[i,j,0,0])/2.3*(0.35+1.6)+corner[i,j,0,0])
        det_corner[i,j,2,0]=round((corner[i,j,1,0]-corner[i,j,0,0])/2.3*(0.35+1.6)+corner[i,j,0,0])
        det_corner[i,j,3,0]=round((corner[i,j,1,0]-corner[i,j,0,0])/2.3*0.35+corner[i,j,0,0])
        
        det_corner[i,j,0,1]=round((corner[i,j,2,1]-corner[i,j,1,1])/2.3*0.35+corner[i,j,0,1])
        det_corner[i,j,1,1]=round((corner[i,j,2,1]-corner[i,j,1,1])/2.3*0.35+corner[i,j,0,1])
        det_corner[i,j,2,1]=round((corner[i,j,2,1]-corner[i,j,1,1])/2.3*(0.35+1.6)+corner[i,j,0,1])
        det_corner[i,j,3,1]=round((corner[i,j,2,1]-corner[i,j,1,1])/2.3*(0.35+1.6)+corner[i,j,0,1])
        for k=0,3 do begin
          plots, det_corner[i,j,k,0], det_corner[i,j,k,1], color=120, psym=3
        endfor
      endfor
    endfor
    
  ;sum up the values inside the detector's place  
  integarr=dblarr(4,4,2)
  for i=0,3 do begin
    for j=2,5 do begin
      integarr[i,j-2,0]=total(image_w_lens[det_corner[i,j,0,0]:det_corner[i,j,1,0],det_corner[i,j,1,1]:det_corner[i,j,2,1]])
      integarr[i,j-2,1]=total(image_wo_lens[det_corner[i,j,0,0]:det_corner[i,j,1,0],det_corner[i,j,1,1]:det_corner[i,j,2,1]])
    endfor
  endfor
  cursor, x, y, /down
  print, str+': '+strtrim(total(integarr[*,*,0])/total(integarr[*,*,1])*100,2)+'%'
endfor
otv,float(image_wo_lens-min(image_wo_lens))/(max(image_wo_lens)-min(image_wo_lens))*250
end