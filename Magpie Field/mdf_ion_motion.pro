;____________________________________________________________________________
pro MDF_ion_motion, I0, I1, r=r, z=z

   default, I0, 50.
   default, I1, 500.

  Bfield = magpie_field( I0, I1, r=r, z=z )
  Bline = magpie_bline( I0, I1, r=rrb, z=zzb )
  
  ; get the radius of curvature
  ;tilt = atan(bfield.br, bfield.bz)
  ;plot, z, tilt[*,90]*!radeg  
  ; tilt changes by theta ~ 20 degrees in s ~ 25cm so R = s/theta = 
  ; trace the Bfield
  
  Br = Bfield.br
  Bz = bfield.bz
  rr = bfield.rr
  zz = bfield.zz
  
 sz = size(br) & nr = sz[2] & nz = sz[1]
 step = 0.0002
 z = zz[*,0]
 zmax = max(z) 
 p0 = [zz[0,0], rr[0,0]]  ; origin
 dp = rr[0,1]-rr[0,0] ; grid size
 traj = replicate({z: ptr_new(), r: ptr_new()}, nr)

; integrate the lorentz force law for an argon ion

c = mse_constants()
m = 40*c.mp
q = c.e
vphi = 400. ; perpendicular velocity
vz = 8000.  ; parallel velocity
vr = 0
v0 = [vr, vphi, vz]
dt = 1d-8 ; time taken to move 1mm
ds = q/m*dt

; for j=0, nr-1 do begin
j=0

   tr = fltarr(1000000,2)
   v = dblarr(1000000,3)
   tr[0,*] = [zz[0,j], rr[0,j]]
   k = 1L  &  zB = 0.
   v[0,*] = v0
   while zB lt zmax do begin &$
     tr[k,*] = tr[k-1,*] + [v0[2],v0[0]] * dt &$
     zB = tr[k,0]   &$
     pt = (tr[k,*] - p0)/dp &$  ; normalize to grid coordinate
     Bpt = mdf_interp_field( Bz, Br, pt ) & Bz0 = Bpt[0] &  Br0 = Bpt[1] &$
     V[k,*] = v0 + ds*[v0[1]*Bz0, -(v0[0]*Bz0-v0[2]*Br0), -v0[1]*Br0] &$ 
     v0 = V[k,*] &$
     if k eq 1 then plot,[zz[0,0],zmax],[0.,0.06],/nodata else plots,tr[k,0],tr[k,1],psym=3 &$
     k = k+1 &$
  end
  
  
;  traj[j].z =  ptr_new(pB[0:k-1,0])
;  traj[j].r =  ptr_new(pB[0:k-1,1])

; end
vperp = sqrt(v[0:k-1,1]^2+v[0:k-1,0]^2)
vperp = interpol(vperp, tr[0:k-1,0], z)
vprll = interpol(v[0:k-1,2], tr[0:k-1,0], z)
omega = q*Bz[*,0]/m
rL = vperp/omega

bline = magpie_bline( 50., 450., r=rrb, z=zzb )


;___________________________________________Larmor radius________________________
plt1 = plot(z,rl*1000,xtitle='Axial displacement (m)', $
  ytitle='Larmor radius (mm)',xrange=[-0.8,0.7],yrange=[0.,40],color='b',$
  MARGIN=[0.15,0.25,0.15,0.1])
for j = 10, n_elements(bline)-1, 20 do $
  pl = plot(*bline[j].z, *bline[j].r*1000,linestyle='dot',color='black',/over)
;for j = 9, n_elements(bline)-1, 20 do $
;  pl = plot(*bline[j].z, -*bline[j].r,/overplot,xrange=[0.2,0.6],linestyle='dot',color='black',/over)

stop
;________________________________________Vperp____________________________________
plt2 = plot(z,vperp,xtitle='Axial displacement (m)', $
  ytitle='Perpendicular speed (m/s)',xrange=[-0.8,0.7],yrange=[0.,3000],$
   color='r', axis_style=1, $
   MARGIN=[0.15,0.25,0.15,0.1])
plt21 = plot(z,Bz[*,0]*30000,color='b', /over, axis_style=1)

yaxis = AXIS('Y', LOCATION=[zmax,0], $
  TITLE='Field (mT)', $
  TICKDIR=0, $
  color='b', $
  TEXTPOS=1, $
  TICKVALUES=findgen(6)*600, $
  TICKNAME=['0','200','400','600','800','1000'])
;xaxis = AXIS('X', LOCATION=[0,3000], $

;________________________________Vprll_________________________________
plt3 = plot(z,vprll,xtitle='Axial displacement (m)', $
  ytitle='Parallel speed (m/s)',xrange=[-0.8,0.7],yrange=[0.,10000],$
   color='r', axis_style=1, $
   MARGIN=[0.15,0.25,0.15,0.1])
plt31 = plot(z,Bz[*,0]*100000,color='b', /over, axis_style=1)

yaxis = AXIS('Y', LOCATION=[zmax,0], $
  TITLE='Field (mT)', $
  TICKDIR=0, $
  color='b', $
  TEXTPOS=1, $
  TICKVALUES=findgen(6)*2000, $
  TICKNAME=['0','200','400','600','800','1000'])
;xaxis = AXIS('X', LOCATION=[0,3000], $



;,/current,LAYOUT=[2,2,4])

;for j = nr-1, 0, -3 do begin &$
;  if j eq nr-1 then plot, *bline[j].z, *bline[j].r, yr=[0,0.06] else $
;  oplot, *bline[j].z, *bline[j].r  &$
;end

;j=30
;blpr = deriv( *bline[j].z, *bline[j].r )
;blprpr = deriv(*bline[j].z, deriv( *bline[j].z, *bline[j].r ))


stop
end

