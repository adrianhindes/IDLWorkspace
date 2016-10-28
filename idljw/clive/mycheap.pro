pro mycheap,data1,data2
 fileg='/users/prl/cam112/adas/adas/adf12/qef93#h/qef93#h_c6.dat'
 filee='/users/prl/cam112/adas/adas/adf12/qef97#h/qef97#h_en2_kvi#c6.dat'
 block=5

restore,file='~/save3.sav',/verb
ener=energy(0);*linspace(0,1,30)
nicx=n_e(0)
ticx=t_e(0)
zeff=nicx(0)*0 + 1.
bmag=nicx(0)*0 + 2.5

;stop
 read_adf12, file = fileg, block = block, ein = ener, $
   dion = nicx/1.0e6, tion = ticx , $
   zeff = zeff , bmag = bmag , data = data1
 read_adf12, file = filee, block = block, ein = ener, $
   dion = nicx/1.0e6, tion = ticx , $
   zeff = zeff , bmag = bmag , data = data2 


; plot,data1


end

; ;cxe(*,t,dc)=(ln2[*,t,dc]*data2+(1.0-ln2[*,t,dc])*data1)*1.0e-6
; ;     stop
;     endfor
;   endfor  

; ;----------------------------------------------
; ; Sum 3 density components
; ;----------------------------------------------
; ratenb=fltarr(nchords,n_elements(tline))
; for i=0,nchords-1 do begin 
;  for t=0,n_elements(tline)-1 do begin 
;   ratenb(i,t)=total(cxe(i,t,*)*ldens(i,t,*))
;  endfor
; endfor 
; ;----------------------------------------------------
; ; Calculate impurity density
; ;----------------------------------------------------
; idens=fltarr(nchords,n_elements(tline))
; cxemiss=fltarr(nchords,n_elements(tline))
; for i=0,nchords-1 do cxemiss(i,*)=interpol(cxemis(i,*),cxtime,tline)

; for i=0,nchords-1 do begin
;  for t=0,n_elements(tline)-1 do begin
;   idens(i,t)=4.0*!pi*cxemiss(i,t)/ratenb(i,t)
;  endfor 
; endfor
