pro nebula_kbparam, shot	          , beam	         , ntime       , tline=tline,$
                   bener=bener    , bvdrift=bvdrift      , bdens=bdens , bmass=bmass,$
	           element=element, frac_ions=frac_ions  , bcurr=bcurr,frac_hydrogen=frac_hydrogen
forward_function getdata
;----------------------------------------------------------------------------------
; Purpose : Set up beam voltage and time line used in NEBULA
; Author  : Stuart Henderson
; Date    : May 2011
; Contact : stuart.henderson@ccfe.ac.uk
;----------------------------------------------------------------------------------   
;------------------------------------------------------
; Get voltage, power and mass of both beams
;------------------------------------------------------
if(beam eq 'sw')then begin
 volt   = getdata('xnb_sw_beam_voltage',shot) ;& volt.data*=0.5
; volt   = getdata('/xnb/sw/g1v',shot) ;& volt.data*=0.5
 fpower = getdata('anb_sw_full_power',shot) ;& fpower.data*=0.5
 hpower = getdata('anb_sw_half_power',shot) ;& hpower.data*=0.5
 tpower = getdata('anb_sw_third_power',shot) ;& tpower.data*=0.5
 mass   = getdata('anb_sw_source_gas_deuter',shot)
; volt   = getdata('xnb_ss_beam_voltage',shot)
; fpower = getdata('anb_ss_full_power',shot)
; hpower = getdata('anb_ss_half_power',shot) 
; tpower = getdata('anb_ss_third_power',shot)
; mass   = getdata('anb_ss_source_gas_deuter',shot)

endif
if(beam eq 'ss')then begin
 volt   = getdata('xnb_ss_beam_voltage',shot)
; volt   = getdata('/xnb/ss/g1v',shot)
 fpower = getdata('anb_ss_full_power',shot)
 hpower = getdata('anb_ss_half_power',shot) 
 tpower = getdata('anb_ss_third_power',shot)
 mass   = getdata('anb_ss_source_gas_deuter',shot)
endif
if(beam eq 'k1') or (beam eq 'k2')then begin
    tt=linspace(-1,10,1000) & f=replicate(1.,1000)
    volt={time:tt,data:80.*f}
    fpower={time:tt,data:2.*f}
    hpower={time:tt,data:0.3*f}
    tpower={time:tt,data:0.1*f}
    mass={erc:0} ; make mass 2
endif

;------------------------------------------------------
; Find when beams are active
;------------------------------------------------------
beamon1=where(volt.data[*] gt 20)
if(beamon1[0] eq -1)then stop,'*** Beam not active ***'
timetmp=volt.time[beamon1]
;------------------------------------------------------
; Check for beam misfire
;------------------------------------------------------
avr=mean(timetmp)
idx=long(interpol(lindgen(n_elements(volt.time)),volt.time,avr))
avrvolt=mean(volt.data[idx+indgen(50)])
iopt=0
;while(iopt eq 0)do begin
; if(volt.data(idx) lt 0.5*avrvolt)then begin
;  iopt=1
; endif else begin   
;  idx=idx-1 
; endelse 
;end
beamon1=replicate(1,n_elements(volt.time))

;where(volt.time gt volt.time(idx) and volt.time lt volt.time(max(beamon1)))
time=volt.time[beamon1]	    
btime=[time(0),max(time)]  
errbeam=mass.erc
if errbeam eq 0 then amu=2. else amu=1.
;------------------------------------------------------
; Create time line
;------------------------------------------------------
tdiv=(btime[1]-btime[0])/(ntime-1)
tline_input=btime[0]+findgen(ntime)*tdiv
nebula_default,frac_hydrogen,0.01

nebula_default,tline,tline_input
ntime=n_elements(tline)
;------------------------------------------------------
; Look at impurities in plasma
;------------------------------------------------------
nebula_default,element,'c' 	; Impurity element expected in the plasma
fraction=fltarr(n_elements(element)+1,ntime)
for i=0,ntime-1 do begin
 hydrogen_frac=1
 for j=0,n_elements(element)-1 do begin
  impurityfrac=0.05
  fraction[j+1,i]=impurityfrac 
  hydrogen_frac=hydrogen_frac-impurityfrac  
 endfor
 fraction[0,i]=hydrogen_frac
endfor
nebula_default,frac_ions,fraction  ; Amount of impurity species in plasma
;------------------------------------------------------
; Power and voltage conditioning
;------------------------------------------------------
;rescurrent=fltarr(n_elements(tline),3) & resenergy=fltarr(n_elements(tline),3)
rescurrent=fltarr(n_elements(tline),4) & resenergy=fltarr(n_elements(tline),4)
vdrift=resenergy & j0=vdrift & dens=j0
smoothenergyf=smooth(volt.data,50,/edge_wrap)*1000.0
smoothenergyh=smooth(volt.data,50,/edge_wrap)*1000.0/2.0
smoothenergyt=smooth(volt.data,50,/edge_wrap)*1000.0/3.0
smoothpowerf=smooth(fpower.data,200,/edge_wrap)*1.0e6
smoothpowerh=smooth(hpower.data,200,/edge_wrap)*1.0e6
smoothpowert=smooth(tpower.data,200,/edge_wrap)*1.0e6
currentf=smoothpowerf/smoothenergyf
currenth=smoothpowerh/smoothenergyh
currentt=smoothpowert/smoothenergyt
rescurrent[*,0]=interpol(currentf,volt.time,tline)
rescurrent[*,1]=interpol(currenth,volt.time,tline)
rescurrent[*,2]=interpol(currentt,volt.time,tline)

rescurrent[*,3]=rescurrent[*,0] * frac_hydrogen
resenergy[*,0]=interpol(smoothenergyf,volt.time,tline)
resenergy[*,1]=interpol(smoothenergyh,volt.time,tline)
resenergy[*,2]=interpol(smoothenergyt,volt.time,tline)
resenergy[*,3]=resenergy[*,0] * 2. ; twice energy/amu for hydrogen
nebula_default,bener,resenergy
nebula_default,bcurr,rescurrent
vdrift[*,0]=sqrt(2.*bener[*,0]*1.602e-19/1.673e-27/amu)
vdrift[*,1]=sqrt(2.*bener[*,1]*1.602e-19/1.673e-27/amu)
vdrift[*,2]=sqrt(2.*bener[*,2]*1.602e-19/1.673e-27/amu)
vdrift[*,3]=sqrt(2.*bener[*,3]*1.602e-19/1.673e-27/amu)
j0[*,0]=bcurr[*,0]  ; Full current density
j0[*,1]=bcurr[*,1]  ; Half current density
j0[*,2]=bcurr[*,2]  ; Third current density
j0[*,3]=bcurr[*,3]  ; Third current density

dens[*,0]=j0[*,0]/vdrift[*,0]/1.6e-19 ; Full initial unnormalised beam density m-1
dens[*,1]=j0[*,1]/vdrift[*,1]/1.6e-19 ; Half initial unnormalised beam density m-1
dens[*,2]=j0[*,2]/vdrift[*,2]/1.6e-19 ; Third initial unnormalised beam density m-1
dens[*,3]=j0[*,3]/vdrift[*,3]/1.6e-19 ; Third initial unnormalised beam density m-1

nebula_default,bvdrift,vdrift
nebula_default,bdens,dens
nebula_default,bmass,amu
;stop


End
