function wftsamp,shot

; Returns the default sample frequency for shots with external clock.

;if ((shot ge 10100) and (shot le 10199)) then return,5e5 
;if ((shot ge 43352) and (shot le 43393)) then return,5e5
;if ((shot ge 43460) and (shot le 43569)) then return,5e5
;if ((shot ge 43519) and (shot le 43545)) then return,5e5
;if ((shot ge 43610) and (shot le 43613)) then return,2.5e5
;if ((shot ge 43614) and (shot le 50000)) then return,5e5

r=meas_config(shot,ext_fsample=ext_fsample)
if (keyword_set(ext_fsample)) then return,ext_fsample else return,0
end
