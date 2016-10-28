pro cdf_sample

id = NCDF_CREATE('inquire.nc', /CLOBBER)

; Fill the file with default values:

NCDF_CONTROL, id, /FILL

; We’ll create some time-dependent data, so here is an

; array of hours from 0 to 5:

hours = INDGEN(5)

; Create a 5 by 10 array to hold floating-point data:

data = FLTARR(5,10)

; Generate some values.

FOR i=0,9 DO $

  data(*,i) = (i+0.5) * EXP(-hours/2.) / SIN((i+1)/30.*!PI)
  
xid = NCDF_DIMDEF(id, 'x', 10) ; Make dimensions.

zid = NCDF_DIMDEF(id, 'z', /UNLIMITED)

; Define variables:

hid = NCDF_VARDEF(id, 'Hour', [zid], /SHORT)

vid = NCDF_VARDEF(id, 'Temperature', [xid,zid], /FLOAT)

NCDF_ATTPUT, id, vid, 'units', 'Degrees x 100 F'

NCDF_ATTPUT, id, vid, 'long_name', 'Warp Core Temperature'

NCDF_ATTPUT, id, hid, 'long_name', 'Hours Since Shutdown'

NCDF_ATTPUT, id, /GLOBAL, 'Title', 'Really important data'

; Put file in data mode:

NCDF_CONTROL, id, /ENDEF

; Input data:

NCDF_VARPUT, id, hid, hours

FOR i=0,4 DO NCDF_VARPUT, id, vid, $

  ; Oops! We forgot the 6th hour! This is not a problem, however,
  
  ; as you can dynamically expand a netCDF file if the unlimited
  
  ; dimension is used.
  
  REFORM(data(i,*)), OFFSET=[0,i]
  
; Add the hour and data:

NCDF_VARPUT, id, hid, 6, OFFSET=[5]

; Add the temperature:

NCDF_VARPUT, id, vid, FINDGEN(10)*EXP(-6./2), OFFSET=[0,5]

; Read the data back out:

NCDF_VARGET, id, vid, output_data

NCDF_ATTGET, id, vid, 'long_name', ztitle

NCDF_ATTGET, id, hid, 'long_name', ytitle

NCDF_ATTGET, id, vid, 'units', subtitle

!P.CHARSIZE = 2.5

!X.TITLE = 'Location'

!Y.TITLE = STRING(ytitle) ; Convert from bytes to strings.

!Z.TITLE = STRING(ztitle) + '!C' + STRING(subtitle)

NCDF_CLOSE, id ; Close the NetCDF file.

SHOW3, output_data ; Display the data.

end