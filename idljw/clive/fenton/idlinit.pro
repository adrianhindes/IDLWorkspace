;@idl$local:idlsysstart.pro	;some of Boyd's stuff

; avoid 24bitcolor bdb 10/96
device, pseudo=8

!edit_input=50

;print,'Restoring IDL expanded path...'
;restore, file='grp_prl:[fjg112.idl]idl_path.dat'
;!path=path

jhpath = 'idl$local:,mds$root:[idl]'
print,'Loading DATA_PLOT directory paths ...'
dp_dir =           GETENV('DATA_PLOT$' )
jhpath = jhpath+expand_path('+'+dp_dir)+','
print,'Loading GRP directory paths ...'
grp_dir =           GETENV('grp_prl' )
jhpath = jhpath+expand_path(+grp_dir+'[fjg112.idl]')+','
jhpath = jhpath+expand_path('+'+'grp_prl:[jnh112.idl]')+','
!path = jhpath+!path
path=!path
save, file='idl_path.dat', path

.run data_plot:[mdsidl]set_errors
.run data_plot:[mdsidl]mds
mds
cam$v2

device,retain=2
; set the number of colors
;window, col=!d.n_colors, /px
;wdelete, !d.window
define_key,'pf4','retall',/term
define_key,'pf3','.run '
define_key,'pf2','print,'
;help,/keys
;spawn,'sh def',area  &  area=strtrim(area(0),2)
;sd, area	;setup the prompt
;if strpos(username(),'112') gt 0 then set_db,'firdata$'
;.run grp_prl:[jnh112.idl]idlstart.pro 

