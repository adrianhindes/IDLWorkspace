function getcal_kstar,shot,cal_shot=cal_shot,cal_version=cal_version,channels=channels,errormess=errormess,$
  new=new,plot=plot,thick=thick,charsize=charsize

;**************************************************************************************
;* GETCAL_KSTAR.PRO                                  S. Zoletnik   2011               *
;**************************************************************************************
;* Get the BES calibration factors for one KSTAR shot.                                *
;* If a calibration file in the cal directory is already available for                *
;* this shot it is read. If not the calibration factors will be read from the         *
;* calibration table using cal_shot and cal_version and stored in a calibration       *
;* file for the current shot.                                                         *
;* The calibration directory is under the KSTAR IDL program directory.                *
;*                                                                                    *
;* INPUT:                                                                             *
;*   shot: The shot number for which the calibration is read                          *
;*   cal_shot: The shot number of the calibration data in the database.               *
;*   cal_version: The version number of the calibration data for the calibration shot *
;*                (def: 1)                                                            *
;*   channels: List of channels (string array, BES-1-1....). Can be omitted.          *
;*   /new: prepare new calibration file for this shot                                 *
;*   /plot: Plot calibration factors read from <shot>.cal file.                       *
;* OUTPUT:                                                                            *
;*   errormess: Error message, '' if no error occured                                 *
;**************************************************************************************

errormess=''

if (keyword_set(new) and not defined(cal_shot)) then begin
  errormess = 'New calibration is requested but no cal_shot paramameter is set.'
  print,errormess
  return,0
endif

default,cal_path,local_default('cal_path',/silent)
if (cal_path eq '') then begin
  res = routine_info('getcal_kstar',/source,/func)
  cal_path = strmid(res[0].path,0,strlen(res[0].path)-strlen(res[0].name)-5)
  cal_path = dir_f_name(cal_path,'cal')
endif

if (shot gt 10000) then begin
  cal_table_file = dir_f_name(cal_path,'KSTAR-BES_64_calibration_table.dat')
  cal_table_file_backup = dir_f_name(cal_path,'KSTAR-BES_64_calibration_table_backup.dat')
  nch = 64
  ncol = 16
endif else begin
  cal_table_file = dir_f_name(cal_path,'KSTAR-BES_calibration_table.dat')
  cal_table_file_backup = dir_f_name(cal_path,'KSTAR-BES_calibration_table_backup.dat')
  nch = 32
  ncol =8
endelse

shot_calfile = dir_f_name(cal_path,i2str(shot)+'.cal')
openr,unit,shot_calfile,error=e,/get_lun
if ((e eq 0) and not keyword_set(new)) then begin
  ; Calibration file exists and no new calibration requested
  txt = ''
  on_ioerror,error_handler
  readf,unit,txt
  txt = strcompress(txt)
  channels = strsplit(txt,' ',/extract)

  txt = ''
  readf,unit,txt
  txt = strcompress(txt)
  cal = strsplit(txt,' ',/extract)
  cal = float(cal)

  if (n_elements(cal) ne n_elements(channels)) then begin
    errormess = 'Channel list and calibration data has different length.'
    if (not keyword_set(silent)) then print,errormess
    close,unit & free_lun,unit
    return,0
  endif

  close,unit & free_lun,unit

  if (keyword_set(plot)) then begin
    plot,[0,1],xrange=[0,ncol+1],xstyle=1,yrange=[0,1.05],xtitle='Row',ystyle=1,title='Normalized calibration factors per row.',$
      xthick=thick,ythick=thick,thick=thick,charthick=thick,charsize=charsize,/nodata
    for i=0,3 do begin
      plotsymbol,i
      c = cal[0+ncol*i:ncol-1+ncol*i]
      oplot,findgen(ncol)+1,c/max(c),thick=thick,psym=-8,linestyle=i,symsize=charsize
    endfor  
  endif

  return,cal

  error_handler:
  errormess = 'Error reading calibration file.'
  if (not keyword_set(silent)) then print,errormess
  close,unit & free_lun,unit
  return,0
endif else begin
  ; no calibration file exists
  if (not defined(cal_shot)) then begin
    errormess = 'No calibration shot is set and no calibration file is found.'
    if (not keyword_set(silent)) then print,errormess
    return,0
  endif

  default,cal_version,1

  openr,unit,cal_table_file,/get_lun,error=error
  if (error ne 0) then begin
    errormess = 'Cannot open calibration table file.'
    if (not keyword_set(silent)) then print,errormess
    return,0
  endif
  on_ioerror,error_handler1
  txt = ''
  readf,unit,txt
  txt = strcompress(txt)
  channels = strsplit(txt,' ',/extract)

  while (not eof(unit)) do begin
    txt = ''
    readf,unit,txt
    txt = strcompress(txt)
    d = strsplit(txt,' ',/extract)
    if ((long(d[0]) eq long(cal_shot)) and (fix(d[1]) eq fix(cal_version)))then begin
      cal = float(d[3:nch+2])
      break
    endif
  endwhile
  close,unit & free_lun,unit

  if (not defined(cal)) then begin
    errormess = 'Requested calibration data not found in calibration table.'
    if (not keyword_set(silent)) then print,errormess
    return,0
  endif

  openw,unit,shot_calfile,error=e,/get_lun
  if (error ne 0) then begin
    errormess = 'Cannot open shot calibration file for writing.'
    if (not keyword_set(silent)) then print,errormess
    return,0
  endif

  on_ioerror,error_handler2
  txt = ''
  txt1 = ''
  for i=0,nch-1 do begin
    txt = txt+' '+channels[i]
    txt1 = txt1+' '+string(cal[i],format='(F10)')
  endfor
  printf,unit,txt
  printf,unit,txt1
  close,unit & free_lun,unit
  return,cal

  error_handler1:
  errormess = 'Error reading calibration table file.'
  if (not keyword_set(silent)) then print,errormess
  close,unit & free_lun,unit
  return,0

  error_handler2:
  errormess = 'Error writing shot calibration file.'
  if (not keyword_set(silent)) then print,errormess
  close,unit & free_lun,unit
  return,cal
endelse

end