; SCCS info: Module @(#)read_adf12.pro	1.2 Date 03/18/03
;----------------------------------------------------------------------
;+
; PROJECT    :  ADAS
;
; NAME       :  read_adf12
;
; PURPOSE    :  Reads adf12 (QEF) files from the IDL command line.
;               called from IDL using the syntax
;               read_adf12,file=...,block=...,ein=... etc
;
; ARGUMENTS  :  All output arguments will be defined appropriately.
;
;               NAME      I/O    TYPE   DETAILS
; REQUIRED   :  file       I     str    full name of ADAS adf12 file
;               block      I     int    selected block
;               ein        I     real() energies requested
;               tion       I     real() ion temperatures requested (eV)
;               dion       I     real() ion densities requested (cm-3)
;               zeff       I     real() Z-effective requested
;               bmag       I     real() B field requested (T)
;
; OPTIONAL      data       O      -     QEF data
;
; KEYWORDS   :  energy           EIN units are eV/amu
;               atomic           EIN units are atomic units
;               velocity         EIN units are cm s-1
;
;
; NOTES      :  This is part of a chain of programs - read_adf12.c and 
;               readadf12.for are required. Scans over energy, ion 
;               temperature, ion desnity, Zeff or B are possible. However
;               only one parameter at a time can be varied. ie if tion
;               and zeff are arrays then the routine will not run.
;
; AUTHOR     :  Martin O'Mullane
; 
; DATE       :  21-07-2000
; 
; MODIFIED   :
;
;         1.1   Martin O'Mullane
;                - First version.
;         1.2   Martin O'Mullane
;                - No limit on number of energies returned. It crashed
;                  if more than 24 were requesed.
;
; VERSION    :
;
;         1.1    21-07-2000
;         1.2    07-02-2003
;-
;----------------------------------------------------------------------

PRO read_adf12, file=file, block=block, ein=ein,                 $
                dion=dion, tion=tion, zeff=zeff, bmag=bmag,      $ 
                energy=energy, atomic=atomic, velocity=velocity, $ 
                data=data


; Check that we get all inputs and that they are correct. Otherwise print
; a message and return to command line

on_error, 2



; file name

if n_elements(file) eq 0 then message, 'A file name must be passed'
file_acc, file, exist, read, write, execute, filetype
if exist ne 1 then message, 'QEF file does not exist '+file
if read ne 1 then message, 'QEF file cannot be read from this userid '+file


; selection block

if n_elements(block) eq 0 then message, 'A QEF block must be selected'
parsize=size(block, /N_DIMENSIONS)
if parsize ne 0 then message,'Selection index cannot be an array'
partype=size(block, /TYPE)
if (partype ne 2) and (partype ne 3) then begin 
   message,'Selection index must be numeric'
endif else ibsel = LONG(block)

; Units of input energy are keywords - default to eV/amu

ietyp = 1L

e1 = keyword_set(energy)
e2 = keyword_set(atomic)
e3 = keyword_set(velocity)
if (e1+e2+e3) gt 1 then message, 'Only one energy unit allowed'

if e1 eq 1 then ietyp = 1L
if e2 eq 1 then ietyp = 2L
if e3 eq 1 then ietyp = 3L

        
                
; Energy, ion temperature, ion density, Zeff and B

if n_elements(ein)  eq 0 then message, 'No user requested energies'
if n_elements(dion) eq 0 then message, 'No user requested ion density'
if n_elements(tion) eq 0 then message, 'No user requested ion temperature'
if n_elements(zeff) eq 0 then message, 'No user requested zeff'
if n_elements(bmag) eq 0 then message, 'No user requested magnetic field'

partype=size(ein, /type)
if (partype lt 2) or (partype gt 5) then begin 
   message,'Energies must be numeric'
endif  else ein = DOUBLE(ein)
partype=size(dion, /type)
if (partype lt 2) or (partype gt 5) then begin 
   message,'Energies must be numeric'
endif  else dion = DOUBLE(dion)
partype=size(tion, /type)
if (partype lt 2) or (partype gt 5) then begin 
   message,'Energies must be numeric'
endif  else tion = DOUBLE(tion)
partype=size(zeff, /type)
if (partype lt 2) or (partype gt 5) then begin 
   message,'Energies must be numeric'
endif  else zeff = DOUBLE(zeff)
partype=size(bmag, /type)
if (partype lt 2) or (partype gt 5) then begin 
   message,'Energies must be numeric'
endif  else bmag = DOUBLE(bmag)

; Now we only allow iteration over one parameter

sz_ein  = size(ein,  /N_DIMENSIONS)
sz_dion = size(dion, /N_DIMENSIONS)
sz_tion = size(tion, /N_DIMENSIONS)
sz_zeff = size(zeff, /N_DIMENSIONS)
sz_bmag = size(bmag, /N_DIMENSIONS)

sz_tot = sz_ein  + sz_dion + sz_tion + sz_zeff + sz_bmag

if (sz_tot GT 1) then message, 'Can only range over one parameter'



; set variables for call to C/fortran reading of data

fortdir = '/users/prl/cam112/acmp/read_adf12';getenv('ADASFORT')

ieval = n_elements(ein)
ieval = LONG(ieval)
data  = DBLARR(ieval)

; if ein is the one ie all others are scalars; note ein could be a scalar also.

sz_tot = sz_dion + sz_tion + sz_zeff + sz_bmag

if (sz_tot EQ 0) then begin

  MAXVAL = 24
  data   = 0.0D0
  n_call = numlines(ieval, MAXVAL)
  
  for j = 0, n_call - 1 do begin 

    ist = j*MAXVAL
    ifn = min([(j+1)*MAXVAL,ieval])-1

    ein_ca   = ein[ist:ifn]
    data_ca  = dblarr(ifn-ist+1)
    ieval_ca = ifn-ist+1

    dummy = CALL_EXTERNAL(fortdir+'/read_adf12.so','read_adf12',    $
                          file, ibsel, ieval_ca, ietyp, ein_ca, data_ca, $
                          tion ,dion , zeff, bmag)

    data = [data, data_ca]

  endfor
  data = data[1:*]
  

endif else begin

   ; which one
   
   if sz_tion EQ 1 then begin
   
      itval = n_elements(tion)
      dtmp = DBLARR(itval)
      for j = 0, itval-1 do begin
         tmp = tion[j]
         dummy = CALL_EXTERNAL(fortdir+'/read_adf12.so','read_adf12',  $
                               file, ibsel,ieval,ietyp,ein,data,tmp,   $
                               dion,zeff,bmag)
         dtmp[j] = data[0]
      endfor
      
      data = dtmp
   
   endif

   if sz_dion EQ 1 then begin
   
      itval = n_elements(dion)
      dtmp = DBLARR(itval)
      for j = 0, itval-1 do begin
         tmp = dion[j]
         dummy = CALL_EXTERNAL(fortdir+'/read_adf12.so','read_adf12',  $
                               file, ibsel,ieval,ietyp,ein,data,tion,  $
                               tmp,zeff,bmag)
         dtmp[j] = data[0]
      endfor
      
      data = dtmp
   
   endif

   if sz_zeff EQ 1 then begin
   
      itval = n_elements(zeff)
      dtmp = DBLARR(itval)
      for j = 0, itval-1 do begin
         tmp = zeff[j]
         dummy = CALL_EXTERNAL(fortdir+'/read_adf12.so','read_adf12',  $
                               file, ibsel,ieval,ietyp,ein,data,tion,  $
                               dion,tmp,bmag)
         dtmp[j] = data[0]
      endfor
      
      data = dtmp
   
   endif

   if sz_bmag EQ 1 then begin
   
      itval = n_elements(bmag)
      dtmp = DBLARR(itval)
      for j = 0, itval-1 do begin
         tmp = bmag[j]
         dummy = CALL_EXTERNAL(fortdir+'/read_adf12.so','read_adf12',  $
                               file, ibsel,ieval,ietyp,ein,data,tion,  $
                               dion,zeff,tmp)
         dtmp[j] = data[0]
      endfor
      
      data = dtmp
   
   endif

endelse                     
 
                      
END
