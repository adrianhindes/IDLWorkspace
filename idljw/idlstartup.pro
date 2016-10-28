device,decomp=0,retain=2
print,'main startup
.r ~/idl/clive/common/pathadd

pathadd,'~/idl/clive'
pathadd,'+~/idl/ijwkim'
pathadd,'+~/IDLWorkspace82/Default'
pathadd,'+~/idl/ycghim'
pathadd,'+~/idl/haitao_IDL'

;pathadd,'~/idl/common',/no
;pathadd,'~/idl',/no
;pathadd,'~/idl/demod',/no
;pathadd,'/usr/local/depot/idlcodes-hmeyer/READ_FLUX'
;pathadd,'~/prj/repos_mse/codes'
defsysv,'!starttime',systime(1)
print,'!starttime=',!starttime
tek_color
