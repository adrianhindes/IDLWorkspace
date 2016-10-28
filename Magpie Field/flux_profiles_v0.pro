function get_coils_0, s, m, mirror_c, source_c

coil_pos = [-0.72, -0.54, -0.36, -0.18, 0., 0.264, 0.317,0.390, 0.443, 0.496, 0.549, 0.602]*100 ; cm


n= 13.5 ;number of windings
a=0.183 *100.0;coil radius in cmeters 

power_supply1=source_c 
I1=n*power_supply1
I2=n*power_supply1
I3=n*power_supply1
I4=n*power_supply1
I5=n*power_supply1

power_supply2=mirror_c
I6=n*power_supply2
I7=n*power_supply2
I8=n*power_supply2
I9=n*power_supply2
I10=n*power_supply2
I11=n*power_supply2
I12=n*power_supply2


coil_I=[s[0]*I1,s[1]*I2,s[2]*I3,s[3]*I4,s[4]*I5,m[0]*I6,m[1]*I7,m[2]*I8,m[3]*I9,m[4]*I10,m[5]*I11,m[6]*I12]

coil={position:coil_pos, current:coil_I, radius: a}
return, coil
end
;_____________________________________

function magpie_coil_field_0, rr, zz, coil

I = coil.current
aa = coil.radius
hh = coil.position

; I is coil current
; a is coil radius
; h is coil z position
; r and z are the field coordinates

  ;convert all these quantities to meters so that the permiability is in the correct units
  r=abs(rr/100.0)
  z=zz/100
  a=aa/100.0
  h=hh/100.0


k = sqrt(4.0*a*r/((r+a)^2.0+(z-h)^2.0))
Kk = !pi/2.*(1. + k^2.0/4.0 + 9*k^4.0/64.) ;elliptical functions
Ek = !pi/2.*(1. - k^2.0/4.0 - 3*k^4.0/64.) ;elliptical functions

mu0=4.0*!pi*1e-7
q = mu0*I*k/(4.0*!pi*sqrt(a*r^3.0))

Br = -q*(z-h)*(Kk - (2.0-k^2)/(2.0*(1-k^2))*Ek) 
Bz = q*r*(Kk + (k^2.0*(r+a)-2.0*r)/(2.0*r*(1-k^2.0))*Ek)

; on axis field - a cross check
Bz0 = mu0*I*a^2.0/2.0/(a^2.0+(z[*,0]-h)^2.0)^1.5

return,{Br: Br, Bz: Bz, Bz0: Bz0}

end
;___________________________________________________

pro flux_profiles_0, s_coils_active, m_coils_active,  mirror_c, source_c, rnorm, r_array, z_array, struct

;a program to calculate the magnetic field lines
;from the model of the magnetic field coil configuration.
;The complexity of this code arises as we need to correct for the
;shift in the central axis of the discharge. The amount of this shift corresponds
;to the position of the fudicial marks engraved in the base plate covering the floor
;of the chamber. This shift has already been taken into account in the imported 
;r_array values.

r=(indgen(130)/129.0)*6 -3.0 +0.2 ;add an offset of 0.2
;z=(indgen(1444)/1443.0)*55.0 +0.6
z=(indgen(1444)/1443.0)*120. -60.
rr=make_array(1444,130)
zz=make_array(1444, 130)

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

;stop
;rdev=r_array(100, 100)-r_array(100,99)
;
;
;;choose a column to pick out the r values
;r_col=reform(r_array[0,*])
;
;b= where((r_col gt 0.0-5e-2) and (r_col lt 0.0+5e-2))
;bint= pic_jsz/2.0- b[0]
;;stop
;
;pos=coil.position
;cur=coil.current
;rad=coil.radius
;
;for k=0, n_coils-1 do begin
;
;coils={position:pos[k], current:cur[k], radius:rad}
;
;      if b[0] le pic_jsz/2-1 then begin
;      diff=(pic_jsz-1)-b[0]
;      rfill=indgen(diff)*rdev
;      rmatrix=make_array(pic_isz, diff)
;          for y=0, pic_isz-1 do begin
;          rmatrix[y,*]=rfill
;          endfor
;      rmatrix[*,0]=0.000001
;      Bz=make_array(pic_isz,diff, n_coils, /double) 
;      Br=make_array(pic_isz,diff, n_coils, /double)
;      B_field=magpie_coil_field(rmatrix, z_array[*,b[0]:pic_jsz-1], coils)
;endif else begin
;      diff=b[0]  ;chooses size of array
;      rfill=indgen(diff)*rdev
;      rmatrix=make_array(pic_isz,diff)
;          for y=0, pic_isz-1 do begin
;          rmatrix[y,*]=rfill
;          endfor
;      rmatrix[*,0]=0.000001
;      Bz=make_array(pic_isz,diff, n_coils, /double) 
;      Br=make_array(pic_isz,diff, n_coils, /double) 
;      B_field=magpie_coil_field(rmatrix, z_array[*,0:b[0]-1], coils)
;endelse
;
;Bz[*,*,k]=B_field.bz
;Br[*,*,k]=B_field.br
;bz[*,0,*]=bz[*,1,*]
;br[*,0,*]=br[*,1,*]
;
;endfor
;
;br_tot=total(br, 3)
;bz_tot=total(bz, 3)
;b_mod=sqrt((br_tot)^2+(bz_tot)^2) ;is dominated by the bz term
;
;;need to calculate the magnetic flux through each radial surface
;d_r= (r_array[0,1]-r_array[0,0])/100
;
;      flux = 2*!pi*total(Bz_tot*rmatrix, 2, /cum)*d_r
;        flux=flux*1e4
;        
;flux_full= make_array(pic_isz,pic_jsz)
;
;    if b[0] le pic_jsz/2-1 then begin
;        flux_full[*, 0:b[0]]=rotate(rotate(flux[*,0:b[0]], 4),3)
;        flux_full[*, b[0]+1:pic_jsz-1]=flux[*,0:*]
;    endif else begin
;        flux_full[*, 0:b[0]-1]=rotate(rotate(flux[*,0:b[0]-1], 4),3)
;        mdiff=b(0)-n_elements(flux_full[0, b[0]:pic_jsz-1])
;        flux_full[*, b[0]:pic_jsz-1]=flux[*, 0:b[0]-1-mdiff]
;endelse

;tvscl, rebin(flux_full, 1444/4, 130*2)
erase

!p.position=0
!p.multi=[0,2,1]
device,decomp=0

imgplot,flux_full,z,r,xr=[0,60],xsty=1,/cb,xtitle='Axis(cm)',ytitle='Radius(cm)',title='Magnetic flux'
coil_pos = [-0.72, -0.54, -0.36, -0.18, 0., 0.264, 0.317,0.390, 0.443, 0.496, 0.549, 0.602]*100 ; cm
for i=0,n_elements(coil_pos)-1 do oplot,coil_pos(i)*[1,1],!y.crange,col=(i le 4) ? 2 : 3
plot, z,b_mod(*,60), title='Magnetic amplitude(T)',xtitle='Axis(cm)',ytitle='Magnetic amplitude(T)',xrange=[0,60]
struct={flux:flux_full, bz:bz_tot, btot:b_mod, br:br_tot}
;save,struct,filename='flux profile for 400 A and 50 A.save'
stop
end