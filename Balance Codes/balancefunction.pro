function balanceFunction, zStart, zEnd, pressure=pressure,densityCharged=densityCharged,diffDens=diffDens, $
  velocity=velocity,diffVelocity=diffVelocity,bVal=bVal,tempIon=tempIon,tempElectron=tempElectron, $
  tempNeutral=tempNeutral,ionizationRate=ionizationRate,species=species

;This function takes in supplied knowns, and calculates particle balance
;Unknown values are set to defaults


;Constants
;e_charge = !const.e
vacuum_permittivity = 8.854188E-12

m_e = !const.me
boltzmann_si = !const.k
boltzmann_ev = !const.k/!const.e
;---===---

default,pressure,1 ;Usual pressure in mTorr
default,densityCharged,3E17    ;from Jaewook's data NOTE: assuming quasineutral plasma, ni=ne of course!
default,diffDens, 1.2E17 ;from Jaewook's data
default,velocity,300 ;from Romana's paper
default,diffVelocity,10 ;total guesstimate
default,bVal,0.01 ;arbitrary(?), necessary for diffusion code
default,tempIon,0.1    ;reasonable operating temp
default,tempElectron,10     ;as above
default,tempNeutral,300 ;in Kelvin (Note this is not equal to ti in this default assumption!)
default,ionizationRate,(9E-9 * 1E-6) ;From ADAS tables
default,species,'hydrogen'

molarH2 = 2.01 ;gram/mol
molarAr = 39.948 ;gram/mol

if species eq 'argon' then begin
  massIon = 39.948*!const.mp
  molarMass = molarAr
endif else begin
  massIon = !const.mp
  molarMass = molarH2
endelse

;Neutral density from pressure using Ideal Gas Law
;Note, assuming neutral hydrogen is molecular (H2)

pressPascals = 0.13332237 * pressure ;convert to Pascals
densityNeutral = pressPascals*molarMass/(!const.k*tempNeutral)/!const.R ;pressure/temp (in kelvin)

region = balanceRegion(zStart,zEnd)

area = region.area ;surface area endplate (start)
diffArea = region.diffArea ;dA surface area endplate (end, difference)
perpArea = region.perpArea ;surface area not including end surfaces (for perp flux)
volume = region.volume



perpFlux = classical_diffusion(bval, tempElectron, tempIon,$
  densityCharged, diffDens, massIon) ;Assuming ambipolar E field is valid

;Particle Balance
SV = ionizationRate*volume ;ionization term

AndVz = area * densityNeutral * diffVelocity


nvdA = densityNeutral * velocity * diffArea


AvdN = area * velocity * diffDens


perpLoss = perpFlux*perpArea

balanceResult = create_struct('ionization',SV,'andvz',andvz,'nvda',nvda,'avdn',avdn,'perpLoss',perpLoss)
return,balanceResult

end