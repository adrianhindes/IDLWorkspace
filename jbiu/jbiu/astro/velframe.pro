;+
; NAME:
;    VELFRAME
;
; PURPOSE:
;    Converts radial velocities between Local Standard of Rest, Heliocentric and Galactocentric velocity frames.
;
; CATEGORY:
;    Astro
;
; CALLING SEQUENCE:
;    Result = VELFRAME(Coords)
;
; INPUTS:
;    Coords:   2-element vector of coordinates at which transformation is computed. Assumed
;              to be decimal RA and Dec degrees unless /GALACTIC is specified.
;
; KEYWORD PARAMETERS:
;    GALACTIC: Input coordinates are in galactic coordinates rather than RA and Dec.
;
;    VLSR:    Input velocity in LSR frame.
;
;    VHELIO:  Input velocity in heliocentric frame.
;
;    VGSR:    Input velocity in Galactic standard of rest frame.
;
;    FRAME:   Output frame. One of 'LSR', 'HELIO' or 'GSR'.
;
; OUTPUTS:
;    Output radial velocity in desired frame, assuming no proper motion.
;
; EXAMPLE:
;    FIXME
;
; MODIFICATION HISTORY:
;    Written by:   Jeremy Bailin
;    13 Sept 2011  Initial writing
;-
function velframe, coords, galactic=galacticp, vlsr=vlsr, vhelio=vhelio, vgsr=vgsr, frame=outframe

; make sure only one inputted value


nspec=0
if keyword_set(mM) then nspec++
if keyword_set(dist) then nspec++
if nspec gt 1 then message, 'Only one of mM and DIST may be specified.'
if nspec eq 0 then message, 'Please give either mM or DIST.'

if keyword_set(mM) then begin
  return, 10^(0.2*(mM+5))  
endif else begin ; keyword_set(dist) must be true
  return, 5.*alog10(dist)-5.
endelse

end

