function aias_units, real_units=real_units
  units = make_array(25, value='[a.u.] - input voltage')

  if keyword_set(real_units) then begin
    units(1) = '[V]'      ; channel 1				|	Uloop	|
    units(2) = '[10!u18!n m!u-3!n]'      ;	   2	|	n_e 	|
    units(3) = '[kA]'      ;  	   3           	|	Ipl 	|

    units(7) = '[A]'    	 ;  	   7           	|	Ivert	|

    units(9) = '[A]'   	 ;  	   9           	|	Ihor	|

    units(18) = '[V]'      ;  	  18           	|	Ubias	|
    units(19) = '[A]'      ;  	  19            |	Ibias	|
    units(23) = '[A]'      ;  	  23           	|	Idyn	|
  endif

  return, units
end

function getdata_cas, shot, dev, chan, $									; obligatory parameters
                  path=path, decompressed=decompressed, rate=rate, $	; optional parameters
                  time=time, active=active, zero=zero, real_units=real_units, unit=unit, $
                  sct_time=sct_time, print_info=print_info, clean=clean ; optional, not public parameter

; ------------------------------------------------------------------
; direct CASTOR DATABASE access - OR - access to localy stored data?
; ------------------------------------------------------------------
remote = 1
if remote eq 1 then begin
  decompressed = 1
  clean = 0
endif
;-------------------------------------------------------------------

; DEVICES:
; ========
if dev eq 'tectra1' then dev='sct'
if dev eq 'tectra2' then dev='tct'
if dev eq 'dewe'    then begin
  dev='tct'
  if chan lt 50 then chan = chan+40
endif
if dev eq 'aias'    then dev='aia'
if dev eq 'tectra3' then dev='dtk'

;------------------------------------------------------
if (dev eq 'sb1') or (dev eq 'sb2') then sig_type = 0
if (dev eq 'sct') or (dev eq 'tct') then sig_type = 1
if (dev eq 'aia') or (dev eq 'dtk') or (dev eq 'bolo') then sig_type = 2
;------------------------------------------------------

; KEYWORDS:
; =========
if not(keyword_set(path)) 			then path = 'C:\temp\'
if remote eq 1 	then path=path+strcompress(string(shot),/remove_all)+'/'

if not(keyword_set(decompressed)) 	then  decompress = 1	else decompress = 0
;if not(keyword_set(rate)) 			then  sampl = 0			else sampl=1

if not(keyword_set(sct_time)) 	then  sct_t = 0		else sct_t = 1
if not(keyword_set(print_info))	then  print_i = 0	else print_i = 1
if not(keyword_set(clean))		then  cl = 0		else cl = 1

;-----------------------------------------------------

; CALL ROUTINES
; =============

case sig_type of

  0: begin
       result = sb_das(shot, dev, path=path, /amplif, clean=cl)
       time = result(0,*)
       result = result(chan, *)
       rate = time(1)-time(0)
       if remote eq 1 then begin
         print, '-----------------------------------------------------------------------------'
         print, 'SORRY, the sb1 and sb2 formats are supported only for direct database access.'
         print, 'Use the "CASTOR indepenent" version of the old sb_das.pro . Thank you.'
         rate = 0.1
       endif

     end
  1: result = sct_das(shot, dev, chan, path=path, decompress=decompress, rate=rate, clean=cl, sct_time=sct_t)
  2: result =   w_das(shot, dev, chan, path=path, decompress=decompress, rate=rate, clean=cl, active=active)

endcase

if (sig_type gt 0) then time = findgen(n_elements(result))*rate
if dev eq 'aia' then time = time-20
if sig_type eq 1 then begin
  time=1000*time
  rate=1000*rate
endif

if (keyword_set(zero)) 	then begin
  if zero gt 1 then imax=zero else imax=fix(1.d/rate)
  pom = moment(result(0:imax))
  result = result - pom(0)
endif

if dev eq 'aia' then begin
  if (keyword_set(real_units)) then begin
    koef = aias_koef()
    result = koef(chan) * result
  endif
  units = aias_units(real_units=real_units)
  unit = units(chan)
endif else unit = '[a.u.] - input voltage'

return, result

end
