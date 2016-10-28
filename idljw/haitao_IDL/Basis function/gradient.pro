function gradient, image1, VECTOR=vector, ABSVAL_NORM=absval,  $
      ONE_SIDED=one_sided, XRANGE=xran, YRANGE=yran

  sim = size( image1 )

  if (sim(0) NE 2) then begin
    message,"expecting an image (2-D matrix)",/INFO
    return,sim
     endif

  if keyword_set( one_sided ) then begin
    didx = shift( image1, -1,  0 ) - image1
    didy = shift( image1,  0, -1 ) - image1
    endif else begin
    didx = ( shift( image1, -1,  0 ) - shift( image1, 1, 0 ) ) * 0.5
    didx(0,*) = image1(1,*)-image1(0,*)
    didy = ( shift( image1,  0, -1 ) - shift( image1, 0, 1 ) ) * 0.5
    didy(*,0) = image1(*,1)-image1(*,0)
     endelse

  didx(sim(1)-1,*) = image1(sim(1)-1,*) - image1(sim(1)-2,*)
  didy(*,sim(2)-1) = image1(*,sim(2)-1) - image1(*,sim(2)-2)

  if N_elements( xran ) EQ 2 then begin
    scale = sim(1) / float( xran(1)-xran(0) )
    didx = didx * scale
     endif

  if N_elements( yran ) EQ 2 then begin
    scale = sim(2) / float( yran(1)-yran(0) )
    didy = didy * scale
     endif

  if keyword_set( vector ) then  return, [ [[didx]], [[didy]] ]
  if keyword_set( absval ) then  return, abs( didx ) + abs( didy )

return, sqrt( didx*didx + didy*didy )
end