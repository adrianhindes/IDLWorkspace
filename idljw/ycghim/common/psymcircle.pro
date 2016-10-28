;-------------------------------------------------------------------------
; Routine: PSYMCICLE
; Date: 12.11.03
;-------------------------------------------------------------------------
; PSYMCIRCLE
;
; Set the user defined symbol to a circle.
;
; Calling sequence:
;
; psymcircle {,/fill}, size=size
;
;    size: Optional parameter - symbol size
;    /fill: Optional parameter - filled circle
;-------------------------------------------------------------------------

PRO psymcircle, fill=fill, ssize=ssize

  if (N_ELEMENTS(ssize) eq 0) then ssize=1.0

  p = FINDGEN(17)*!PI*2.0/16
  USERSYM, ssize*cos(p), ssize*sin(p), fill=fill, color=color

END
