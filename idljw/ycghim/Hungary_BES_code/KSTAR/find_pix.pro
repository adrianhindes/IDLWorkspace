function find_pix, pixd, spat_cor_p

  ;///////////////////////////////////////////////////////////
  ;This small function finds the spatial coordinate for a pixel
  ;///////////////////////////////////////////////////////////
  ;
  ;INPUT:
  ;   pixd: 2D array of the pixel coordinate for the spatial coordinate
  ;   spat_cor_p: the n x m matrix of the spatial[pix] matrix
  ;OUTPUT:
  ;   spatcor: the spatial coordinate of the pixel coordinate pixd
  ;   
  ;comment: this routine is used for apd_calib_2.pro
  ;
  ;///////////////////////////////////////////////////////////
  
  nx=n_elements(spat_cor_p[*,0,0])
  ny=n_elements(spat_cor_p[0,*,0])
  vec=dblarr(nx,2)
  distmatrix=dblarr(nx,ny)
  
  for i=0,nx-1 do begin
    for j=0,ny-1 do begin
      distmatrix[i,j]=(pixd[0]-spat_cor_p[i,j,0])^2+(pixd[1]-spat_cor_p[i,j,1])^2
    endfor
  endfor
  for i=0,nx-1 do begin
    vec[i,0]=min(distmatrix[i,*],n)
    vec[i,1]=n
  endfor
  b=min(vec[*,0],m)
  spatcor=[m,vec[m,1]]/5
  return, spatcor
end