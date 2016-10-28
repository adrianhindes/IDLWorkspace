pro read_nidata,filename,channel,config=config,nodata=nodata,errormess=errormess,data=data,time=time,noscale=noscale

; ********************************************************************************
; * READ_NIDATA.PRO                                                              *
; *      Read data written by ni... programs.                                    *
; *------------------------------------------------------------------------------*
; *     13.08.2003                       S. Zoletnik, KFKI-RMKI                  *
; *                                                                              *
; *     Modified reading multiple file format        D. Dunai  /2008. 02.26.     *
; *------------------------------------------------------------------------------*
; * Reads one channel or configuration from a  data file.                        *
; * INPUT:                                                                       *
; *  /nodata: Do not read data, only configuration                               *
; *  filename: Name of file to read                                              *
; *  channel: Channel number (1...)                                              *
; *  /noscale: Do not scale data with gain, return values in original in format. *
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

if (line ne 'NI6115 V1.0') and  (line ne 'NI6115 V2.0') then begin
  errormess = 'Error. File '+filename+' is not a standard data file from NI.'
  return
endif

file_version=line

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
  4: config.gain = 4;
  8: config.gain = 8;
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

if file_version eq 'NI6115 V1.0' then begin

a = assoc(unit,dblarr(config.number_of_samples),offset_start)
data = a(channel-1)
time = dindgen(config.number_of_samples)/config.sample_rate+config.start_time
close,unit & free_lun,unit
return

endif


if file_version eq 'NI6115 V2.0' then begin

a = assoc(unit,INTARR(config.number_of_samples),offset_start)
data = a(channel-1)
if (not keyword_set(noscale)) then begin
  ;scale the data
  ;range is -10, 10 V ->LSB = 10/gain
  data = data*(10./config.gain)*(1./2.^15)
endif

time = dindgen(config.number_of_samples)/double(config.sample_rate)+config.start_time
close,unit & free_lun,unit


return

endif


err:
errormess = 'Error reading file '+filename
close,unit & free_lun,unit
return

end

