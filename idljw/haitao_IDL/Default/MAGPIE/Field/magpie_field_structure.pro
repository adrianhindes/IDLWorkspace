pro magpie_field_structure, Isource, Imirror
  Isource = 50.0
  Imirror = 500.0
  
  z = range(-0.6,0.7,.001) 
  r = range(.001,.15,.001)

  B = Magpie_field( Isource, Imirror, r=r, z=z, scale=scale )
  sz = size(B.zz,/dim) & nz=sz[0] & nr=sz[1]  
   
  modb = sqrt(b.bz^2+b.br^2)
  gradbz = deriv(b.zz, modb)
  gradbr = transpose(deriv(transpose(b.rr),transpose(modb)))
  gradb = [[[gradbr]], [[fltarr(nz,nr)]], [[gradbz]]]
  bvec = [[[b.br]], [[fltarr(nz,nr)]], [[b.bz]]]
  
  stop
  asdf = dblarr(1300,150,3)
  for i =0L, 1300L-1L do begin
    for j = 0L, 150L-1L do begin
       asdf[i,j,*] = crossp(bvec[i,j,*],GradB[i,j,*])
    endfor
  endfor

   
;  B_cross_gradb = (crossp(Bvec, GradB))[*,*,1] ; these drifts are entirely rotational
  
;  contour, B_cross_gradb, b.zz, b.rr, nlev=20,/fill,$
;      xr=[-0.2,.7], yr=[0.,.06], zr=[-.01,.01], /xst,/yst

  contour, bvec[*,*,0], b.zz, b.rr, nlev=20,/fill,$
      xr=[-0.7,.7], yr=[0.,.15], zr=[-.01,.01], /xst,/yst
;  
;  c1 = contour(bvec[*,*,0], b.zz, b.rr, rgb_table = 0, /fill)
;  cbar = colorbar(TARGET = c1, orientation=1)
 
 stop
 end