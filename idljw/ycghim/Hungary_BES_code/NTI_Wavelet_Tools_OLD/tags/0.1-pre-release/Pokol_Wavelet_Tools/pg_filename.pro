; Name: pg_filename
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2003.05.29.
;
; Purpose: Create filename from title
;
; Calling sequence:
;	filename=pg_filename(title [,ext] [,dir])
;
; Input:
;	title: Title of the plot
;	ext (optional): Extension of file; default: '.ps'
;	dir (optional): Subdirectory of data; default: 'output'
;
; Output:
;	filename: Filename of the PS file

function pg_filename, title, ext=ext, dir=dir

; Set defaults, constants
if not(keyword_set(ext)) then ext='.eps'
if not(keyword_set(dir)) then dir='output'

filename=pg_removestr(title)
if NOT file_test(dir,/directory) then file_mkdir, dir
filename=dir_f_name(dir,i2str(1000*systime(1))+'_'+filename+ext)

return, filename

end
