pro read_ni6115,filename,channel,config=config,nodata=nodata,errormess=errormess,$
       data=data,time=time,trange=trange

; ********************************************************************************
; * READ_ni6115.PRO                                                              *
; *      Read data written by ni6115_shot program.                               *
; *------------------------------------------------------------------------------*
; *     13.08.2003                       S. Zoletnik, KFKI-RMKI                  *
; *                        zoletnik@rmki.kfki.hu                                 *
; *------------------------------------------------------------------------------*
; * Reads one channel or configuration from a  data file.                        *
; * INPUT:                                                                       *
; *  /nodata: Do not read data, only configuration                               *
; *  filename: Name of file to read                                              *
; *  channel: Channel number (1...)                                              * 
; *  trange: time range for deta read.                                           *
; *          THIS IS IN s,relative to the trigger time.                          *                  *
; * OUTPUT:                                                                      *
; *  time: Time vector in sec relative to trigger.                               *
; *  data: Data vector                                                           *
; *  config: Configuration information (structure)                               *
; *  errormess: Error message or ''                                              *
; ********************************************************************************

errormess = '';

; Open file
openr,unit,filename,/get_lun,error=error
if (error ne 0) then begin
  errormess = 'Error opening file: '+!err_string
  return
endif

count_pos = 0

on_ioerror,err

line = ''
readf,unit,line
count_pos = count_pos+strlen(line)+2
if (line ne 'NI6115 V1.0') then begin
  errormess = 'Error. File '+filename+' is not an ni6115_shot data file.'
  return
endif

config = { ni6115_struct, start_time: 0.0,        $
                          meas_time:  0.0,        $
                          sample_rate: 0L,        $
                          number_of_samples: 0L,  $
                          number_of_channels: 0,  $
                          gain: 0.0 }

line = ''
readf,unit,line
count_pos = count_pos+strlen(line)+2
config.start_time = double(line);

readf,unit,line
count_pos = count_pos+strlen(line)+2
config.meas_time = double(line);

readf,unit,line
count_pos = count_pos+strlen(line)+2
config.sample_rate = long(line);

readf,unit,line
count_pos = count_pos+strlen(line)+2
config.number_of_samples = long(line);

readf,unit,line
count_pos = count_pos+strlen(line)+2
config.number_of_channels = fix(line);

readf,unit,line
count_pos = count_pos+strlen(line)+2
gain = fix(line)
case gain of
  -2: config.gain = 0.2;
  -1: config.gain = 0.5;
  1: config.gain = 1
  2: config.gain = 2 ;
  5: config.gain = 5;
  10: config.gain = 10;
  20: config.gain = 20;
  50: config.gain = 50;
  default: begin
    errormess = 'Bad gain value in data file.'
    close_unit & free_lun,unit
    return
    end
endcase


if (keyword_set(nodata)) then begin
  close,unit & free_lun,unit
  return
end

if ((channel lt 1) or (channel gt config.number_of_channels)) then begin
  errormess = 'Bad channel number.'
  close,unit & free_lun,unit
  return
endif



; Now file pointer is at start of data, get offset value
; Unfortunately this does nto seem to work under windows, thus we
; replace this by counting the position in the file
; offset_start = 0l
; point_lun, -unit, offset_start
offset_start = long(count_pos)
if (keyword_set(trange)) then begin
  if (trange[0] ge trange[1]) then begin
    errormess = 'Invalid trange.'
    print,errormess
    close,unit & free_lun,unit
    return
  endif
  if (trange[1] lt config.start_time) or (trange[0] ge config.start_time+config.number_of_samples/config.sample_rate) then begin
    time = 0
    data = 0;
    errormess = 'No data in time interval.'
    print,errormess
    close,unit & free_lun,unit
    return
  endif
  
  trange[1] =  min([trange[1] , config.start_time+config.number_of_samples/config.sample_rate])
  trange[0] =  max([trange[0] , config.start_time])
  
  nread = long(double(trange[1]-trange[0])*config.sample_rate)
  nstart = long(double(trange[0]-config.start_time)*config.sample_rate)
  if (nstart+nread gt config.number_of_samples) then nread = config.number_of_samples-nstart
endif else begin
  nread = config.number_of_samples
  nstart = 0;
endelse
  
a = assoc(unit,intarr(nread),offset_start+nstart*2)
data = a(channel-1)
time = (dindgen(nread)+nstart)/config.sample_rate+config.start_time
close,unit & free_lun,unit
return

err:
errormess = 'Error reading file '+filename
close,unit & free_lun,unit
return

end

