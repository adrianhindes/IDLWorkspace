;_____________________________________________________________________________
function Magpie_bline, I0, I1, r=r, z=z, scale=scale

  Bfield = Magpie_field( I0, I1, r=r, z=z, scale=scale )
  
  ; get the radius of curvature
  ;tilt = atan(bfield.br, bfield.bz)
  ;plot, z, tilt[*,90]*!radeg  
  ; tilt changes by theta ~ 20 degrees in s ~ 25cm so R = s/theta = 
  ; trace the Bfield
  
  Br = Bfield.br
  Bz = bfield.bz
  rr = bfield.rr
  zz = bfield.zz
  dr = rr[0,1]-rr[0,0]
  flux = 2*!pi*total(Bz*rr, 2, /cum)*dr
 
; contours of magnetic flux 
;  c1 = contour_bar( (flux*1e4)<2, zz, rr, n_level = 30, rgb = 5,$
;                yrange = [0.,0.05], ytitle='Radius (m)', $
;                xrange = [-0.3, 0.55], xtitle='Axial distance (m)',$
;                ctitl='Flux x10^4 Wb', over=0)

;  Mod B contours 
;  c2 = contour_bar( sqrt(br^2+bz^2)*1000, zz, rr, n_level = 30, rgb = 5,$
;                yrange = [0.,0.05], ytitle='Radius (m)', $
;                xrange = [-0.3, 0.55], xtitle='Axial distance (m)',$
;                ctitl='Mod B (mT)', over=0)

  
 sz = size(br) & nr = sz[2] & nz = sz[1]
 step = 0.0002
 zmax = zz[nz-1,0] 
 p0 = [zz[0,0], rr[0,0]]
 dp = rr[0,1]-rr[0,0]
 Bline = replicate({z: ptr_new(), r: ptr_new()}, nr)

 for j=0, nr-1 do begin

   pB = fltarr(10000,2)
   pB[0,*] = [zz[0,j], rr[0,j]]
   unit = unit([Bz[0,j],Br[0,j]])
   k = 1  &  zB = 0.
   while zB lt zmax do begin &$
     pB[k,*] = pB[k-1,*] + unit * step &$
     zB = pB[k,0]   &$
     pt = (pB[k,*] - p0)/dp &$
     unit = unit(mdf_interp_field( Bz, Br, pt )) &$
     k = k+1 &$
  end
  Bline[j].z =  ptr_new(pB[0:k-1,0])
  Bline[j].r =  ptr_new(pB[0:k-1,1])
 end

;for j = nr-1, 0, -3 do begin &$
;  if j eq nr-1 then plot, *bline[j].z, *bline[j].r, yr=[0,0.06] else $
;  oplot, *bline[j].z, *bline[j].r  &$
;end

;j=30
;blpr = deriv( *bline[j].z, *bline[j].r )
;blprpr = deriv(*bline[j].z, deriv( *bline[j].z, *bline[j].r ))


return, bline
end

