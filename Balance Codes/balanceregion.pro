function balanceRegion, z1, z2

;Given two z locations (actual), 
;Calculate the region area and dA for particle balance
; z=0 is the source region, lengths are in cm

  ;a program to calculate the magnetic field lines
  ;from the model of the magnetic field coil configuration.
  ;The complexity of this code arises as we need to correct for the
  ;shift in the central axis of the discharge. The amount of this shift corresponds
  ;to the position of the fudicial marks engraved in the base plate covering the floor
  ;of the chamber. This shift has already been taken into account in the imported
  ;r_array values.

  z_length = 1444
  norm_z = 1443.0
  diam = 130
  norm_r = 129.0

  r=(indgen(diam)/norm_r)*6 -2.8  ;4cm radius
  z=(indgen(z_length)/norm_z)*120 -60 ;60cm


  rr=make_array(z_length,diam)
  zz=make_array(z_length, diam)


  for i=0, 1444-1 do begin
    rr[i,*]=r[*]
  endfor

  for j=0, 130-1 do begin
    zz[*,j]=z[*]
  endfor


  y=1
  n=0


  s_coils_active = [y,y,y,y,y]                ;source coils are active indicated with 'y' (starting from end nearest pump), not active: 'n'
  m_coils_active = [n,n,y,y,y,y,y]             ;mirror coils are active indicated with 'y' (starting from end nearest pump), not active: 'n'
  mirror_c = 400
  source_c = 50
  rnorm = -0.2
  r_array = rr
  z_array = zz
  coil=get_coils(s_coils_active, m_coils_active, mirror_c, source_c)
  n_coils=n_elements(coil.position)
  pic_jsz=n_elements(r_array[0,*])
  pic_isz=n_elements(r_array[*,0])

  pos=coil.position
  cur=coil.current
  rad=coil.radius

  Bz=make_array(pic_isz,pic_jsz, n_coils, /double)
  Br=make_array(pic_isz,pic_jsz, n_coils, /double)


  for k=0, n_coils-1 do begin
    coils={position:pos[k], current:cur[k], radius:rad}
    B_field=magpie_coil_field(r_array, z_array, coils)
    Bz[*,*,k]=B_field.bz
    Br[*,*,k]=B_field.br
    bz[*,0,*]=bz[*,1,*]
    br[*,0,*]=br[*,1,*]
  endfor

  br_tot=total(br, 3)
  bz_tot=total(bz, 3)
  b_mod=sqrt((br_tot)^2+(bz_tot)^2) ;is dominated by the bz term

  ;need to calculate the magnetic flux through each radial surface
  d_r= (r_array[0,1]-r_array[0,0])/100

  fmid=Bz_tot*abs(r_array)
  r_col=reform(r_array[0,*])
  b= where((r_col gt 0.0-5e-2) and (r_col lt 0.0+5e-2))

  fmid[*,0:b(0)-1]=rotate(total(rotate(fmid[*,0:b(0)-1], 7),2,/cum),7)
  fmid[*,b(0):pic_jsz-1]=total(fmid[*,b(0):pic_jsz-1],2, /cum)

  flux = 2*!pi*fmid*d_r
  flux_full=flux*1e4



  z1_index = value_locate(z,z1)
  z2_index = value_locate(z,z2)

  ;B field flux val to track
  flux_track = 10 ;arbitrary

  ;Area and dA

  fluxArea = flux_area(flux_full, r, z1_index, z2_index, flux_track)
  
  r1 = fluxArea.r1 * 1e-4
  r2 = fluxArea.r2 * 1e-4
  zlength= z2-z1
  
  parallelArea = fluxArea.Area * 1e-4
  diffArea = fluxArea.dA * 1e-4
  vol = voltruncone(r1,r2,zlength)
  perpArea = surfacetruncone(r1,r2,zlength)
  

  
  region = create_struct('area',parallelArea,'diffArea',diffArea,'volume',vol,'perpArea',perpArea)
  
return,region

end