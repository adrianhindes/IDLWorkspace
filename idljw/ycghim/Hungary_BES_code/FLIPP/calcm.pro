pro calcM,M,ned,z,probe_amp=probe_amp,xrr=xrr,calc_point=nd,zeff=zeff,$
       li2p_rec=p0,errormess=errormess,beamenergy=beamenergy,tempfile=tempfile
; **************************** calcm.pro ***************** S. Zoletnik **************
;           Major editing                                 4.5.2001  S. Zoletnik
; Calculation of response matrix for density change       
;   
;
; INPUT:
; ned,z:  Calculates M matrix for a given density profile ned(z)
;         length of ned and z vectors should be less than 30  n_e: [cm-3]
; probe_amp: amplitude of density peak for response function calculation
; xrr: the z values where the light profile is calculated
; calc_point: The number of points for which the density profile is varied
;             (Variations at z(0)....z(calc_point-1)
; zeff: zeff value for the light calculation
; beamenergy: Energy of beam in keV
; tempfile: Temperature file in temp/
; OUTPUT:
; M: matrix
; li2p_rec: the light profile reconstructed from the input density profile
; errormess: error message or ''
; *********************************************************************************
                                
default,beamenergy,48.

;if (((size(z))(1) ge 30) or ((size(ned))(1) ge 30)) then begin
;  errormess='calcm.pro: Too long vectors!'
;  print,errormess
;  return
;endif  
default,probe_amp,(min(ned)/3 < 1e12)
if (not keyword_set(xrr)) then begin
  erromess = 'xrr argument to calcm.pro should be set!
  print,errormess
  return
endif  

default,nd,(size(z))(1)
np=(size(xrr))(1)
M=dblarr(np,nd)

zv=fltarr((size(z))(1),nd+1)
n1v=fltarr((size(z))(1),nd+1)
zv(*,0)=z
n1v(*,0)=ned  
for i=1,nd do begin
  zv(*,i)=z
  n1v(*,i)=ned
  n1v(i-1,i)=n1v(i-1,i)+probe_amp
endfor
                          
li2p=calc_light(zv,n1v*1e6,xrr,zeff=zeff,beamenergy=beamenergy,$
          tempfile=tempfile,errormess=errormess)
if (errormess ne '') then begin
  print,errormess
  return
endif
    
p0=li2p(*,0)
for i=0,nd-1 do begin
  M(*,i)=li2p(*,i+1)-p0
endfor
M=M/(probe_amp/1e13)

end
