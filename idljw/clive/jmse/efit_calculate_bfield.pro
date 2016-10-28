function EFIT_Calculate_bfield, efit, r, z, time, cubic=cubic

default, cubic, -0.5

  sz=size(r)  &  nr=sz[1] & nz=sz[2]
  etime=efit.time
  if n_elements(time) eq 0 then time=(efit.time)[0]
  idx = (where(efit.time ge time))[0]>0
;  print,'time, efit.time:',time,efit.time[idx]

  rmin=min(efit.r)  &  rmax=max(efit.r)
  zmin=min(efit.z)  &  zmax=max(efit.z)
  ridx = reform((r-rmin)/(rmax-rmin)*n_elements(efit.r))
  zidx = reform((z-zmin)/(zmax-zmin)*n_elements(efit.z))

  psi_n = (EFIT.ssimag[idx]-EFIT.psirz[*,*,idx])/(EFIT.ssimag[idx]-EFIT.ssibry[idx])

  dpsidx = fltarr(nr,nz) & dpsidy=dpsidx
  br = fltarr(nr,nz) & bz=br
      rho = interpolate(psi_n,ridx,zidx,cub=cubic) &$  ; normalized flux
      psirz = interpolate(efit.psirz[*,*,idx],ridx,zidx,cub=cubic) &$
; calculate horizontal derivative of psi in tangent plane
      for j = 0,nz-1 do begin
        dpsidx[*,j] = Deriv(r[*,j],psirz[*,j])
      endfor
      ; calculate vertical derivative of psi
      for i = 0,nr-1 do begin
        dpsidy[i,*] = Deriv(z[i,*],psirz[i,*])
      endfor
      ; calculate array of Br, Bz, and Bp
      for j = 0, nz-1 do begin
        br[*,j] = dpsidy[*,j]/r[*,j]
        bz[*,j] = -dpsidx[*,j]/r[*,j]
      endfor
      ; get Bt and then simply 2d interpolate
      bt0 = EFIT_Calculate_btor( efit, idx )
      bt = interpolate(bt0,ridx,zidx,cub=-0.5) &$  ; normalized flux

return, {br: br, bz: bz, bt:bt, rho: rho, psi: psirz}

end
