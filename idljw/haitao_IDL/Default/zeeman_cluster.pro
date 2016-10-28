;--------------------------------------------------------------------
function Zeeman_relative_intensity, J, Jprime, M, Mprime
; J is upper level
; Jprime is lower J level
; M is upper M level
; Mprime is lower M level
;  See Clive's thesis p33
;--------------------------------------------------------------------
 
case J-Jprime of
0: Iz = {pi: float(M^2), sig_p:(J+M)*(J+1-M)/4., sig_m:(J-M)*(J+1+M)/4., gm:0.}
1: Iz = {pi: float(J^2-M^2), sig_p:(J+M)*(J-1+M)/4., sig_m:(J-M)*(J-1-M)/4., gm:0.}
-1: Iz = {pi: float((J+1)^2-M^2), sig_p:(J+1-M)*(J-M+2)/4., sig_m:(J+1+M)*(J+M+2)/4., gm:0.}
else: return,{pi: 0., sig_p:0., sig_m:0.} ; stop,'J level difference > 1'
end

case M-Mprime of
0: return, {pi: Iz.pi, sig_p:0., sig_m:0., gm:0.}
1: return, {pi: 0., sig_p:Iz.sig_p, sig_m:0., gm:0.}
-1: return,{pi: 0., sig_p:0., sig_m:Iz.sig_m, gm:0.}
else: return,{pi: 0., sig_p:0., sig_m:0., gm:0.} ;stop,'M level difference > 1'
end

end
;--------------------------------------------------------------------
function Compress_Zeeman_cluster, Z
z=reform(z,n_elements(z))
br = where(z.sig_m ne 0 or z.sig_p ne 0 or z.pi ne 0)
return, z[br]
end

;--------------------------------------------------------------------
pro Show_Zeeman_cluster, Zin, lambda=lambda, Bfield=B

z=compress_zeeman_cluster(Zin)
yr=minmax([[z.sig_m],[z.sig_p],[z.pi]])
n=n_elements(z)

plot,z.gm, z.sig_m, yr=yr+[0,.5], xr=minmax(z.gm)+[-1,1],/xst,/nodata,/yst

for i=0, n-1 do begin &$
  if (z.sig_m)[i] ne 0 then plots, [(z.gm)[i],(z.gm)[i]],[0,(z.sig_m)[i]], col=2,th=2 &$
end
for i=0, n-1 do begin &$
  if (z.sig_p)[i] ne 0 then plots, [(z.gm)[i],(z.gm)[i]],[0,(z.sig_p)[i]], col=2,th=2 &$
end
for i=0, n-1 do begin &$
  if (z.pi)[i] ne 0 then plots, [(z.gm)[i],(z.gm)[i]],[0,(z.pi)[i]], col=4,th=2 &$
end

end

;--------------------------------------------------------------------
function Zeeman_cluster, S, L, J, Spr, Lpr, Jpr, compress=compress
;
; calculate the zeeman structure for transtion between states (S,L,J) -> (S',L',J')
;
; three clusters sp, sm, pi
; elements have wavelength shift and rel intensity
 
if J ne 0 then g = 1+float(J*(J+1)-L*(L+1)+S*(S+1))/(2*J*(J+1)) else g=1.
if Jpr ne 0 then gpr = 1+float(Jpr*(Jpr+1)-Lpr*(Lpr+1)+Spr*(Spr+1))/(2*Jpr*(Jpr+1)) else gpr=1.

;for l1, M upper levels [2,1,0,-1,2] and lower [1,0,-1]
M=range(-J,J,1)  &  nM=n_elements(M)
Mpr=range(-Jpr,Jpr,1)  &  nMpr = n_elements(Mpr)
Iz=zeeman_relative_intensity(0,0,0,0)  ; initial null structure
Iz = replicate(Iz, [nM, nMpr])
for i=0, nM-1 do begin &$
  for k=0,nMpr-1 do begin &$
    Iz[i,k] = zeeman_relative_intensity(J,Jpr,M[i],Mpr[k]) &$
    Iz[i,k].gm = M[i]*g-Mpr[k]*gpr &$
end &$
end

if keyword_set(compress) then Iz=compress_zeeman_cluster(Iz)  ;get rid of zero-intensity components

return, Iz
end
