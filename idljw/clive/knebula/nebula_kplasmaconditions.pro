PRO nebula_kplasmaconditions, shot      ,tline     ,rpsi=rpsi ,$
		             zpsi=zpsi ,temp=temp ,dens=dens,psi=psi
;----------------------------------------------------------------------------------
; Purpose : Set up plasma conditions used in NEBULA
; Author  : Stuart Henderson
; Date    : May 2011
; Contact : stuart.henderson@ccfe.ac.uk
;----------------------------------------------------------------------------------		      
;--------------------------------
; Get MAST thomson data
;--------------------------------

;nebula_exthomson,shot,t_e,n_e,rpsi,zpsi,tpsi,psi,qprof,qtime,qrad
nebula_kexthomson,shot,t_e,n_e,rpsi,zpsi,tpsi,psi,qprof,qtime,qrad


;--------------------------------
;interpolate onto time line
;--------------------------------
tempdef=fltarr(n_elements(rpsi),n_elements(zpsi),n_elements(tline))
densdef=tempdef & psidef=densdef
for i=0,n_elements(rpsi)-1 do begin
  for j=0,n_elements(zpsi)-1 do begin  
    tempdef[i,j,*]=interpolo(t_e[i,j,*],tpsi,tline)
    densdef[i,j,*]=interpolo(n_e[i,j,*],tpsi,tline)
    psidef[i,j,*]=interpolo(psi[i,j,*],tpsi,tline)      
  endfor
endfor  
nebula_default,temp,tempdef
nebula_default,dens,densdef
;filetest='~cam112/knebula/'
;if(file_test(filetest))then begin
;    filename=string(shot,format='("~cam112/knebula/plasmabackground",I5,".sav")')
;    save,temp,dens,psi,rpsi,zpsi,tpsi,tline,psidef,tempdef,densdef,qprof,qtime,qrad,file=filename
;endif else begin
;    print,'Please change file path for IDL save file in nebula/beamcode/version1.0/nebula_plasmaconditions.pro'
;    stop
;endelse
end
