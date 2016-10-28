Pro nebula_beamfire,beamstopping=beamstopping,correctionmodel=correctionmodel,$
                    n2population=n2population,beamemission=beamemission,$
                    filesbms=filesbms, filesn2=filesn2 , filesbes=filesbes,$
                    besdata=besdata,dens_arr=dens_arr,refdens=refdens,t_e=t_e,n_e=n_e,$
                    correctiondata=correctiondata,diff=diff,intdens=intdens,n2data=n2data,$
                    rarr,zarr,tline,rpsi,zpsi,noplasma,bener,darr,$
                    bmass,i,j,t,temp,dens,frac_ions,dc,bvdrift
;----------------------------------------------------------------------------------
; Purpose : Calls ADAS to obtain atomic cross sections
; Author  : Stuart Henderson
; Date    : May 2011
; Contact : stuart.henderson@ccfe.ac.uk
;----------------------------------------------------------------------------------
;--------------------------------------------------
; Map electron temp and dens onto beam path
;--------------------------------------------------		     
ne_storever=fltarr(21,30) & ne_storehor=ne_storever
nebula_map,rpsi,zpsi,tline,temp,rarr(*,i,j),zarr(*,i,j),tline(t),tmpt_e
nebula_map,rpsi,zpsi,tline,dens,rarr(*,i,j),zarr(*,i,j),tline(t),tmpn_e
fraction=frac_ions[*,t]
t_e=fltarr(n_elements(rarr[*,0,0])) & n_e=t_e
energy=fltarr(n_elements(rarr[*,0,0]))
for k=0,n_elements(rarr[*,0,0])-1 do begin
  t_e(k)=tmpt_e(k,k)
  n_e(k)=tmpn_e(k,k)
endfor
if(noplasma)then begin
for k=0,n_elements(rarr[*,0,0])-1 do begin
  t_e(k)=1e-6
  n_e(k)=1e-6
endfor
endif
energy[*]=bener(t,dc)/bmass  
nocheck=1
;--------------------------------------------------
; Read in adas beam emission coefficients
;--------------------------------------------------	       
if keyword_set(beamemission)then begin
besdata=n_e
read_adf22,files=filesbes,data=bescx,$
    	   fraction=fraction,te=t_e,$
    	   dens=n_e/1.e6,energy=energy

besdata[*]=bescx[*]*1e-6*n_e[*]	
endif
;--------------------------------------------------
; Read in adas beam stopping coefficients
;--------------------------------------------------
if keyword_set(beamstopping)then begin
;print,'it count'
;save,filesbms,data,fraction,t_e,n_e,energy,file='~/save3.sav',/verb
;stop
read_adf21,files=filesbms,data=data,$
	   fraction=fraction,te=t_e,$
	   dens=n_e/1.e6,energy=energy
;stop
idx=where(finite(data) eq 0)
if idx(0) ne -1 then data(idx)=0.
refdens(0)=dens_arr(0,10,10,t,dc)
for k=1,n_elements(rarr[*,0,0])-1 do refdens(k)=$
		   refdens(k-1)*exp(-(n_e(k)/1.e6)*data(k)*$
		   darr(k)*100./(bvdrift(t,dc)*100.))


endif
;--------------------------------------------------
; Account for correctiondata in model
;--------------------------------------------------
if keyword_set(correctionmodel)then begin
correctiondata=fltarr(n_elements(rarr[*,0,0]))
correctiondata(0)=1.0
;stop
read_adf21,files=filesbms,data=correctioncx,$
	   fraction=fraction,te=mean(t_e)*[1,1],$
	   dens=intdens(t)/1.e6*[1,1],energy=mean(energy)*[1,1]&correctioncx=correctioncx
;stop
for k=1,n_elements(rarr[*,0,0])-1 do correctiondata(k)=$
		 correctiondata(k-1)*exp(-(intdens(t)/1.e6)*correctioncx[0]*diff(k)*$
		 100./(bvdrift(t,dc)*100.))


; refdens(0)=dens_arr(0,10,10,t,dc)
; for k=1,n_elements(rarr[*,0,0])-1 do refdens(k)=$
; ;		   refdens(k-1)*exp
; (-(n_e(k)/1.e6)*data(k)*$
; 		   darr(k)*100./(bvdrift(t,dc)*100.))

; plot,-(n_e(*)/1.e6)*data(*)*		   darr(*)*100,yr=[-1e8,0];./(bvdrift(t,dc)*100.)

; oplot,fltarr(30)-(intdens(t)/1.e6)*correctioncx[0]*diff(*),col=2;*		 100./(bvdrift(t,dc)*100.)),col=2

correctiondata2=correctiondata

id=where(t_e ne 1.)
;stop
if(id[0] eq -1)then id[0]=0
correctiondata=shift(correctiondata,id(0)+3)	
correctiondata[0:id[0]+3]=1.0
	 
;		 newdarr=fltarr(30)
;		 newdarr(id(0):*)=indgen(30-id[0])*darr(1)
;		 
;correctiondata2=fltarr(30)+1		 
;for k=id[0]+1,n_elements(rarr[*,0,0])-1 do correctiondata2(k)=$
;		 correctiondata2(k-1)*exp(-(intdens(t)/1.e6)*correctioncx[0]*diff(k)*newdarr(k)*$
;		 100./(bvdrift(t,dc)*100.))
;		 correctiondata=correctiondata2 		  
endif		  



;--------------------------------------------------
; Read in adas n2 population coefficients
;--------------------------------------------------	
if keyword_set(n2population)then begin
read_adf22,files=filesn2,data=n2data,$
    	   fraction=fraction,te=t_e,$
    	   dens=n_e/1.e6,energy=energy
endif	
end
