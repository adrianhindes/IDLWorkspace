;If you want to change initial configuration of IDL, edit this file.

;ADD path
!path = !path + ':' + expand_path('+/home/ycghim/IDL')

;!path = !path + ':' + $
;        '/home/ycghim/IDL/common:' + $
;        expand_path('+/home/ycghim/IDL/yc_routines'); + $
        ;'/home/ycghim/IDL/yc_routines/read_mdsplus'

;Maintain a backing store
DEVICE, RETAIN=2

;Set the window size
PREF_SET, 'IDL_GR_X_QSCREEN', 'False', /COMMIT
PREF_SET, 'IDL_GR_X_WIDTH', 600, /COMMIT
PREF_SET, 'IDL_GR_X_HEIGHT', 600, /COMMIT

;Set the charsize
!p.charsize=1.5


PRINT, 'IDL is starting...(message from ~/IDL/yc_routines/mystartup.pro)'
PRINT, ' '
