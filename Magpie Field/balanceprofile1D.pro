pro balanceProfile1D

z_length = 1444
norm_z = 1443.0
diam = 130
norm_r = 129.0

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

y=1
n=0
s_coils_active = [n,y,y,y,y]
m_coils_active = [n,n,y,y,y,y,y]
mirror_c = 400
source_c = 50
rnorm = -0.2

flux = fluxFull(s_coils_active, m_coils_active, mirror_c, source_c, rr, zz)
stop
startL = 1
endL = 10

z1_index = value_locate(z,startL)
z2_index = value_locate(z,endL)

;B field flux val to track
flux_track = 25

;Velocity (z direction)
vz = 300 ;m/s
dVz = 0

;Area and dA

fluxArea = flux_area(flux.Flux, r, z1_index, z2_index, flux_track)

A = fluxArea.Area
dA = fluxArea.dA
radius = fluxArea.r1

A = A*1E-4
dA = dA * 1E-4
radius = radius * 1E-2

;Calculate Ionization Constant
n_i = 3E17 ;assume density
length = startL - endL;cm
length = length * 1E-2
vol = A*length ;volume
del_ni = n_i/radius

cylA = 2*!pi*radius*length

;Neutral density
;p = 1E3 ;Torr
p = 0.13332237
temp = 300
n_n = (p)/(!const.k*temp)
;del_nn = n_n/0.04 ;Assume linear drop off of density

m_i=1.67d-27*40 ;Argon ion mass

t_i = 0.1 ;ev
t_e = 5

vti=sqrt(2*!const.e*t_i/m_i) ;ion thermal vel
vte = sqrt(2*!const.e*t_e/!const.me)

ionRateCoefficient = 9E-9 * 1E-6
S = n_n * n_i * ionRateCoefficient
;Free path
t = S/n_n ;ionization frequency
lambda_n = vz/t ;ionization free path
print,"Mean Free Ionization Path of Neutral =",lambda_n

;Density flucatation
dN = 1.2E17 ;from Jaweook's data

bval = (mean(flux.b_mod[z1_index,*]) + mean(flux.b_mod[z1_index,*]))/2.

perp_flux = classical_diffusion(bval, t_e, t_i, vte, vti, n_i, del_ni, m_i)

;Particle Balance
SV = S*vol
print,"SV = ", SV

AndVz = A * n_n * dVz
print,"AndVz = ",AndVz

nvdA = n_n * vz * dA
print,"nvdA = ",nvdA

AvdN = A * vz * dN
print,"AvdN = ", AvdN

perpLoss = perp_flux*cylA
print,"Perpendicular Losses = ",perpLoss


imgplot,Flux.Flux,z,r,xr=[0,60],xsty=1,/cb,xtitle='Axis(cm)',ytitle='Radius(cm)',title='Magnetic flux'
coil_pos = [-0.72, -0.54, -0.36, -0.18, 0., 0.264, 0.317,0.390, 0.443, 0.496, 0.549, 0.602]*100 ; cm
for i=0,n_elements(coil_pos)-1 do oplot,coil_pos(i)*[1,1],!y.crange,col=(i le 4) ? 2 : 3
plot, z, Flux.B_mod(*,60), title='Magnetic amplitude(T)',xtitle='Axis(cm)',ytitle='Magnetic amplitude(T)',xrange=[0,60]
struct={flux:Flux.Flux, bz:Flux.Bz, btot:Flux.B_mod, br:Flux.Br}

stop

end
