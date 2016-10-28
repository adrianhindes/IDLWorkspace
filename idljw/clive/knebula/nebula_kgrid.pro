Pro nebula_kGrid, centre   ,chat     ,pslice   ,tline	,narray   ,beamlet ,rarr     ,zarr   ,$
                 btravel  ,bdens    ,dens_arr ,darr	,bhat	  ,ispace  ,mastbeam ,entrance,$
		 diff     ,rotangle,xx=xx,yy=yy,zz=zz
;----------------------------------------------------------------------------------
; Purpose : Set up geometry used in NEBULA
; Author  : Stuart Henderson
; Date    : May 2011
; Contact : stuart.henderson@ccfe.ac.uk
;----------------------------------------------------------------------------------
;-------------------------------------------
; Set up interogation grid
;-------------------------------------------
beamlet=fltarr(narray,pslice,pslice,3)
; In beam coordinates, cm !!
for i=0,narray-1 do begin
  for j=0,pslice-1 do begin   
      if mastbeam eq 'k1' then       btangent = 148.6
      if mastbeam eq 'k2' then       btangent = 171.848
      bspan=80.
      ; span above/below-> say 40cm each
      
    beamlet[i,*,j,0]=-btangent-bspan/2+indgen(pslice)*(bspan)/(pslice-1)
    beamlet[i,*,j,1]=btravel[0]+i*btravel[1]/(narray-1)+fltarr(pslice)
    beamlet[i,j,*,2]=bspan/2-indgen(pslice)*bspan/(pslice-1)
  endfor
endfor
xx=reform(beamlet(0,*,0,0))
yy=reform(beamlet(*,0,0,1))
zz=reform(beamlet(0,0,*,2))

nebula_ksetpini, xt,yt,zt,x2,y2,z2,norm,source,div,rotxt,rotyt,zt_att,mastbeam
rotxt=rotxt/100.
rotyt=rotyt/100.
zt_att=zt_att/100.
ispace=fltarr(narray,pslice,pslice)
;-------------------------------------------
; Set up neutral distribution 
;-------------------------------------------
for i=0,narray-1 do begin ; loop integration points
 for j=0,pslice-1 do begin ; Loop horizontal grid points
  for k=0,pslice-1 do begin ; Loop vertical grid points
   xgrid=beamlet(i,j,k,0)
   ygrid=beamlet(i,j,k,1)
   zgrid=beamlet(i,j,k,2) 
   ; Directional cosines between grid point and beamlet
   distance=sqrt((xt-xgrid)^2+(yt-ygrid)^2+(zt-zgrid)^2)  
   ihat=-(xt-xgrid)/distance
   jhat=-(yt-ygrid)/distance
   khat=-(zt-zgrid)/distance
   ;Directional cosines between beamlet and focus point
   focus=sqrt((xt-x2)^2+(yt-y2)^2+(zt-z2)^2)
   ibhat=-(xt-x2)/focus
   jbhat=-(yt-y2)/focus
   kbhat=-(zt-z2)/focus
   ;Calculate angle between grid point and beamlet
   cosdivangle=(ihat*ibhat+jhat*jbhat+khat*kbhat)<.99999999999  
   ;cosdivangle=round(cosdivangle*1e6)/1.e6
   
   divangle=acos(cosdivangle) 
   divangle=divangle/!dtor
   ;Divergence function
   j0=exp(-(divangle^2/(div^2)/2.))
   j0=j0/norm   
   resj0=j0/distance^2*source   
   ispace(i,j,k)=total(j0/distance^2*source   )*1e4 ; from cm-2 -> m-2
   id=where(finite(ispace(i,j,k),/nan))
   
;   stop
  endfor
 endfor 
endfor
;Turn into machine coordinates and in m
beamlet1=beamlet ; Bug sorted for SW beam - needed different 
for i=0,narray-1 do begin ; loop integration points
 for j=0,pslice-1 do begin ; Loop horizontal grid points
  for k=0,pslice-1 do begin ; Loop vertical grid points
   beamlet1(i,j,k,0)=(beamlet(i,j,k,0)*cos(rotangle)+beamlet(i,j,k,1)*sin(rotangle))/100.
   beamlet1(i,j,k,1)=(-beamlet(i,j,k,0)*sin(rotangle)+beamlet(i,j,k,1)*cos(rotangle))/100.
   beamlet1(i,j,k,2)=beamlet(i,j,k,2)/100.
  endfor
 endfor 
endfor   
beamlet=beamlet1
rarr=fltarr(narray,pslice,pslice) & zarr=rarr 
dens_arr=fltarr(narray,pslice,pslice,n_elements(tline),4)
bhat=fltarr(pslice,pslice,3)
For i=0,pslice-1 do begin
 For j=0,pslice-1 do begin
;-------------------------------------------
; Create R and Z arrays
;-------------------------------------------  
  ipbeyond=0.0
  rarr(0,i,j)=nebula_modulus([beamlet(0,i,j,0),beamlet(0,i,j,1)])
  for k=1,narray-1 do begin
    rarr(k,i,j)=nebula_modulus([beamlet(k,i,j,0),beamlet(k,i,j,1)])
    if(rarr(k-1,i,j)-rarr(k,i,j) lt 0)then ipbeyond=[ipbeyond,k] 
  endfor
;-------------------------------------------
; Account for change in sign of R after IP
;-------------------------------------------   
  if(n_elements(ipbeyond) ne 1)then begin
  ipbeyond=ipbeyond[1:*]
  ;rarr(ipbeyond,i,j)=-rarr(ipbeyond,i,j) ;This is actually a bug. I originally designed this to keep track of where IP occurs - 
                                          ;but rarr is needed to interpolate TS
                                          ;data - therefore can't be negative!
  endif
  zarr[*,i,j]=beamlet[*,i,j,2]
;-------------------------------------------
; Create distance travelled array
; Average distance travelled - correction
;------------------------------------------- 
;  darr(0,i,j)=0.
;  for k=1,narray-1 do darr(k,i,j)=sqrt((beamlet(k,i,j,0)-beamlet(k-1,i,j,0))^2+$
;                                      (beamlet(k,i,j,1)-beamlet(k-1,i,j,1))^2+$
;		                      (beamlet(k,i,j,2)-beamlet(k-1,i,j,2))^2)
  

;-------------------------------------------
; Create unit vectors for each psuedo beamlet
;------------------------------------------- 
  start=[beamlet(0,i,j,0),beamlet(0,i,j,1)]
  fin=[beamlet(narray-1,i,j,0),beamlet(narray-1,i,j,1)]
  hat=fin-start
  bhat[i,j,0:1]=hat/nebula_modulus(hat) 
  zhat=beamlet(0,i,j,2)-beamlet(narray-1,i,j,2)
  dist=sqrt((beamlet(0,i,j,0)-beamlet(narray-1,i,j,0))^2+$
  	    (beamlet(0,i,j,1)-beamlet(narray-1,i,j,1))^2)
  bhat[i,j,2]=zhat/dist 
  for t=0,n_elements(tline)-1 do begin      
    for bcomp=0,3 do begin       
      dens_arr[0,i,j,t,bcomp]=bdens[t,bcomp]    
    endfor    
  endfor		     
 Endfor
Endfor

darr=fltarr(narray) & act=darr & diff=act 
darr(0)=0.
mid=round((pslice-1)/2.0)
;-------------------------------------------
; Find path length difference
;------------------------------------------- 
for k=1,narray-1 do begin
 refpoint=[beamlet(k,mid,mid,0),beamlet(k,mid,mid,1),beamlet(k,mid,mid,2)]
 distance=sqrt((centre[0]-refpoint[0])^2+(centre[1]-refpoint[1])^2+(centre[2]-refpoint[2])^2)  
 newdist=sqrt((rotxt-refpoint[0])^2+(rotyt-refpoint[1])^2+(zt_att-refpoint[2])^2)
 distance1=max(newdist)-0.5*(max(newdist)-mean(newdist)) 
 diff(k)=abs(distance1-distance)
 tm=beamlet(k,mid,mid,*)-beamlet(k-1,mid,mid,*)
 darr(k)=sqrt(tm[0]^2+tm[1]^2+tm[2]^2)
; stop
endfor
End
