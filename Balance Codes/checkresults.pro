pro checkResults
;---===|Description|===---
;Check results of probe data; calculate theoretical particle balance and diffusion numbers
;from data
;Works for shots 7498 - 7982 
;---===|USAGE|===---
;Set two shot series for two z values from an experiment
;See google spreadsheet data tables for series descriptions and numbers
;Particle balance calculations done for every point given
;---===---
;---===|Notes|===---
;Assuming classical diffusion
;Assuming user has chosen two adjacent sets
;---===---

;---===|Reference Shot No.|===---
;Because lazyness, here's a summary of shots to choose from
;z=1 == 0cm, z=2 == 5cm etc... for shots 6/10/16
;|2.1 mTorr 3KW| -- |8.4 mTorr 3KW|
;7498 z = 1 ---     7708 z = 1
;7528 z = 2 ---     7678 z = 2
;7558 z = 3 ---     7648 z = 3
;7588 z = 4 ---     7618 z = 4
;|4.1 mTorr 1KW| -- |4.2 mTorr 10KW|
;7760 z = 1 ---     7982 z = 1
;7790 z = 2 ---     7955 z = 2
;7820 z = 3 ---     7927 z = 3
;7850 z = 4 ---     7895 z = 4
;---===---

startA = 7760
startB = 7790

;Retrieve probe measurement data
;Setting xdom = 1 gives back results with radial x values. xdom = 0 is probe angle
dataA = radialAvg(startA,xdom=1)
dataB = radialAvg(startB,xdom=1)

;radialAvg gets us probe measurements temperature and density (of electrons)
;Now retrieve relevant ionization rate for these shots
;Small issue though; light emission was taken discretely for each shot set, so with two sets
;we compromise and take the average resulting ionization rate
;This would correspond to a physical assumption that ionization rate doesn't change on the scale of 
;~5cm differences (axial) in MAGPIE discharges

;Having checked, it would appear this is reasonably true.

;Get the light emission data point from plasma shot using array lookup function
emissionA = exposurePoint(startA)
emissionB = exposurePoint(startB)

;Get ionization values
ionizationA = emissionValue(emissionA)
ionizationB = emissionValue(emissionB)
ionization = (ionizationA + ionizationB)/2.

;Get z values from shots used, convert to cm
;5cm offset since z=1 == 0 cm
zA = zLookup(startA)*5 -5 
zB = zLookup(startB)*5 -5

;Lookup pressure
pressureA = pLookup(startA)
pressureB = pLookup(startB)



loopLength = length(dataA.xaxis) -1

ionizationValues = fltarr(loopLength+1)
fluxTerms = fltarr(loopLength+1)
andvz = fluxTerms
nvda = fluxTerms
avdn = fluxTerms
perpLoss = fluxTerms



for i = 0,loopLength do begin
  density = (dataA.density)[i]
  diffDensity = abs((dataA.density)[i]-(dataB.density)[i])
  temp = (dataA.temp)[i] ;Should average A and B data sets here...?
  pressure = pressureA
  balance = balanceFunction(zA,zB,densityCharged=density,diffDens=diffDensity,tempElectron=temp,$
    ionizationRate = ionization)
   
  ionizationValues[i] = balance.ionization
  andvz[i] = balance.andvz
  nvda[i] = balance.nvda
  avdn[i] = balance.avdn
  perpLoss[i] = balance.perpLoss
    
    
  percent = (i+1)/(loopLength+1)
  print,floor(percent*100),' % done'
endfor



stop

fluxTerms = andvz + nvda + avdn + perpLoss
window,1
plot,dataA.xaxis,ionizationValues[*]
window,2
plot,dataA.xaxis,fluxTerms[*]


stop
end