; Name: pg_get_aug_mirnov
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2007.12.29.
;
; Purpose: Read in AUG Mirnov data
;
; Calling sequence:
;	signal=pg_get_aug_mirnov(shot,channel,nodata=nodata)
;
; Input:
;	shot: shot number
;	channel: channel name
;	nodata (optional): return no data
;
; Output:
;	signal: structure:
;		.t: time vector
;		.s: signal vector

function pg_get_aug_mirnov,shot,channel,nodata=nodata

if keyword_set(no_data) then begin
      signal=0.
endif else begin
	chnum=fix(strmid(channel,4))
	if where(shot EQ [19807,19821,20975,21292,22188,22265,22268,22310,22375,22377,22382,23418,23913,25740,25845]) GT -1 then begin
	if (strcmp(strmid(channel,0,3),'B31') AND (where(chnum EQ [1,2,3,5,6,7,8,9,10,11,12,13,14,30]) GT -1)) OR $
		(strcmp(strmid(channel,0,3),'C04') AND (where(chnum EQ [1]) GT -1)) OR $
		(strcmp(strmid(channel,0,3),'C09') AND (where(chnum EQ [1]) GT -1))$
		then diag='MHA'
	if (strcmp(strmid(channel,0,3),'C09') AND (where(chnum EQ [1,2,3,4,5,6,7,8,9,10,11,12,14,26]) GT -1)) OR $
		(strcmp(strmid(channel,0,3),'C07') AND (where(chnum EQ [16]) GT -1))$
		then diag='MHB'
	if (strcmp(strmid(channel,0,3),'C05') AND (where(chnum EQ [1,20]) GT -1)) OR $
		(strcmp(strmid(channel,0,3),'C10') AND (where(chnum EQ [1,20]) GT -1)) OR $
		(strcmp(strmid(channel,0,3),'C04') AND (where(chnum EQ [1,16]) GT -1)) OR $
		(strcmp(strmid(channel,0,3),'C09') AND (where(chnum EQ [31,32]) GT -1))$
		then diag='MHD'
	if (strcmp(strmid(channel,0,3),'C09') AND (where(chnum EQ [15,16,17,18,20,21,22,23,24,25,27,28,29,30]) GT -1)) OR $
		(strcmp(strmid(channel,0,3),'C07') AND (where(chnum EQ [1]) GT -1))$
		then diag='MHE'
	endif
	if where(shot EQ [19090,20040]) GT -1 then begin
	if (strcmp(strmid(channel,0,3),'B31') AND (where(chnum EQ [1,2,3,5,6,7,8,9,10,11,12,13,14]) GT -1)) OR $
		(strcmp(strmid(channel,0,3),'C04') AND (where(chnum EQ [1]) GT -1)) OR $
		(strcmp(strmid(channel,0,3),'C09') AND (where(chnum EQ [1]) GT -1))$
		then diag='MHA'
	if (strcmp(strmid(channel,0,3),'C09') AND (where(chnum EQ [1,2,3,4,5,6,7,8,9,10,11,12,14,26]) GT -1)) OR $
		(strcmp(strmid(channel,0,3),'C07') AND (where(chnum EQ [16]) GT -1))$
		then diag='MHB'
	if (strcmp(strmid(channel,0,3),'C05') AND (where(chnum EQ [1,20]) GT -1)) OR $
		(strcmp(strmid(channel,0,3),'C10') AND (where(chnum EQ [1,20]) GT -1)) OR $
		(strcmp(strmid(channel,0,3),'C04') AND (where(chnum EQ [1,16]) GT -1)) OR $
		(strcmp(strmid(channel,0,3),'C09') AND (where(chnum EQ [31,32]) GT -1))$
		then diag='MHD'
	if (strcmp(strmid(channel,0,3),'C09') AND (where(chnum EQ [15,16,17,18,20,21,22,23,24,25,27,28,29,30]) GT -1)) OR $
		(strcmp(strmid(channel,0,3),'C07') AND (where(chnum EQ [1]) GT -1))$
		then diag='MHE'
	endif
  if where(shot EQ [18931]) GT -1 then begin
  if (strcmp(strmid(channel,0,3),'B31') AND (where(chnum EQ [1,2,3,5,6,7,8,9,10,11,12,13,14]) GT -1)) OR $
    (strcmp(strmid(channel,0,3),'C04') AND (where(chnum EQ [1]) GT -1)) OR $
    (strcmp(strmid(channel,0,3),'C09') AND (where(chnum EQ [1]) GT -1))$
    then diag='MIR'
  if (strcmp(strmid(channel,0,3),'C09') AND (where(chnum EQ $
      [1,2,3,4,5,6,7,8,9,10,11,12,14,15,16,17,18,20,21,22,23,24,25,26,27,28,29,30,31,32]) GT -1)) OR $
    (strcmp(strmid(channel,0,3),'C04') AND (where(chnum EQ [1,16]) GT -1)) OR $
    (strcmp(strmid(channel,0,3),'C05') AND (where(chnum EQ [1,20]) GT -1)) OR $
    (strcmp(strmid(channel,0,3),'C10') AND (where(chnum EQ [1,20]) GT -1)) OR $
    (strcmp(strmid(channel,0,3),'C07') AND (where(chnum EQ [1,16]) GT -1))$
    then diag='MTR'
  endif
	if strcmp(diag,'') then begin
		print,'Diagnostic not defined for channel '+channel+' in shot '+i2str(shot)
		return,{t:[0,0],s:[0,0]}
	endif
	get_rawdata,shot=shot,d,t,data_number=70000000l,diag=diag,$
        name=channel,leng=leng3co4,date=date3co4,physdim=physdim3co4
	signal={t:t,s:d}
endelse

if max(d) EQ 0 then signal={t:[min(t),max(t)],s:[0,0]}

return,signal

end
