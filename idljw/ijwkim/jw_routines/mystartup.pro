;If you want to change initial configuration of IDL, edit this file.

;ADD path
!path = !path + ':' + expand_path('+/home/ijwkim/IDL') + expand_path('+/home/ycghim/IDL')
;        '/home/ijwkim/IDL/jw_routines' + $
;        ':/home/ycghim/IDL/common'

;Maintain a backing store
DEVICE, RETAIN=2

;Set the window size
PREF_SET, 'IDL_GR_X_QSCREEN', 'False', /COMMIT
PREF_SET, 'IDL_GR_X_WIDTH', 600, /COMMIT
PREF_SET, 'IDL_GR_X_HEIGHT', 600, /COMMIT

;Set the charsize
!p.charsize=1.5


PRINT, 'IDL is starting...(message from ~/IDL/jw_routines/mystartup.pro)'
PRINT, ' '
