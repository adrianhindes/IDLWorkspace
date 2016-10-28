function fluxFull, s_coils_active, m_coils_active, mirror_c, source_c, r_array, z_array

coil = get_coils(s_coils_active, m_coils_active, mirror_c, source_c)

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

return,{Flux: flux_full, BField: B_field, B_Mod: b_mod, Br: br_tot, Bz: bz_tot}

end
