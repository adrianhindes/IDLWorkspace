FUNCTION despike, data, gl_width=gl_width, bin_width=bin_width, $
                  gap_thres=gap_thres
;====================================================
; Procedure DESPIKE
; Despikes data vector. Rejected data points are set to
;   GARBAGE. Then gliding window is moved by one data point and procedure is 
; repeated until the full data vector is processed. The despiked datavector is
; returned.   
;
; data = input data (vector)
; glwidth = width of gliding window (default = 11)
;
; Author: Christoph Senff
; Last modified: 11/11/98
;====================================================
; Check arguments
;====================================================
  if n_elements(data) eq 0 then begin
    print, 'Provide input data'
    progexit
  endif
  if n_elements(gl_width) eq 0 then gl_width = 11
  if n_elements(bin_width) eq 0 then bin_width = 0.1
  if n_elements(gap_thres) eq 0 then gap_thres = 5.
;==========================================================================
; Set constants
;==========================================================================
  GARBAGE = -999.d
;==========================================================================
; Despike
;==========================================================================
  dt = data
  n_dt = n_elements(dt)
  for i=0, n_dt-gl_width do begin
    dt_sub = dt(i:(i+gl_width-1))
    dt(i:(i+gl_width-1)) = histo_despike(dt_sub, bin_width, gap_thres)
  endfor      
;==========================================================================
  return, dt
  END