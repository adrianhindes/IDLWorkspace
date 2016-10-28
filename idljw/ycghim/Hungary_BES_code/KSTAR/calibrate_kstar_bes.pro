pro calibrate_kstar_bes,shot,timerange=timerange,offset_timerange=offset_timerange,$
                        errormess=errormess,datapath=datapath,visual=visual,timefile=timefile,$
                        offset_timefile=offset_timefile

;*******************************************************************************************
;*                                                                                         *
;* calibrate_kstar_bes.pro              S. Zoletnik  6.08.2011                             *
;*                                      M. Lampert   23.01.2012                            *
;* Do relative calibration of the BES channels by calculating                              *
;* mean signal in a gas shot.                                                              *
;* A gas shot can be a dedicated one or can be somewhere after a                           *
;* disruption when the beam is still firing into the residual gas.                         *
;* The program will enter a new line into the calibration database                         *
;* in cal\calib_database.dat. It is a text file, each calibration is one line:             *
;* shot cal-version mirror-pos 32xmean intensities                                         *
;*  cal-version is a version number in case multiple calibrations exist for the same shot  *
;*  mirror-pos is either 'Close' or 'Remote'                                               *
;*  The first line contains the channel list                                               *
;* INPUT:                                                                                  *
;*   shot: The calibration shot                                                            *
;*   timerange: The time range when the mean signals are calulated                         *
;*   timefile: Alternative to timerange                                                    *
;*   offset_timerange: Timerange when the channel 0 line is calculated.                    *
;*   offset_timefile: Alternative to offset timerange                                      *
;*                                                                                         *
;* OUTPUT:                                                                                 *
;*   errormess: Error message or '' if no error                                            *
;*******************************************************************************************

if (defined(timerange) and defined(timefile)) then begin
  errormess = 'Specify only one of timefile and timerange.'
  if (not keyword_set(silent)) then print,errormess
  return
endif  
if (defined(offset_timerange) and defined(offset_timefile)) then begin
  errormess = 'Specify only one of offset_timefile and offset_timerange.'
  if (not keyword_set(silent)) then print,errormess
  return
endif 

;These lines are for data input through visual (M. Lampert)
if (keyword_set(visual)) then begin
  show_rawsignal,shot,'BES-1-1',timerange=timerange
  print, 'click on a time point to zoom when the nbi goes into the gas!'
  cursor, t1, y, /down
  show_rawsignal,shot,'BES-1-1', trange=[t1-0.1,t1+0.1]
  print, 'Click on the beginning and the end of the calibration time range! (no plasma, but nbi is on)'
  cursor, t1, y, /down
  cursor, t2, y, /down
  if (t1 gt t2) then begin
    temp=t1
    t1=t2
    t2=temp
  endif
  timerange=[t1,t2]
  show_rawsignal,shot,'BES-1-1'
  print, 'Click on the beginning and the end of the offset time range! (end of the shot, no plasma, no NBI)'
  cursor, t1,y,/down
  cursor, t2,y,/down
  if (t1 gt t2) then begin
    temp=t1
    t1=t2
    t2=temp
  endif
  offset_timerange=[t1,t2]
  print, 'Timerange: ['+strtrim(timerange[0],2)+','+strtrim(timerange[1],2)+']'
  print, 'Offset timerange: ['+strtrim(offset_timerange[0],2)+','+strtrim(offset_timerange[1],2)+']'
endif


errormess = ''

default,cal_path,local_default('cal_path',/silent)
if (cal_path eq '') then begin
  res = routine_info('calibrate_kstar_bes',/source)
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

; Making backup of calibration file
if (strupcase(!version.os) eq 'WIN32') then cmd = 'del '+cal_table_file_backup+' & copy '+cal_table_file+' '+cal_table_file_backup
if (strupcase(!version.os) eq 'LINUX') then cmd = 'rm -f '+cal_table_file_backup+' ; cp '+cal_table_file+' '+cal_table_file_backup
spawn,cmd

openr,unit,cal_table_file,/get_lun,error=error
if (error ne 0) then begin
  errormess = 'Cannot open calibration table file, creating new.'
  if (not keyword_set(silent)) then print,errormess
  openw,unit,cal_table_file,/get_lun,error=error
  if (error ne 0)then begin
    errormess = 'Cannot create calibration table file:'+dir_f_name(cal_path,cal_table_file)
    if (not keyword_set(silent)) then print,errormess
    return
  endif
  channels = strarr(nch)
  txt = ''
  for i=0,nch-1 do begin
    channels[i] = 'BES-'+i2str(fix(i/ncol)+1)+'-'+i2str(i mod ncol + 1)
    txt = txt+' '+channels[i]
  endfor
  printf,unit,txt
  close,unit & free_lun,unit
  ; Making backup of calibration file
  if (strupcase(!version.os) eq 'WIN32') then cmd = 'del '+cal_table_file_backup+' & copy '+cal_table_file+' '+cal_table_file_backup
  if (strupcase(!version.os) eq 'LINUX') then cmd = 'rm -f '+cal_table_file_backup+' ; cp '+cal_table_file+' '+cal_table_file_backup
  spawn,cmd
endif else begin
  close,unit & free_lun,unit
endelse

openr,unit_r,cal_table_file_backup,/get_lun,error=error
if (error ne 0) then begin
  errormess = 'Cannot open backup calibration table file, exiting.'
  if (not keyword_set(silent)) then print,errormess
  return
endif

on_ioerror,ioerror_handler_r
; reading channels from first line of file
txt_ch = ''
readf,unit_r,txt_ch
channels = strsplit(txt_ch,' ',/extract)
nch = n_elements(channels)

openw,unit_w,cal_table_file,/get_lun,error=error
if (error ne 0) then begin
  errormess = 'Cannot open calibration table file, exiting.'
  if (not keyword_set(silent)) then print,errormess
  return
endif

on_ioerror,ioerror_handler_w
printf,unit_w,txt_ch

calfac = fltarr(nch)
if (defined(timefile)) then begin
  timefile_d = loadncol(dir_f_name('time',timefile),2,errormess=errormess)
  if (errormess ne '') then begin
    if (not keyword_set(silent)) then print,errormess
    goto,ioerror_handler_notxt   
  endif
  timerange = [min(timefile_d),max(timefile_d)]
endif  
if (defined(offset_timefile)) then begin 
  timefile_do = loadncol(dir_f_name('time',offset_timefile),2,errormess=errormess)
  if (errormess ne '') then begin
    if (not keyword_set(silent)) then print,errormess
    goto,ioerror_handler_notxt
  endif
  offset_timerange = [min(timefile_do),max(timefile_do)]
endif  

for i=0,nch-1 do begin
  print,channels[i]
  wait,0.1
  get_rawsignal,shot,'KSTAR/'+channels[i],t,d,trange=timerange,errormess=errormess,datapath=datapath,/nocalibrate
  if (errormess ne '') then begin
    if (not keyword_set(silent)) then print,errormess
    goto,ioerror_handler_notxt
  endif
  if (defined(timefile)) then begin
    nt = (size(timefile_d))[1]
    npoint = 0
    for it=0,nt-1 do begin
      ind = where((t ge timefile_d[it,0]) and (t le timefile_d[it,1]))
      if (ind[0] ge 0) then begin
        calfac[i] = calfac[i]+total(d[ind])
        npoint = npoint+n_elements(ind)
      endif  
    endfor 
  endif else begin      
    calfac[i] = total(d)
    npoint = n_elements(d)
  endelse
  calfac[i] = calfac[i]/npoint
  
  ; offset correction
  if ((n_elements(offset_timerange) ge 2) or defined(offset_timefile)) then begin
    get_rawsignal,shot,'KSTAR/'+channels[i],t,d,trange=offset_timerange,errormess=e,datapath=datapath,/nocalibrate
    if (e ne '') then begin
      if (not keyword_set(silent)) then print,errormess
      goto,ioerror_handler_notxt
    endif
    calfac_off = 0
    if (defined(offset_timefile)) then begin
      nt = (size(timefile_do))[1]
      npoint = 0
      for it=0,nt-1 do begin
        ind = where((t ge timefile_do[it,0]) and (t le timefile_do[it,1]))
        if (ind[0] ge 0) then begin
          calfac_off = calfac_off+total(d[ind])
          npoint = npoint+n_elements(ind)
        endif  
      endfor 
    endif else begin      
      calfac_off = total(d)
      npoint = n_elements(d)
    endelse
    calfac[i] = calfac[i]-calfac_off/npoint
  endif
endfor
calfac = calfac/mean(calfac)
load_config_parameter,shot,'Optics','MirrorPosition',data_source=32,output_struct=srad,$
         datapath=datapath,errormess=e,/silent
if (e ne '') then begin
    load_config_parameter,shot,'Optics','RadialMirrorPosition',data_source=32,output_struct=srad,$
         datapath=datapath,errormess=e,/silent
    if (e ne '') then begin
      if (not keyword_set(silent)) then print,e
      goto,ioerror_handler_notxt
    endif
endif
load_config_parameter,shot,'Optics','VerticalMirrorPosition',data_source=32,output_struct=svert,$
         datapath=datapath,errormess=e,/silent

added = 0
version = 1

while (not eof(unit_r) or (not keyword_set(added))) do begin
  if (not eof(unit_r)) then begin
    on_ioerror,ioerror_handler_r
    txt_orig = ''
    readf,unit_r,txt_orig
    txt_filled = 1
  endif else begin
    txt_filled = 0
  endelse
  if (not keyword_set(added)) then begin
    if (txt_filled eq 1) then begin
      addnow = 0
      txt = strcompress(txt_orig)
      d = strsplit(txt,' ',/extract)
      if (n_elements(d) lt nch+3) then begin
        errormess = 'Invalid calibration file format: '+txt
        if (not keyword_set(silent)) then print,errormess
        goto,ioerror_handler_notxt
      endif
      c_shot = d[0]
      c_version = d[1]
      if (shot le c_shot) then begin
        if (shot eq c_shot) then begin
          if (version le c_version) then begin
            ; If there is a calibration for this shot then increasing version
            version = version+1
          endif else begin
            ; We have to enter data here
            addnow = 1
          endelse
         endif else begin
          addnow = 1
        endelse
      endif
    endif else begin
      ; If no data from file
      addnow = 1
    endelse

    if (keyword_set(addnow) or not keyword_set(txt_filled)) then begin
      txt_new = i2str(shot)+' '+i2str(version)+' '+srad.value
      for i=1,nch do begin
        txt_new = txt_new+' '+string(calfac[i-1],format='(F10)')
      endfor
      on_ioerror,ioerror_handler_w
      printf,unit_w,txt_new
      added = 1
    endif
  endif  ; not added yet
  ; Copying original line
  on_ioerror,ioerror_handler_w
  if (txt_filled) then printf,unit_w,txt_orig
endwhile

close,unit_r & free_lun,unit_r
close,unit_w & free_lun,unit_w
print,'Calibration data added.'
return

ioerror_handler_w:
errormess = 'Error writing calibration table file.'
if (not keyword_set(silent)) then print,errormess
goto,ioerror_handler_notxt

ioerror_handler_r:
errormess = 'Error reading calibration table file.'
if (not keyword_set(silent)) then print,errormess

ioerror_handler_notxt:
print,'Recovering backup calibration file.'
close,unit_r & free_lun,unit_r
if (defined(unit_w)) then begin
  close,unit_w & free_lun,unit_w
endif
; Recovering backup of calibration file
if (strupcase(!version.os) eq 'WIN32') then cmd = 'del '+cal_table_file+' & copy '+cal_table_file_backup+' '+cal_table_file
if (strupcase(!version.os) eq 'LINUX') then cmd = 'rm -f '+cal_table_file+' ; cp '+cal_table_file_backup+' '+cal_table_file
spawn,cmd
return
stop
end
