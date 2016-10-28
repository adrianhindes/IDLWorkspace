function EFIT_calculate_normalized_flux, Efit, time, r=rr, z=zz 

  idx = (where(efit.time ge time))[0]>0    ;efit time index
  psi_n = (EFIT.ssimag[idx]-EFIT.psirz[*,*,idx])/(EFIT.ssimag[idx]-EFIT.ssibry[idx])
  rmin=min(efit.r)  &  rmax=max(efit.r)
  zmin=min(efit.z)  &  zmax=max(efit.z)
  nre = n_elements(efit.r)
  nze = n_elements(efit.z)
  
  sz=size(rr)
  if sz[0] eq 1 then begin

     ridx = ((rr-rmin)/(rmax-rmin)*(nre-1))>0<(nre-1)
     zidx = ((zz-zmin)/(zmax-zmin)*(nze-1))>0<(nze-1)
     psi = interpolate(psi_n,ridx,zidx,cub=-0.5)
  
  end else begin
; get the poloidal flux in ROI
    nr=sz[1] & nz=sz[2]
    ridx = reform((rr-rmin)/(rmax-rmin)*(nre-1),nr*nz)>0<(nre-1)
    zidx = reform((zz-zmin)/(zmax-zmin)*(nze-1),nr*nz)>0<(nze-1)
    psi = reform(interpolate(psi_n,ridx,zidx,cub=-0.5) , nr, nz)
  end
;  stop
return, psi

end