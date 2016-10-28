
function read_psi, shot, time

; Read poloidal flux from EFIT

  ds = read_flux(shot)

  ip = where(ds.taxis.vector ge time) & ip = ip[0]

  jp = where(ds.yaxis.vector ge 0.0) & jp = jp[0]

  psi = ds.data[*, jp, ip]

  r = ds.xaxis.vector

; Read psi at boundary from EFIT
  ds = read_data(shot, 'efm_psi_boundary')
  ip = where(ds.taxis.vector ge time) & ip = ip[0]
  psib = ds.data[0, 0, ip]

; Read psi at axis from EFIT
  ds = read_data(shot, 'efm_psi_axis')
  psi0 = ds.data[0, 0, ip]

; Read radius of magnetic axis
  ds = read_data(shot, 'efm_magnetic_axis_r')
  r0 = ds.data[0, 0, ip]

; Calculate normalised flux
  psin = (psi - psi0) / (psib - psi0)

; Calculate normalised radius
  rho = sqrt(psin)

  ds = {shot:shot, time:time, r:r, psi0:psi0, psib:psib, psi:psi, psin:psin, rho:rho, $
           r0:r0}

  return, ds

end

