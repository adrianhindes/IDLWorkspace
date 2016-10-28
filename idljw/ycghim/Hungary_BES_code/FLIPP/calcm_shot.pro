pro calcm_shot,shot,t1,t2,z_vect=z_vect,multi=multi,teprof=teprof,$
  smooth=smooth,zeff=zeff

; Calculates M matrix for linearized density calculation based on the
; average light signal in shot between times t1 and t2.
; Saves m matrix, z_vect, p0,n0 and p0r in file: <shot>_m.mx
; multi: multiplies density profile by this factor	 
; teprof: use this electron temperature file for simula

get2pdat,shot,t1,t2,li2p,samp
loadxrr,xrr
np=(size(xrr))(1)
p0=fltarr(np)
nprof=(size(li2p))(1)
p0(*)=total(li2p,1)/nprof

calcne,p0,n0,z,3
z=z(where(z ne 0))
n0=n0(where(z ne 0))
n0=n0>0
if (keyword_set(multi)) then n0=n0*multi
if (keyword_set(smooth)) then n0=smooth(n0,smooth)

if (not keyword_set(z_vect)) then begin
  n0=xy_interpol(z,n0,xrr)
  z=[9,xrr]
  n0=[1e11,n0]
	z_vect=z
endif else begin
  n0=xy_interpol(z,n0,z_vect)
  z=z_vect
endelse  
nd=(size(n0))(1)
p0r=calc_light(z,n0,xrr)
if (keyword_set(multi)) then p0=p0r

if keyword_set(teprof) then spawn,'cp '+teprof+' ~/simula/W7.temp'
calcM,M,n0,z,zeff=zeff

if (keyword_set(multi)) then begin
  save,m,z_vect,p0,n0,p0r,file=i2str(shot)+'x'+$
       string(multi,format='(F3.1)')+'_m.mx'
endif else begin
  save,m,z_vect,p0,n0,p0r,file=i2str(shot)+'_m.mx'
endelse

end
