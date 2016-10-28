pro hardon,portrait=portrait,landscape=landscape,color=color,$
  encapsulated=encapsulated,preview=preview,filename=filename_input

;****************************************************************************
;* This program switches graphics output to Postscript. Use hardoff.pro     *
;* or hardfile.pro to close the output file and switch back to the original *
;* graphics device.                                                         *
;*                                                                          *
;*  INPUT:                                                                  *
;*  /portrait: Use portrait layout                                          *
;*  /landscape: Use landscape layout                                        *
;*  /color: Generate color output. This is the default, use color=0 to      *
;*          generate BW.                                                    *
;*  /encapsulated: Generate encapsualated Postscript.                       *
;*  / preview: Generate preview image in file.                              *
;*  filename: Use a temporary filename othe than idl.ps. This is useful     *
;*            when multiple IDL programs are running at the same time.      *
;****************************************************************************

common hardcopy,original_device,filename

if (defined(filename_input)) then filename = filename_input else filename = ''

if (not keyword_set(portrait)) then landscape=1
default,portrait,0
default,landscape,1
default,color,1
default,encapsulated,0
default,preview,0

original_device=!d.name
set_plot,'ps'
if (filename ne '') then filename_device = filename
device,landscape=landscape,portrait=portrait,bits=8,$
  encapsulated=encapsulated,preview=preview,color=color,filename=filename_device
end


