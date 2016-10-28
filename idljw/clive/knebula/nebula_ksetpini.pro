pro nebula_ksetpini,xt,yt,zt,x2,y2,z2,norm,source,divang ,rotxt,rotyt,zt_att,mastbeam
;beam,rotyt,rotxt,zt,rotx2,roty2,z2,norm,source,divang

;new part,correspond to PINI beams
nebula_read_pinigrid,xpini,zpini, pn=pn
beam=mastbeam

;point=[70.,-712.7,0] ; position of the beam centre in tor coord cm.

if beam eq 'sw' then begin
;    point(2)=-0.1              ; down

endif

if(beam eq 'ss')then begin
rotangle=4.84*!dtor
machinepoint=[point[0]*cos(rotangle)+point[1]*sin(rotangle),-point[0]*sin(rotangle)+point[1]*cos(rotangle),point[2]]
endif 
if beam eq 'sw' then begin
rotangle=64.84*!dtor
machinepoint=[point[0]*cos(rotangle)+point[1]*sin(rotangle),-point[0]*sin(rotangle)+point[1]*cos(rotangle),point[2]]
endif

if beam eq 'k1' then begin
    rotangle=-90*!dtor
    point =[-148.7,-1340.34699,0]
    machinepoint=[point[0]*cos(rotangle)+point[1]*sin(rotangle),-point[0]*sin(rotangle)+point[1]*cos(rotangle),point[2]]
endif

if beam eq 'k2' then begin
    rotangle=-94*!dtor
    point=[-171.808,-1328.75,0]
    machinepoint=[point[0]*cos(rotangle)+point[1]*sin(rotangle),-point[0]*sin(rotangle)+point[1]*cos(rotangle),point[2]]
endif

;stop
;vert_foc=517.2 ;cm
vert_foc=1000.;/3 ;New focus taken from Gee, SJ, etal, MAST Neutral beam Long Pulse Upgrade, 2005
horiz_foc=1000.;/3;cm


n_beamlets=n_elements(xpini)*2
yt=replicate(point[1],n_beamlets)
xt=fltarr(n_elements(xpini)*2)
xt[0:n_elements(xpini)-1]=xpini+point[0]
xt[n_elements(xpini):n_elements(xpini)*2-1]=xpini+point[0]
zt=fltarr(n_elements(zpini)*2)
zt[0:n_elements(zpini)-1]=zpini
zt[n_elements(zpini):n_elements(zpini)*2-1]=-zpini
;div=replicate(0.354,n_beamlets) ; div (std)of each beamlet
div=replicate(0.9/sqrt(2),n_beamlets) ; div (std)of each beamlet
;div=replicate(0.45*sqrt(2),n_beamlets) ; Factor of root 2 out in Mikael code
divang=div[0]
focusx=replicate(point[0],n_beamlets)  ; x,y,z, positions for steering of each beamlet
focusy=horiz_foc+yt
focusz=zt-horiz_foc/vert_foc*zt
x2=focusx
y2=focusy
z2=focusz

rotx2=x2*cos(rotangle)+y2*sin(rotangle)
roty2=-x2*sin(rotangle)+y2*cos(rotangle)
rotxt=xt*cos(rotangle)+yt*sin(rotangle)
rotyt=-xt*sin(rotangle)+yt*cos(rotangle)


unitss=[rotx2(0),roty2(0),0]-machinepoint
unitss=unitss/sqrt(unitss(0)^2+unitss(1)^2+unitss(2)^2)



;print,'SS unit vector: ',unitss
;print,'SS centre point: ',machinepoint

;plot,[rotxt(0),rotx2(0)]/100,[rotyt(0),roty2(0)]/100,xrange=[-2,2],yrange=[-2,2]
;for i=0,n_beamlets-1 do oplot,[rotxt(i),rotx2(i)]/100,[rotyt(i),roty2(i)]/100
;oplot,[xtsw(0),x2sw(0)]/100,[ytsw(0),y2sw(0)]/100
;for i=0,n_beamlets-1 do oplot,[xtsw(i),x2sw(i)]/100,[ytsw(i),y2sw(i)]/100


;wall=2
;xcir=fltarr(361) & ycir=xcir
;for i=0,360 do begin
;
 ;xcir(i)=wall*cos(i*!dtor)
 ;ycir(i)=wall*sin(i*!dtor)
;endfor
;oplot,xcir,ycir
;wall=0.7
;xcir=fltarr(361) & ycir=xcir
;for i=0,360 do begin
; xcir(i)=wall*cos(i*!dtor)
; ycir(i)=wall*sin(i*!dtor)
;endfor
;oplot,xcir,ycir,linestyle=1



;plot,[yt(0),y2(0)]/100,[zt(0),z2(0)]/100,yrange=[-1,1]
;for i=0,n_beamlets-1 do oplot,[rotyt(i),roty2(i)]/100,[zt(i),z2(i)]/100
;***************************************************************
;normalization procedure 
 t=findgen(1000)/999*!Pi/2
 norm=fltarr(n_beamlets)
  for i=0,n_beamlets-1 do $ 
     norm[i]=2*!pi*int_tabulated(t,exp(-(t/(div[i]*!Pi/180))^2/2)*sin(t))   

;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;this is a just temperary part for the setting of initial
;image of the beam  (intensity of every beamlet)
  source=replicate(1,n_beamlets)
  source=source/total(source)
; for attenuation calculations only  


;temporary part,correspond to pini beams
n_beamlets_att=15; number of beamlets to consider

yt_att =replicate(point[1],n_beamlets_att)
att_ind= round(n_beamlets*findgen(n_beamlets_att)/n_beamlets_att>1)
xt_att=xt(att_ind)
zt_att=zt(att_ind)
norm_att=norm(att_ind)
; plot the PINI beamlets and the reduced set used for the attenutation calculation
;;window,0, xsize=350, ysize=700
;plot,xt,zt,psym=1,/iso
;oplot,xt_att,zt_att,psym=4,thick=3


;Part to find the correspondace between beamlets for shape calculation(nbeamlets) and 
;beamlets for beam attenuation calculation

ind_att=fltarr(n_beamlets)
for i=0,n_beamlets-1 do begin
Rdist=sqrt((xt[i]-xt_att)^2+(yt[i]-yt_att)^2+(zt[i]-zt_att)^2)
min_rdist=min(rdist,indmin)
ind_att[i]=indmin

endfor

end
