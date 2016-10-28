;-----------------------------------------------------------------------------
; Function NICE_NUMBER: (Version 1.21)		R.Martin 20/09/2002
;
; This routine converts a number into a string using the least number of 
; characters to display the result. The sign option will add a '+' sign to
; the front of a positive number.
;
; Format
;   result=STRNUM(numarg {, /sign})
;
;   result  - string array
;   numarg  - integer/real array
;
;   /sign   - add plus sign to front of numbers >=0
;
;
; eg.	0.00000 	becomes 0.0
;       1.00000e10		1.0e10
;	1.25000, /sign         +1.25
;      -1.00000, /sign	       -1.0
;
;-----------------------------------------------------------------------------
;

function nice_number, numarg, sign=signflag

  on_error, 2
  if not_real(numarg) then begin
    error_message, 'NICE_NUMBER: Input parameter must be a number'
  endif

  if not_integer(numarg) then begin
    result=strtrim(numarg, 2)
    for i=0, n_elements(numarg)-1 do begin
      tmpstr=strsplit(result(i), 'e+', /extract)
      posmin=strpos(tmpstr(0), '.')+2
      pos=stregex(tmpstr(0)+'00', '0+$')

      tmpstr(0)=strmid(tmpstr(0), 0, posmin>pos(0) )

      result(i)=strjoin(tmpstr, 'e')
    endfor
  endif else begin
    result=strtrim(numarg, 2)
  endelse

  if keyword_set(signflag) then begin
    result=(['', '+'])(numarg ge 0.0)+result
  endif

  return, result

end

;-----------------------------------------------------------------------------
; Modification history
;
;  Version 1.22
;  - Rewrite algorithm using STREGEX
;
;  Version 1.21
;  - Rewrite algorithm using STRJOIN and STRSPLIT
;  - Use IDL-error handling
;  - rename variables
;  - updata helpful-header
;  - STRNUM(0.0, /sign) now returns '+0.0'
;  - STRNUM(1e20) return, '1.0e20' instead of '1.0e+20'
;  - ???? should it return '1e20'
;  - Bug Fix STRNUM(0.12345) produced '0.123450e'
;
;  Version 1.10
;  - Add sign option
;  - Allow num to be an array
;  - All numbers displayed to at least 1 Sig.Fig.
;
