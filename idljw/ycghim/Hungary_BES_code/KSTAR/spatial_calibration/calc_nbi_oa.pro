pro calc_nbi_oa, oa_nbi=oa_nbi, oa_pic=oa_pic, direction=direction,$
                 fourcord=fourcord, coeff=coeff, lithium=lithium, geom_coord=geom_coord,$
                 nbi_w=nbi_w

  ;********************************************************************
  ;*                       calc_nbi_oa                                *
  ;********************************************************************
  ;* This routine calculates the optical axis of the NBI from Yong    *
  ;* Un's report. It also gives the pixel to coordinate transform     *
  ;*Input(s):                                                         *
  ;*  fourcord:  The four coordinates on the EDICAM picture, in the   *
  ;*             order of top,bottom,left,right and is [4,2] vector   *
  ;*  direction: 0:Edge 1:Core1(middle) 2:Core2 (lower)               *
  ;*  oa_pic:    The coordinate of the optical axis on the picture    *
  ;*             (its center)                                         *
  ;*  nbi_w:     Weight factors for the NBI1,2,3                      *
  ;*Output(s):                                                        *
  ;*  oa_nbi:     The coordinate of the optical axis on the NBI plane,*
  ;*              in our xyz coordinate system                        *
  ;*  pix2cord_p: [[alfa_x2r,beta_x2r],[alfa_y2z,beta_y2z]]           *
  ;********************************************************************
  
  ;The following coordinates are from Yong Un's report
  ;These are the xyz coordinatecs of the points on the wall
  default,fourcord,dblarr(4,2)
  default,oa_pic,[1312,1082]/2
  default,direction,0
  default,nbi_w,[0,1,0]
  
  ;This is a trial database of the four coordinates from pictures
  ;the structure is the following:
  
  a=size(fourcord)
  if (a[0] ne 2 or a[1] ne 4) then begin
    print, 'Error: Fourcord is not a [4,2] array'
    return
  endif
;  The following commented section contains the previous spatial calibration point   
  window_cat=[66.5,2732.4,-253] ;CATIA shifted to center and shifted with the pinhole coordinate, still necessary for rotation calculation
  ;window_axis_p=[139.,2664.7,-253] 
  ;d_mirror_firstlens=70. ;28.6 ;distance between the first window's middle and the actual pinhole aestimate point
  ;principal_ray_point_cat=-d_mirror_firstlens/distance(window_cat,window_axis_p)*(window_axis_p-window_cat)+window_cat

  principal_ray_point_cat=[45.3,2751.6,-245.3] ;The intersection point of the princial rays inside the optics
  r_litium_cat=[777.,777.,0.] ;The Lithium beam is suspected to be going in a poloidal plane
  m_port_middle_cat=[0,729.7,0] ;This is a point which describes the plane of the m-port middle
  
  window_yun=[-974.7,2569.,-253.]  ;from YUN
  a_point_nbi_yun=[377.8,2774.4,0] ;from YUN
  b_point_nbi_yun=[2331,-1551.3,0] ;from YUN
  
  if defined(nbi_w) then begin
    foc_point_nbi_yun=dblarr(3)
    r_focal_point_nbi=sqrt(1487.^2+3400.^2)
    alfa_nbi_123=atan(238./3400.)
    
    ;The R coordinate of the NBI focal point is known, its coordinate in Yong Un's system is the question  
    xa = a_point_nbi_yun[0]
    xb = b_point_nbi_yun[0]
    ya = a_point_nbi_yun[1]
    yb = b_point_nbi_yun[1]
    r = r_focal_point_nbi
    a = (yb-ya)/(xb-xa)
    coa = a^2+1
    cob = 2*a*ya-2*a^2*xa
    coc = 2*a^2*xa^2+ya^2-2*a*xa*ya-r^2
    foc_point_nbi_yun[0] = (-cob+sqrt(cob^2-4*coa*coc))/(2*coa)
    foc_point_nbi_yun[1] = a*(foc_point_nbi_yun[0]-xa)+ya
    
    a_point_nbi_yun=foc_point_nbi_yun
    b_1=rot_z(b_point_nbi_yun, foc_point_nbi_yun, alfa_nbi_123)
    b_2=b_point_nbi_yun
    b_3=rot_z(b_point_nbi_yun, foc_point_nbi_yun, -alfa_nbi_123)
    
    b_point_nbi_yun=(nbi_w[0]*b_1+nbi_w[1]*b_2+nbi_w[2]*b_3)/total(nbi_w)
  endif

  ;M-port middle is the 0° toroidal angle coordinate, this is figured out from the known coordinates  
  
  fourcord_spat_J_yun  = transpose([[2037.0,1828.3,49.1],$ ;from YUN
                                    [2037.0,1828.3,-49.1],$
                                    [2030.2,1877.0,0],$
                                    [2043.8,1779.7,0]])
                                    
  fourcord_spat_Im_yun = transpose([[2523.6,1124.2,87.7],$ ;from YUN
                                    [2523.6,1124.2,-27.7],$
                                    [2530.5,1176.8,30.0],$
                                    [2516.6,1071.7,30.0]])
                                    
  fourcord_spat_Il_yun = transpose([[2523.6,1124.2,-132.3],$ ;from YUN
                                    [2523.6,1124.2,-247.7],$
                                    [2530.5,1176.8,-190.0],$
                                    [2516.6,1071.7,-190.0]])
                                
  rotangle=-acos(transpose(window_yun[0:1]) # window_cat[0:1]/ $
                (distance(window_yun[0:1],/length)*distance(window_cat[0:1],/length)))
             
  a_point_nbi_cat=rot_z(a_point_nbi_yun,[0,0,0],rotangle)
  b_point_nbi_cat=rot_z(b_point_nbi_yun,[0,0,0],rotangle)
  c_point_nbi_cat=[(a_point_nbi_cat[0:1]+b_point_nbi_cat[0:1])/2,-100]

  a_point_li_cat=r_litium_cat*3
  b_point_li_cat=r_litium_cat*2
  c_point_li_cat=[r_litium_cat[0:1]*2.5,-100]

  geom_coord={window_cat:window_cat,a_point_nbi_cat:a_point_nbi_cat,b_point_nbi_cat:b_point_nbi_cat,$
                                    a_point_li_cat:a_point_li_cat,  b_point_li_cat:b_point_li_cat,$
                                    m_port_middle_cat:m_port_middle_cat,principal_ray_point_cat:principal_ray_point_cat}
  
  fourcord_spat_J_cat=dblarr(4,3)
  fourcord_spat_Im_cat=dblarr(4,3)
  fourcord_spat_Il_cat=dblarr(4,3)
  
  for i=0,3 do begin
    fourcord_spat_J_cat[i,*]=rot_z(fourcord_spat_J_yun[i,*],[0,0,0],rotangle)
    fourcord_spat_Im_cat[i,*]=rot_z(fourcord_spat_Im_yun[i,*],[0,0,0],rotangle)
    fourcord_spat_Il_cat[i,*]=rot_z(fourcord_spat_Il_yun[i,*],[0,0,0],rotangle)
  endfor
        
  if not keyword_set(lithium) then begin
    
    ; The following coordinates are the above mentioned coordinates on the NBI plane,
    ; with the correct viewing line
    fourcord_spat_nbi_J=dblarr(4,3)
    fourcord_spat_nbi_Im=dblarr(4,3)
    fourcord_spat_nbi_Il=dblarr(4,3)
                                    
    for i=0,3 do begin
      fourcord_spat_nbi_J[i,*]=line_plane_intersection(fourcord_spat_J_cat[i,*],$
                                                       principal_ray_point_cat,$
                                                       a_point_nbi_cat,$
                                                       b_point_nbi_cat,$
                                                       c_point_nbi_cat)
      fourcord_spat_nbi_Im[i,*]=line_plane_intersection(fourcord_spat_Im_cat[i,*],$
                                                        principal_ray_point_cat,$
                                                        a_point_nbi_cat,$
                                                        b_point_nbi_cat,$
                                                        c_point_nbi_cat)
      fourcord_spat_nbi_Il[i,*]=line_plane_intersection(fourcord_spat_Il_cat[i,*],$
                                                        principal_ray_point_cat,$
                                                        a_point_nbi_cat,$
                                                        b_point_nbi_cat,$
                                                        c_point_nbi_cat)
    endfor                                
    case direction of
      0:portcor = fourcord_spat_nbi_J
      1:portcor = fourcord_spat_nbi_Im
      2:portcor = fourcord_spat_nbi_Il
    endcase
  endif else begin
    fourcord_spat_li_J=dblarr(4,3)
    for i=0,3 do begin
      fourcord_spat_li_J[i,*]=line_plane_intersection(fourcord_spat_J_cat[i,*],$
                                                      principal_ray_point_cat,$
                                                      a_point_li_cat,$
                                                      b_point_li_cat,$
                                                      c_point_li_cat)
    endfor
    portcor=fourcord_spat_li_J ;For the lithium calibration only these coordinate's are adequate
      endelse
  n=n_elements(fourcord[*,0])  ;Number of known coordinates on the image
  n_c=12                    ;Number of coefficients
  r=dblarr(n_c)             ;The vector for the coefficients
  b=dblarr(3*n)             ;Values of the real spatial coordinates [r,z]
  a=dblarr(3*n,n_c)

  for i=0,n-1 do begin
    x  = fourcord[i,0]
    xy = fourcord[i,0]*fourcord[i,1]
    y  = fourcord[i,1]
    
    a[3*i,*]   = [x,xy,y,1,0,0,0,0,0,0,0,0]
    a[3*i+1,*] = [0,0,0,0,x,xy,y,1,0,0,0,0]
    a[3*i+2,*] = [0,0,0,0,0,0,0,0,x,xy,y,1]
    b[3*i]   = portcor[i,0]
    b[3*i+1] = portcor[i,1]
    b[3*i+2] = portcor[i,2]    
  endfor
   
  if n eq 4 then begin
    r=invert(a) # b
  endif else begin
    r=(invert(transpose(a) # a) # transpose(a)) # b
  endelse
  
  ;print, b - (a # r) 
  
  x=oa_pic[0]
  y=oa_pic[1]
  
  coeff=transpose([[r[0:3]],[r[4:7]],[r[8:11]]])
  oa_nbi_xyz=dblarr(3)
  oa_nbi_xyz=coeff # [x,x*y,y,1]
  oa_nbi=xyztocyl(oa_nbi_xyz)
end 