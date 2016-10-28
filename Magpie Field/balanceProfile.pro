pro balanceProfile

z_length = 1444
norm_z = 1443.0
diam = 130
norm_r = 129.0
stop
r=(indgen(diam)/norm_r)*6 -2.8  ;4cm radius
z=(indgen(z_length)/norm_z)*120 -60 ;60cm

rr=make_array(z_length,diam)
zz=make_array(z_length, diam)

for i=0, 1444-1 do begin
  rr[i,*]=r[*]
endfor

for j=0, 130-1 do begin
  zz[*,j]=z[*]
endfor
stop
y=1
n=0
s_coils_active = [n,y,y,y,y]
m_coils_active = [n,n,y,y,y,y,y]
mirror_c = 400
source_c = 50
rnorm = -0.2

flux = fluxFull(s_coils_active, m_coils_active, mirror_c, source_c, rr, zz)
stop
;Keep Tube length Constant
startL = 0
endL = 10

length = startL - endL ;cm
length = length * 1E-2

z1_index = value_locate(z,startL)
z2_index = value_locate(z,endL)

bval = (mean(flux.b_mod[z1_index,*]) + mean(flux.b_mod[z1_index,*]))/2.

;Geometry Loop
fluxIndices = 30
flux_tracking = indgen(fluxIndices)
flux_tracking = flux_tracking + 1
stop
area = fltarr(fluxIndices)
dA = area
radii1 = area
radii2 = area

for i = 0, fluxIndices-1 do begin &$
  fluxGeom = flux_area(flux.Flux, r, z1_index, z2_index, flux_tracking[i])
  area[i] = fluxGeom.Area
  dA[i] = fluxGeom.dA
  radii1[i] = fluxGeom.r1
  radii2[i] = fluxGeom.r2
end

;Scaling
area = area*1E-4
dA = dA * 1E-4
radii1 = radii1 * 1E-2
radii2 = radii2 * 1E-2

;Mass and Temperature
m_i=1.67d-27*40 ;Argon ion mass

t_i = 0.1 ;ev
t_e = 10

;Velocity (z direction)
vz = 300 ;m/s
dVz = 0

;Density
n_i = 6E17 ;assume density
dN = 1.2E17 ;from Jaweook's data

;Neutral parameters
press = 0.13332237
temp = 5000
n_n = (press)/(!const.k*temp)

;Create Structure for Balance Function
balanceStruct = {dens_n: n_n, dN: dN, dens_i: n_i, $
  velz: vz, dvelz: dVz, t_i: t_i, t_e: t_e, mi: m_i}
;Particle Balance Loop
;
;Loop through different radii annular regions
ionization = fltarr(fluxIndices)
AndVzArray = ionization
nvdAArray = ionization
AvdNArray = ionization
perpLossArray = ionization

for i = 0, fluxIndices -1 do begin &$
  a = area[i]
  r1 = radii1[i]
  r2 = radii2[i]
  dAa = dA[i]
  geomStruct = {area: a, r1: r1, r2: r2, dA: dAa}
  balance = particleBalance(balanceStruct,geomStruct,length,bval)
  ionization[i] = balance.SV
  AndVzArray[i] = balance.andvz
  nvdAArray[i] = balance.nvda
  AvdNArray[i] = balance.avdn
  perpLossArray[i] = balance.perpLoss
end



stop
;Plot results as a function of (smaller r2) radius


rhs = andvzarray + nvdaarray + avdnarray + perpLossArray

ratio = rhs/ionization

plot,radii2,ratio


stop

;Now loop through different lengths of annular regions

startL = 0
lengthIndices = 400
maxLength = 20.
endLengths = (indgen(lengthIndices)+1)/maxLength
fixedFluxTrack = 26 ;Fix a flux tracking value (~25 gives maximum radii)

ionization2 = fltarr(lengthIndices)
AndVzArray2 = ionization2
nvdAArray2 = ionization2
AvdNArray2 = ionization2
perpLossArray2 = ionization2

fluxGeom2 = flux_area(flux.Flux, r, z1_index, z2_index, fixedFluxTrack)

for i = 0, lengthIndices -1 do begin &$
length_i = endLengths[i]-startL
balance = particleBalance(balanceStruct,fluxGeom2,length_i,bval)
ionization2[i] = balance.SV
AndVzArray2[i] = balance.andvz
nvdAArray2[i] = balance.nvda
AvdNArray2[i] = balance.avdn
perpLossArray2[i] = balance.perpLoss
end

stop

rhs2 = andvzarray2 + nvdaarray2 + avdnarray2 + perpLossArray2

ratio2 = rhs2/ionization2

plot,endLengths,ratio2

stop

imgplot,Flux.Flux,z,r,xr=[0,60],xsty=1,/cb,xtitle='Axis(cm)',ytitle='Radius(cm)',title='Magnetic flux'
coil_pos = [-0.72, -0.54, -0.36, -0.18, 0., 0.264, 0.317,0.390, 0.443, 0.496, 0.549, 0.602]*100 ; cm
for i=0,n_elements(coil_pos)-1 do oplot,coil_pos(i)*[1,1],!y.crange,col=(i le 4) ? 2 : 3
plot, z, Flux.B_mod(*,60), title='Magnetic amplitude(T)',xtitle='Axis(cm)',ytitle='Magnetic amplitude(T)',xrange=[0,60]
struct={flux:Flux.Flux, bz:Flux.Bz, btot:Flux.B_mod, br:Flux.Br}

stop

end
