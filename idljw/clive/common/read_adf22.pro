;----------------------------------------------------------------------
;+
; PROJECT    :  ADAS
;
; NAME       :  read_adf22
;
; PURPOSE    :  Reads adf22 (BME) files from the IDL command line.
;               called from IDL using the syntax
;               read_adf22,file=...,energy=...,te=... etc
;
; ARGUMENTS  :  All output arguments will be defined appropriately.
;
;               NAME      I/O    TYPE   DETAILS
; REQUIRED   :  files      I     str()  full name of ADAS adf22 files
;               fraction   I     real() target ion fractions; same as number of
;                                       adf21 files
;                                         1st Dimension: requested parameters
;                                         2nd Dimension: numfiles
;                                       If only one dimesnion is present
;                                       read_adf21 assumes that the target
;                                       impurity fraction is the same for all
;                                       requested parameters.
;               te         I     real() temperatures requested (eV)
;               dens       I     real() electron densities requested (cm-3)
;               energy     I     real() beam energies requested (eV/amu)
; OPTIONAL      data       O      -     BME/BMP data (ph cm3 s-1 / na)
;               fulldata   O      -     structure containing all the
;                                       data in the adf21 file. If
;                                       requested other options are
;                                       not used. Note only one file
;                                       is permitted for this option.
;
;                                        file   :  filename
;                                        itz    : target ion charge.
;                                        tsym   : target ion element symbol.
;                                        beref  : reference beam energy (eV/amu).
;                                        tdref  : reference target density (cm-3).
;                                        ttref  : reference target temperature (eV).
;                                        svref  : stopping coefft. at reference
;                                                 beam energy, target density and
;                                                 temperature (cm3 s-1).
;                                        be     : beam energies(eV/amu).
;                                        tdens  : target densities(cm-3).
;                                        ttemp  : target temperatures (eV).
;                                        svt    : stopping coefft. at reference beam
;                                                 energy and target density (cm3 s-1)
;                                        sved   : coefft. at reference target
;                                                 temperature (ph cm3 s-1 or dimensionless).
;               help       I     Display help entry.
;
; NOTES      :  The processing is done with read_adf21, this is merely
;               a wrapper. This is part of a chain of programs -
;               read_adf21.c and readadf21.for are required.
;               The BMP variant stores the fractional population of
;               excited beam n-levels and therefore is dimensionless.
;
; AUTHOR     :  Martin O'Mullane
;
; DATE       :  01-03-2001
;
; UPDATE     :
;
;       1.1     Martin O'Mullane
;                 - First version.
;       1.2     Allan Whiteford
;                 - Added /help keyword.
;       1.3     Martin O'Mullane
;                 - Bring into line with latest read_adf21 options.
;       1.4     Martin O'Mullane
;                 - Update comments.
;       1.5     Martin O'Mullane
;                 - Do do pass fulldata to read_adf21 if not in
;                   argument list.
;
; VERSION    :
;       1.1    01-03-2001
;       1.2    07-04-2005
;       1.3    01-05-2009
;       1.4    03-08-2009
;       1.5    16-11-2009
;
;-
;----------------------------------------------------------------------

PRO read_adf22, files    = files,    $
                energy   = energy,   $
                te       = te,       $
                dens     = dens,     $
                fraction = fraction, $
                data     = data,     $
                fulldata = fulldata;, $
;                nocheck  = nocheck;,  $
;                help     = help

if arg_present(fulldata) then begin

   read_adf21, files    = files,    $
               energy   = energy,   $
               te       = te,       $
               dens     = dens,     $
               fraction = fraction, $
               data     = data,     $
               fulldata = fulldata;, $
;               nocheck  = nocheck;,  $
;               help     = help

endif else begin

   read_adf21, files    = files,    $
               energy   = energy,   $
               te       = te,       $
               dens     = dens,     $
               fraction = fraction, $
               data     = data;,     $
;               nocheck  = nocheck;,  $
;               help     = help

endelse

END
