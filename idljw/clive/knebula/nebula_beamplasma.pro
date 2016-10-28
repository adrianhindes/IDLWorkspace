Pro nebula_beamplasma,rarr   , zarr , dens_arr , temp    , dens  ,$
                      rpsi   , zpsi , bener    , bvdrift , tline ,$
	              pslice , darr , beamlet  , n2pop   , bmass ,$
	              frac_ions     , element  , noplasma, ispace,$
	              div_beam_att  , intdens  , diff    , bemis_arr
;----------------------------------------------------------------------------------
; Purpose : Fires the beam into the plasma
; Author  : Stuart Henderson
; Date    : May 2011
; Contact : stuart.henderson@ccfe.ac.uk
;----------------------------------------------------------------------------------
;-------------------------------------------------
; Specify files for atomic data - from ADAS
;-------------------------------------------------
nebula_adaselements,element,fileadf21,fileadf22,fileadf22e
filesbms=fileadf21
filesn2=fileadf22
filesbes=fileadf22e

;-------------------------------------------------
; Iterate the beamlets into the plasma for each 
; time-step and beam component
;-------------------------------------------------
print,'*************************'
print,'Firing beam into plasma'
print,'*************************'
n2pop=dens_arr
weight=dens_arr 
bemis_arr=dens_arr
meanweight=fltarr(30)
refdens=fltarr(n_elements(rarr[*,0,0]))
centralp=round((pslice-1)/2.0)
For t=0,n_elements(tline)-1 do begin 
  for dc=0,3 do begin		
;--------------------------------------------------
; Read in beam stopping coefficients of central beam
;--------------------------------------------------
    i=centralp
    j=centralp
    comp1=refdens & comp2=comp1  & comp3=comp1 & comp4=comp1
    nebula_beamfire,beamstopping='beamstopping',correctionmodel='correctionmodel',$
                    filesbms=filesbms,dens_arr=dens_arr,refdens=refdens,t_e=t_e,n_e=n_e,$
                    correctiondata=correctiondata,diff=diff,intdens=intdens,$
                    rarr,zarr,tline,rpsi,zpsi,noplasma,bener,darr,$
                    bmass,i,j,t,temp,dens,frac_ions,dc,bvdrift
    refdens=refdens     
;--------------------------------------------------
; Read in beam stopping coefficients of left beam
;--------------------------------------------------

    i=0
    j=centralp
    nebula_beamfire,beamstopping='beamstopping',$
                    filesbms=filesbms,dens_arr=dens_arr,refdens=refdens,$
                    rarr,zarr,tline,rpsi,zpsi,noplasma,bener,darr,$
                    bmass,i,j,t,temp,dens,frac_ions,dc,bvdrift
    comp1=refdens 

;--------------------------------------------------
; Read in beam stopping coefficients of right beam
;--------------------------------------------------
    i=pslice-1
    j=centralp
    nebula_beamfire,beamstopping='beamstopping',$
                    filesbms=filesbms,dens_arr=dens_arr,refdens=refdens,$
                    rarr,zarr,tline,rpsi,zpsi,noplasma,bener,darr,$
                    bmass,i,j,t,temp,dens,frac_ions,dc,bvdrift
    comp2=refdens 
;--------------------------------------------------
; Read in beam stopping coefficients of upper beam
;--------------------------------------------------
    i=centralp
    j=pslice-1
    nebula_beamfire,beamstopping='beamstopping',$
                    filesbms=filesbms,dens_arr=dens_arr,refdens=refdens,$
                    rarr,zarr,tline,rpsi,zpsi,noplasma,bener,darr,$
                    bmass,i,j,t,temp,dens,frac_ions,dc,bvdrift
    comp3=refdens 
;--------------------------------------------------
; Read in beam stopping coefficients of lower beam
;--------------------------------------------------
    i=centralp
    j=0
    nebula_beamfire,beamstopping='beamstopping',$
                    filesbms=filesbms,dens_arr=dens_arr,refdens=refdens,$
                    rarr,zarr,tline,rpsi,zpsi,noplasma,bener,darr,$
                    bmass,i,j,t,temp,dens,frac_ions,dc,bvdrift
    comp4=refdens 
;--------------------------------------------------
; Read in BES data
;--------------------------------------------------
    
    i=centralp
    j=centralp
    nebula_beamfire,beamemission='beamemission',filesbes=filesbes,besdata=besdata,$
                    rarr,zarr,tline,rpsi,zpsi,noplasma,bener,darr,$
                    bmass,i,j,t,temp,dens,frac_ions,dc,bvdrift
;--------------------------------------------------
; Read in fraction of population in n=2 for central
; beamlet
;--------------------------------------------------
    i=centralp
    j=centralp

    nebula_beamfire,n2population='n2population',filesn2=filesn2 ,n2data=n2data,$
                    rarr,zarr,tline,rpsi,zpsi,noplasma,bener,darr,$
                    bmass,i,j,t,temp,dens,frac_ions,dc,bvdrift
    refpop=n2data			       
;--------------------------------------------------
; Build up density profile
;--------------------------------------------------  
    x1=fltarr(n_elements(rarr[*,0,0])) & x2=x1 & x3=x1 & x4=x1 & x5=x1 
    for i1=0,pslice-1 do begin
     for j1=0,pslice-1 do begin
      p1=[0,centralp]        ; left beam
      p2=[centralp,centralp] ; Central Beam
      p3=[pslice-1,centralp] ; Right beam
      p4=[centralp,pslice-1] ; Upper beam
      p5=[centralp,0]        ; Lower beam
      x1[*]=reform(refdens/comp1)
      x2[*]=1.0
      x3[*]=reform(refdens/comp2)
      x4[*]=reform(refdens/comp3)
      x5[*]=reform(refdens/comp4)
      d1=nebula_modulus([abs(i1-p1[0]),abs(j1-p1[1])])      
      d2=nebula_modulus([abs(i1-p2[0]),abs(j1-p2[1])])
      d3=nebula_modulus([abs(i1-p3[0]),abs(j1-p3[1])])
      d4=nebula_modulus([abs(i1-p4[0]),abs(j1-p4[1])])
      d5=nebula_modulus([abs(i1-p5[0]),abs(j1-p5[1])])
      if(d1 ne 0)then w1=1.0/d1 else w1=1.
      if(d2 ne 0)then w2=1.0/d2 else w2=1.
      if(d3 ne 0)then w3=1.0/d3 else w3=1.
      if(d4 ne 0)then w4=1.0/d4 else w4=1.
      if(d5 ne 0)then w5=1.0/d5 else w5=1.   
      if(i1 eq (pslice-1)/2. and j1 eq (pslice-1)/2.)then weight[*,i1,j1,t,dc]=1.0 else $
                 weight[*,i1,j1,t,dc]=(x1*w1+x2*w2+x3*w3+x4*w4+x5*w5)/(w1+w2+w3+w4+w5)      
;--------------------------------------------------
; Calculate final density array
;--------------------------------------------------
      if(noplasma)then dens_arr(*,i1,j1,t,dc)=ispace(*,i1,j1)*refdens(*)  else $
      dens_arr(*,i1,j1,t,dc)=ispace(*,i1,j1)*refdens(*)*correctiondata(*)/weight[*,i1,j1,t,dc]
;stop
      bemis_arr(*,i1,j1,t,dc)=besdata(*)*dens_arr(*,i1,j1,t,dc)/(4.*!pi)
      n2pop[*,i1,j1,t,dc]=refpop(*)      
     endfor
    endfor     
  endfor 
endfor 	
end
