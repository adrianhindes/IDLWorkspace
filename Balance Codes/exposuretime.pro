function exposureTime, shotNo
;Lookup (not really, just a bunch of ifs and thens) table
; for exposure times depending on shot
;"There's gotta be a better way to do this" - Adrian H 4/12/16

if shotNo eq 28 then begin
  shotLength = 10
endif
if shotNo eq 29 then begin
  shotLength = 5
endif
if shotNo ge 30 then begin
  shotLength = 10
endif
if shotNo ge 35 then begin
  shotLength = 5
endif

if shotNo ge 37 then begin
  shotLength = 10
endif
if shotNo eq 40 then begin
  shotLength = 15
endif

if shotNo ge 41 then begin
  shotLength = 50
endif

if shotNo ge 45 then begin
  shotLength = 5
endif

if shotNo ge 48 then begin
  shotLength = 50
endif





;28 - 10ms exposure H Alpha 47mm (8.4 mTorr)
;29 - 5ms, source
;30 - 10ms, z =2 or 3
;31 - 10 ms z =3
;32 - 10ms z=4 (pinch)
;33 - 10ms z = 4 (4.2mTorr)
;34 - 10ms z = 3
;35 - 5ms z = 2
;36 - 5m z = 1
;37 - 10ms z = 1 (2.1mTorr)
;38 - 10ms z = 2
;39 - 10ms z = 3
;40 - 15ms z = 4 (pinch)
;
;41 - 50ms z = 1 (1KW, 4.2mTorr)
;42 - 50ms z = 2
;43 - 50ms z = 3
;44 - 50ms z = 4
;45 - 5ms changed aperture, z = 4
;46 - 5ms z =3
;47 - 5ms z = 2
;48 - 50ms z = 1
;49 - 50ms z = 2
;50 - 50ms z = 3
;51 - 50ms z = 4
;
return, shotLength
end