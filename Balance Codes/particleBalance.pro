function particleBalance, balanceStruct, geomStruct, length, bval


nn = balanceStruct.dens_n
dN = balanceStruct.dN
ni = balanceStruct.dens_i
vz = balanceStruct.velz
dvz = balanceStruct.dvelz
ti = balanceStruct.t_i
te = balanceStruct.t_e
mi = balanceStruct.mi
  
area = geomStruct.Area
r1 = geomStruct.r1
r2 = geomStruct.r2
dA = geomStruct.dA

vol = area*length ;volume
del_ni = ni/r1

vol = voltruncone(r1,r2,length)
area = surfacetruncone(r1,r2,length)

vti=sqrt(2*!const.e*ti/mi) ;ion thermal vel
vte = sqrt(2*!const.e*te/!const.me)

ionRateCoefficient = 9E-9 * 1E-6
S = nn * ni * ionRateCoefficient

;Free path
t = S/nn ;ionization frequency
lambda_n = vz/t ;ionization free path
;print,"Mean Free Ionization Path of Neutral =",lambda_n

perp_flux = classical_diffusion(bval, te, ti, vte, vti, ni, dN, mi)

;Particle Balance
SV = S*vol
;print,"SV = ", SV

AndVz = area * nn * dVz
;print,"AndVz = ",AndVz

nvdA = nn * vz * dA
;print,"nvdA = ",nvdA

AvdN = area * vz * dN
;print,"AvdN = ", AvdN

perpLoss = perp_flux*area
;print,"Perpendicular Losses = ",perpLoss

balance = {SV: SV, andvz: AndVz, nvda: nvdA, AvdN: AvdN, perpLoss: perpLoss}
return,balance

end