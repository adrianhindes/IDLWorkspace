function defchannels,shot,data_source=data_source
;************************************************************
; Returns a list of the channels measured in the given shot
; and system.
;************************************************************

default,data_source,fix(local_default('data_source'))

if (data_source eq 23) then begin   ;  MAST APD
  chlist = indgen(8)+1
  return,chlist
endif

if (data_source eq 25) then begin   ;  TEXTOR APD)
  chlist = strarr(14)
  for i=2,15 do begin
    chlist[i-2] = 'BES-'+i2str(i)
  endfor
  return,chlist
endif

r=meas_config(shot,data_source=data_source,channel_list=ch,signal_list=sig,/silent)
if (r ne 0) then return,0
if ((data_source ne 8) and (data_source ne 10) and (data_source ne 23)) then begin
       for i=1,35 do begin
         ind=where(sig eq 'Li-'+i2str(i))
         if (ind(0) ge 0) then begin
           if (not defined(chlist)) then chlist=[i] else chlist=[chlist,i]
         endif
       endfor
endif

if ((data_source eq 8) or (data_source eq 10)) then begin   ;  Blow-off
       for i=1,10 do begin
         ind=where(sig eq 'Blo-'+i2str(i))
         if (ind(0) ge 0) then begin
           if (not defined(chlist)) then chlist=[i] else chlist=[chlist,i]
         endif
       endfor
endif

if (data_source eq 23) then begin   ;  MAST APD
  chlist = [1,2,3,4,5,6,7,8]
endif

if (defined(chlist)) then return,chlist else return,ch

end



;if (data_source eq 0) then begin
;  if (shot ge 90000) then begin  ; simulations
;    return,findgen(28)+1
;  endif
;  if ((shot le 32000) and (shot gt 31000)) then begin
;    channels=findgen(24)+1
;  endif
;  if ((shot ge  39330) and (shot le 39372) or (shot ge 40354) and (shot le 41599)$
;      or (shot gt 40738)) then begin
;    channels=findgen(16)+4
;  endif
;  if ((shot ge 39928) and (shot le 39929)) then begin
;    channels=[5,7,9,11,13,15,17,19]
;  endif
;  if ((shot gt  39372) and (shot lt 39927) or (shot lt 20000) $
;      or (shot ge 39934) and (shot le 40353)) then begin
;    channels=findgen(16)+2
;  endif
;  if ((shot ge 42827) and (shot le 43126)) then begin
;    channels=findgen(28)+1
;  endif
;  if ((shot gt 43126) and (shot lt 43352)) then begin
;    channels=[4,6,8,9,10,11,12,13,14,15,16,17,18,19,20,21]
;  endif
;  if ((shot ge 43352) and (shot le 43393)) then begin
;    channels=[2,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,24,25]
;  endif
;  if ((shot ge 43399) and (shot le 43418)) then begin
;    channels=[4,6,8,9,10,11,12,13,14,15,16,17,18,19,20,21]
;  endif
;  if ((shot ge 43419) and (shot le 43459)) then begin
;    channels=[4,6,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22]
;  endif
;  if ((shot ge 43460) and (shot le 43492)) then begin
;    channels=[3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,24,25,26,27]
;  endif
;  if ((shot ge 43519) and (shot le 43545)) then begin
;    channels=[4,6,8,9,10,11,12,13,14,15,16,17,18,19,20,21]
;  endif
;  if ((shot ge 43546) and (shot le 43626)) then begin
;    channels=[4,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,24,25]
;  endif
;  if ((shot ge 43572) and (shot le 43591)) then begin
;    channels=[4,6,9,10,11,12,13,14,15,16,17]
;  endif
;  if ((shot ge 43592) and (shot le 50000)) then begin
;    channels=[4,6,8,9,10,11,12,13,14,15,16]
;  endif
;  default,channels,findgen(28)+1
;  return,channels
;endif
;if (data_source eq 2) then begin
;  if ((shot gt 39200) and (shot lt 39300)) then return,findgen(25)+2
;  return,findgen(28)+1
;endif
;end
;
;
;
;
;
;
;
;
