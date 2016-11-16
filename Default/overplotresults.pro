pro overplotResults

;Use radial avg function to overplot sets of data from experiments
;Experiment Title?
exTitle='1KW RF Hydrogen at 4.1mTorr '
startShots = [7760,7790,7820,7850]
k = n_elements(startShots)

numPoints = dataPoints(shot=startShots[0])

;dataset Ordering: temp, density, vplasma, isat
series = dblarr(4,numPoints,k)
;Series array = [dataSet,data,experiment]

for i = 0, k-1 do begin
  result = radial_avg(startShots[i])
  data = result[0]
  xAxis = result[1]
  
  series[0,*,i] = data.temp
  series[1,*,i] = data.density
  series[2,*,i] = data.vplasma
  series[3,*,i] = data.isat
  
endfor

m=4 ; 4 data sets temp, density, vplasma, isat
xAxTitle='Degrees'
yAxTitles=[' Temperature',' Density',' Vplasma',' I-Sat']
yAxUnits=[' (eV)',' (m^-3)',' (V)',' (mA)']

;
for j = 0, m do begin
window,j
plot,xAxis,series[j,*,0],psym=1
  for i = 1, k-1 do begin
oplot,xAxis,series[j,*,i],xtitle=xAxTitle,ytitle=yAxTitles[j],title=exTitle+yAxTitles[j]+yAxUnits[j],psym=i+1
  endfor
endfor


end