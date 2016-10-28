pro getdbtiming,str
print,'getdbtiming'
period=mdsvaluestr(str,'.PCO_CAMERA.SETTINGS.TRIGGER.SETTINGS:HIGH_TIME',/open,/flat)

period+=mdsvaluestr(str,'.PCO_CAMERA.SETTINGS.TRIGGER.SETTINGS:LOW_TIME',/flat) 
period=period * 1e-3  ; to ms

t0 = mdsvaluestr(str,'.PCO_CAMERA.SETTINGS.TRIGGER:TRIGOFFST_TM',/flat) + mdsvaluestr(str,'.PCO_CAMERA.SETTINGS.TRIGGER.SETTINGS:DELAY',/flat)*1e-3


exposure = mdsvaluestr(str,'.PCO_CAMERA.SETTINGS.TIMING:EXPOSURE',/close,/flat)
str.t0=t0
str.t0proper=t0
str.dt=period

print,'period is ',period
print,'exposure is ',exposure


end
