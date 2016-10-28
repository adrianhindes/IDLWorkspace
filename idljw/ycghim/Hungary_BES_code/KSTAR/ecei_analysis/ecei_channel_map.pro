function ecei_channel_map,block=block,errormess=errormess
; This function returns the channel names for the ECEi channels in a matrix
; INPUT:
;  block: 'L' or 'H'
; Return value is a matrix of channel names. First index is horizontal.

errormess = ''
if (not defined(block)) then begin
  errormess = 'ECEI_CHANNEL_MAP: Block name not defined. Set J or L.'
  return,0
endif
if ((strupcase(block) ne 'L') and (strupcase(block) ne 'H')) then begin
  errormess = 'ECEI_CHANNEL_MAP: Invalid block name. Set J or L.'
  return,0
endif

map = strarr(8,24)
for i=0,23 do begin
  for j=0,7 do begin
   map[j,i] = 'ECEI/ECEI_'+block+i2str(i+1,digits=2)+i2str(8-j,digits=2)
  endfor
endfor
return,map
end