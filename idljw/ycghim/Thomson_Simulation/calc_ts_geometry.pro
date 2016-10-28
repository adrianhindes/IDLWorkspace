
function calc_ts_geometry, dsch, dssys

; Laser trajectory to cylindrical coordinates
  laser_pc = dssys.laser_pr
  laser_pc[*, 0] = r_to_c(dssys.laser_pr[*, 0])
  laser_pc[*, 1] = r_to_c(dssys.laser_pr[*, 1])

; Vector along laser path
  laser_v = vector(dssys.laser_pr[*, 0], dssys.laser_pr[*, 1])

; Unit vector along laser path
  laser_uv = unit_vector(laser_v)

; Locate cartesian coordinates of viewing locations
  view_pr = fltarr(3, 2, dsch.nch)

; Iterate along laser path
  dl = 1e-3
  pri = dssys.laser_pr[*, 0]
  ich = dsch.nch-1

  repeat begin

    pri = pri + dl * laser_uv

    pci = r_to_c(pri)

    if pri[0] lt 0. then begin

      if pci[0] le dsch.rch[ich] then begin
        view_pr[*, 0, ich] = pri
        ich--
      endif       

    endif else begin

      if pci[0] ge dsch.rch[ich] then begin
        view_pr[*, 1, ich] = pri
        ich++
      endif

    endelse

  endrep until ich lt 0

; Iterate along laser path to find far intersections
  pri = dssys.laser_pr[*, 0]
  ich = 0

  repeat begin

    pri = pri + dl * laser_uv

    pci = r_to_c(pri)

    if pri[0] gt 0. then begin

      if pci[0] ge dsch.rch[ich] then begin
        view_pr[*, 1, ich] = pri
        ich++
      endif

    endif

  endrep until ich ge dsch.nch

; Unit vectors of views
  view_uv = fltarr(3, dsch.nch)

  for i=0,dsch.nch-1 do begin
    view_v = vector(view_pr[*, dsch.location[i], i], dssys.lens_pr[*, dsch.system[i]])
    view_uv[*, i] = unit_vector(view_v)
  endfor

; Angles of view with laser beam
  angle = fltarr(dsch.nch)

  for i=0, dsch.nch-1 do $
    angle[i] = acos(vector_scalar_product(laser_uv, view_uv[*, i]))

; Calculate scattering lengths along laser
  scatlen = fltarr(dsch.nch)
  for i=0, dsch.nch-1 do $
    scatlen[i] = dssys.dxim[dsch.system[i]] / sin(angle[i])

; Axial point of machine
  axis_pr = [0., 0., 0.]

; Radial unit vector to view location
  radial_uv = fltarr(3, dsch.nch)

  for i=0, dsch.nch-1 do begin
    radial_v = vector(axis_pr, view_pr[*, dsch.location[i], i])
    radial_uv[*, i] = unit_vector(radial_v)
  endfor

; Angle between radial vector and laser
  beta = fltarr(dsch.nch)

  for i=0, dsch.nch-1 do $
    beta[i] = acos(vector_scalar_product(laser_uv, radial_uv[*, i]))

; Calculate radial resolution (radial component of scattering length)
  drch = sqrt((scatlen * abs(cos(beta)))^2 + (dssys.wlaser * abs(sin(beta)))^2)

  dssys = create_struct(dssys, 'laser_pc', laser_pc, 'laser_uv', laser_uv, 'view_pr', view_pr, $
                                   'view_uv', view_uv, 'angle', angle, 'scatlen', scatlen, 'drch', drch, $
                                   'beta', beta)

  return, dssys

end

