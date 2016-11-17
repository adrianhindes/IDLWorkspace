
;_____________________________________


;___________________________________________________

pro flux_profiles, s_coils_active, m_coils_active,  mirror_c, source_c, rnorm, r_array, z_array, struct

;a program to calculate the magnetic field lines
;from the model of the magnetic field coil configuration.
;The complexity of this code arises as we need to correct for the
;shift in the central axis of the discharge. The amount of this shift corresponds
;to the position of the fudicial marks engraved in the base plate covering the floor
;of the chamber. This shift has already been taken into account in the imported 
;r_array values.

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


default, s_coils_active, [y,y,y,y,y]                ;source coils are active indicated with 'y' (starting from end nearest pump), not active: 'n'
default, m_coils_active, [n,n,y,y,y,y,y]             ;mirror coils are active indicated with 'y' (starting from end nearest pump), not active: 'n'
default, mirror_c, 400
default, source_c, 50
default, rnorm, -0.2  
default, r_array, rr
default, z_array, zz


coil=get_coils(s_coils_active, m_coils_active, mirror_c, source_c)
n_coils=n_elements(coil.position)
pic_jsz=n_elements(r_array[0,*])
pic_isz=n_elements(r_array[*,0])

pos=coil.position
cur=coil.current
rad=coil.radius

      Bz=make_array(pic_isz,pic_jsz, n_coils, /double) 
      Br=make_array(pic_isz,pic_jsz, n_coils, /double)


for k=0, n_coils-1 do begin
coils={position:pos[k], current:cur[k], radius:rad}
B_field=magpie_coil_field(r_array, z_array, coils)
Bz[*,*,k]=B_field.bz
Br[*,*,k]=B_field.br
bz[*,0,*]=bz[*,1,*]
br[*,0,*]=br[*,1,*]
endfor

br_tot=total(br, 3)
bz_tot=total(bz, 3)
b_mod=sqrt((br_tot)^2+(bz_tot)^2) ;is dominated by the bz term

;need to calculate the magnetic flux through each radial surface
d_r= (r_array[0,1]-r_array[0,0])/100

fmid=Bz_tot*abs(r_array)
r_col=reform(r_array[0,*])
b= where((r_col gt 0.0-5e-2) and (r_col lt 0.0+5e-2))

fmid[*,0:b(0)-1]=rotate(total(rotate(fmid[*,0:b(0)-1], 7),2,/cum),7)
fmid[*,b(0):pic_jsz-1]=total(fmid[*,b(0):pic_jsz-1],2, /cum)
  
      flux = 2*!pi*fmid*d_r
        flux_full=flux*1e4


erase 
!p.position=0
!p.multi=[0,2,1]
device,decomp=0

;Particle Balance Modelling -A.H. 8/8/16
;n_scale = 1E17
;np = (1/4.)*(-(7./8.)*(r-1)^3 + (r+8)) ;roughly fit profile to Jaewook's density data
;np = np/(max(np)-min(np)) ;normalize
;np = np*n_scale
;np[Where(n LT 0)]=0

;Length of tube to consider

z1 = 0
z2 = 10

z1_index = value_locate(z,z1)  
z2_index = value_locate(z,z2)  

;B field flux val to track
flux_track = 10

;Velocity (z direction)
vz = 300 ;m/s
dVz = 0 

;Area and dA

fluxArea = flux_area(flux_full, r, z1_index, z2_index, flux_track)

A = fluxArea.Area
dA = fluxArea.dA
radius = fluxArea.r1
;
;;Radius tracking test
;bi = 30
;flux_tracking = indgen(bi)
;flux_tracking = flux_tracking + 1
;
;radii = fltarr(bi)
;for i = 0, bi-1 do begin &$
;  fluxes = flux_area(flux_full, r, z1_index, z2_index, flux_tracking[i])
;  radii[i] = fluxes[2]
;end

;plot,flux_tracking,radii
stop

A = A*1E-4
dA = dA * 1E-4
radius = radius * 1E-4

;Calculate Ionization Constant
n_i = 3E17 ;assume density
length = z2 - z1;cm
length = length * 1E-2
vol = A*length ;volume
del_ni = n_i/radius


;Neutral density
;p = 1E3 ;Torr
p = 0.13332237
temp = 300  
n_n = (p)/(!const.k*temp)
;del_nn = n_n/0.04 ;Assume linear drop off of density

m_i=1.67d-27*40 ;Argon ion mass

t_i = 0.1 ;ev
t_e = 10

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

bval = 0.01
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

;difference = abs(SV - (AndVz + nvdA + AvdN))
;print,"Difference = ",difference

imgplot,flux_full,z,r,xr=[0,60],xsty=1,/cb,xtitle='Axis(cm)',ytitle='Radius(cm)',title='Magnetic flux'
coil_pos = [-0.72, -0.54, -0.36, -0.18, 0., 0.264, 0.317,0.390, 0.443, 0.496, 0.549, 0.602]*100 ; cm
for i=0,n_elements(coil_pos)-1 do oplot,coil_pos(i)*[1,1],!y.crange,col=(i le 4) ? 2 : 3
plot, z,b_mod(*,60), title='Magnetic amplitude(T)',xtitle='Axis(cm)',ytitle='Magnetic amplitude(T)',xrange=[0,60]
struct={flux:flux_full, bz:bz_tot, btot:b_mod, br:br_tot}


stop

end