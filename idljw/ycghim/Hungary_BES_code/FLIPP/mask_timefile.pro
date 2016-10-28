pro mask_timefile,timefile,mask=mask

; ************** mask_timefile.pro *********** S. Zoletnik 27.3.1998 **
; Selects the time intervals from timefile which overlap with the
; time intervals of mask timefile.
; Writes the resulting timefile as <timefile>
; *********************************************************************

min_t=1e-3  

t=loadncol('time/'+timefile,2,/silent)
nt=(size(t))(1)
mask_t=loadncol('time/'+mask,2,/silent)
mask_nt=(size(mask_t))(1)
                     
t1=0
t2=t1
for i=0,nt-1 do begin
  for j=0,mask_nt-1 do begin
    if (not ((t(i,0) ge mask_t(j,1)) or (t(i,1) le mask_t(j,0)))) then begin
      if (t(i,0) ge mask_t(j,0)) then t1=[t1,t(i,0)] else t1=[t1,mask_t(j,0)]
      if (t(i,1) le mask_t(j,1)) then t2=[t2,t(i,1)] else t2=[t2,mask_t(j,1)]
    endif
  endfor
endfor

ind=where(t2-t1 ge min_t)
if (ind(0) lt 0) then begin
  print,'There is no common part of '+timefile+' and '+mask+'.'
  print,timefile+' is not modified.'      
  return
endif
t1=t1(ind)
t2=t2(ind)
        
openw,unit,'time/'+timefile,/get_lun
intn=n_elements(t1)	
for i=0,intn-1 do begin
  printf,unit,t1(i),t2(i)
endfor
close,unit
free_lun,unit	
end
