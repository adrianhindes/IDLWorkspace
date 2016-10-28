Pro nebula_plasmaline,dens,rpsi,zpsi,intdens,tline	


viewpoint=[-2.,0,0.]
ang=-15.*!dtor
ipoints=20
dircos=[cos(ang),sin(ang),0.]
viewarr=fltarr(ipoints,3)
dist=3.9
viewarr[*,0]=viewpoint[0]+findgen(ipoints)*dist*dircos[0]/(ipoints-1)
viewarr[*,1]=viewpoint[1]+findgen(ipoints)*dist*dircos[1]/(ipoints-1)
viewarr[*,2]=viewpoint[2]+findgen(ipoints)*dist*dircos[2]/(ipoints-1)
viewr=fltarr(ipoints)
for i=0,ipoints-1 do viewr(i)=nebula_modulus([viewarr[i,0],viewarr[i,1]])
nebula_map,rpsi,zpsi,tline,dens,viewr,0,tline,densline
intdens=fltarr(n_elements(dens(0,0,*)))
for t=0,n_elements(dens(0,0,*))-1 do intdens(t)=mean(densline(*,t))*dist
id=where(intdens lt 0)
if(id[0] ne -1)then intdens[id]=1.e0



End
