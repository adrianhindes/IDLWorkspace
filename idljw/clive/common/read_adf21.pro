; SCCS info: Module @(#)read_adf21.pro	1.1 Date 10/04/00 
;----------------------------------------------------------------------
;+
; PROJECT    :  ADAS
;
; NAME       :  read_adf21
;
; PURPOSE    :  Reads adf21 and adf22 (BMS & BME) files from the IDL 
;               command line.
;               called from IDL using the syntax
;               read_adf21,file=...,energy=...,te=... etc
;
; ARGUMENTS  :  All output arguments will be defined appropriately.
;
;               NAME      I/O    TYPE   DETAILS
; REQUIRED   :  files      I     str()  full name of ADAS adf21 files
;               fraction   I     real() beam fractions; same no. as files
;               te         I     real() temperatures requested
;               dens       I     real() electron densities requested
;               energy     I     real() beam energies requested
; OPTIONAL      data       O      -     BMS/BME data
;
; NOTES      :  This is part of a chain of programs - read_adf21.c and 
;               readadf21.for are required.
;
; AUTHOR     :  Martin O'Mullane
; 
; DATE       :  31-05-2000
; 
; UPDATE     :  
;-
;----------------------------------------------------------------------

PRO read_adf21, files=files, energy=energy, te=te,  dens=dens,   $
                fraction=fraction,  data=data


; Check that we get all inputs and that they are correct. Otherwise print
; a message and return to command line

on_error, 2



; Valid file names and fractions

if n_elements(files) eq 0 then message, 'At least one file name must be passed'

num_files = n_elements(files)       
for j = 0, num_files-1 do begin
   file_acc, files[j], exist, read, write, execute, filetype
   if exist ne 1 then message, 'BMS/BME file does not exist '+files[j]
   if read ne 1 then message, 'BMS/BME  file cannot be read from this userid '+files[j]
endfor
     
if n_elements(fraction) eq 0 then message, 'User requested fractions are missing'

partype=size(fraction, /type)
if (partype lt 2) or (partype gt 5) then begin 
   message,'Beam fractions must be numeric'
endif  else fraction = DOUBLE(fraction)
          
          
                
; Check temperature, density and energies

if n_elements(te) eq 0 then message, 'User requested temperatures are missing'

partype=size(te, /type)
if (partype lt 2) or (partype gt 5) then begin 
   message,'Temperature must be numeric'
endif  else te = DOUBLE(te)

if n_elements(dens) eq 0 then message, 'User requested electron densities are missing'

partype=size(dens, /type)
if (partype lt 2) or (partype gt 5) then begin 
   message,'Electron densities must be numeric'
endif  else dens = DOUBLE(dens)

if n_elements(energy) eq 0 then message, 'User requested beam energies are missing'

partype=size(energy, /type)
if (partype lt 2) or (partype gt 5) then begin 
   message,'Beam energies must be numeric'
endif  else energy = DOUBLE(energy)





; Set variables for call to C/fortran reading of data
; Are te, dens and energy the same length and one dimensional?
; if so define data array

len_te   = n_elements(te)
len_dens = n_elements(dens)
len_eng  = n_elements(energy)

if (len_dens ne len_te) or (len_te ne len_eng) then $
   print, 'TE/DENS/ENERGY size mismatch - smallest  used'
    
itval = min([len_te,len_dens,len_eng])
   

itval  = LONG(itval)
data   = DBLARR(itval)

te     = te[0:itval-1]
dens   = dens[0:itval-1]
energy = energy[0:itval-1]



;   fortdir = '/users/prl/cam112/acmp/read_adf21'
if getenv('HOSTNAME') eq 'scucomp1.anu.edu.au' or $
 getenv('HOSTNAME') eq 'scucomp2.anu.edu.au' $
  then h='' else h='h'

fortdir = getenv('HOME')+'/acmp'+h+'/read_adf21' ;/knebula';getenv('ADASFORT')
;fortdir = getenv('ADASFORT')

dummy = 0
dummy = CALL_EXTERNAL(fortdir+'/read_adf21.so','read_adf21',$
                      num_files, files, fraction, itval, te, dens, energy, data)
                      

                      
END
