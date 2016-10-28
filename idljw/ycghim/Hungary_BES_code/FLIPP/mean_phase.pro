function mean_phase,phase_in,weights,errormess=errormess
;**************************************************************************
;* MEAN_PHASE.PRO                      S. Zoletnik                        *
;*                                                                        *
;* This program calculates a weighted average of phases.                  *
;* First it normalizes the deviation of the phases from the first element *
;* between -Pi and +Pi and calculates the mean afterwards.                *
;*                                                                        *
;* INPUT:                                                                 *
;*  phase_in: A 1D array of phase values                                  *
;*  weights: An array of weights (default: all 1)                         *
;*                                                                        *
;* OUTPUT:                                                                *
;*  errormess: error message or ''                                        *
;*                                                                        *
;* Return value:                                                          *
;*  The average phase                                                     *
;**************************************************************************

phase = phase_in
n_phase = n_elements(phase)
default,weights,fltarr(n_phase)+1

if (n_elements(weights) ne n_elements(phase_in)) then begin
  errormess = 'Number of weights is different form number of phase values.'
  print,errormess
  return,0
endif

ref_phase = phase[0]
while (1) do begin
  ind = where((phase - ref_phase) gt !pi)
  if (ind[0] lt 0) then begin
    break
  endif else begin
    phase[ind] = phase[ind]-2*!pi
  endelse
endwhile
while (1) do begin
  ind = where((phase - ref_phase) le -!pi)
  if (ind[0] lt 0) then begin
    break
  endif else begin
    phase[ind] = phase[ind]+2*!pi
  endelse
endwhile
mp = total(phase*weights)/total(weights)
while (mp gt !pi) do mp = mp-2*!pi
while (mp le -!pi) do mp = mp+2*!pi
return,mp
end