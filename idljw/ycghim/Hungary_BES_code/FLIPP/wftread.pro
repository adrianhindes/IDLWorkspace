PRO WFTREAD,fname,data,rcount,NODATA=nodata,STOP=stop,				$
	TRANGE=trange,POINTN=pointn,EXT_FSAMPLE=ext_fsample,			$
	TIME=time,DATE=date,fSAMPLE=fsample,TSTART=tstart,			$
	TITLE=title,USER_NOTES=user_notes,					$
	VERTICAL_NORM=vertical_norm,VERTICAL_ZERO=vertical_zero

;
; written by Philippe Verplancke, IPP, 17/3/93,
; extended by Gerhard Herre, IPP, 18/4/94,
; last changes 24-3-98 S. Zoletnik
;

if (n_params() ne 3) then begin
  print,'Usage: wftread,fname,data,rcount,[(keyword1)=(var1), ...]'
  print,'fname		Input:      	 Filename'
  print,'trange		Input(Keyword):  Zeitbereich der gelesen werden soll [s]'
  print,'pointn		Input(Keyword):  Number of data points to read from trange(0)'
  print,'ext_fsample	Input(Keyword):  Sample Frequency [Hz]'
  print,'nodata		Input(Keyword):  No data will be read'
  print,'stop		Input(Keyword):  Stop after reading the header'
  print,'data		Output:          Data vector'
  print,'rcount		Output:          Number of read data points'
  print,'time		Output(Keyword): Time vector [s]'
  print,'date		Output(Keyword): Date, trigger time'
  print,'fsample	Output(Keyword): Sample Frequency [Hz]'
  print,'tstart		Output(Keyword): Start time of acquisition [s]'
  print,'title		Output(Keyword): Stored title of measurement'
  print,'user_notes	Output(Keyword): Notes from the user'
  return
endif

case (!version.os) of
  'vms'    : sswap = 0
  'ultrix' : sswap = 0
  'OSF'    : sswap = 0
  'sunos'  : sswap = 1
  'AIX'    : sswap = 1
  'hp-ux'  : sswap = 1
  'linux'  : sswap = 0
  'IRIX'   : sswap = 1
  'Win32'  : sswap = 0;
  else  : stop,'Unknown !version.os:',!version.os
endcase

openr,lun,fname,/get_lun

hfile = assoc(lun,bytarr(20))
header = hfile(0)

nic_id1 = fix(string(header(2:3)))
nic_id2 = fix(string(header(4:5)))
if (nic_id1 ne 2) then begin
  message,'nic_id1 invalid!'
  return
endif
if (nic_id2 ne 1) then begin
  message,'nic_id2 invalid!'
  return
endif
header_size = fix(string(header(8:19)))

hfile = assoc(lun,bytarr(header_size))
header = hfile(0)

title = string(header(44:124))

year = fix(string(header(125:127)))
month = fix(string(header(128:130)))
day = fix(string(header(131:133)))
tim = long(string(header(134:145)))
hour = tim/3600000l
minute = (tim/60000l) mod 60
second = (tim/1000l) mod 60
date = string(day,month,year,hour,minute,second,				$
		format='(i2.2,"-",i2.2,"-",i2.2,":",i2.2,".",i2.2,".",i2.2)')

data_count = long(string(header(146:157)))
vertical_zero = long(string(header(158:169)))
vertical_norm = float(string(header(170:193)))
bytes_per_data_point = fix(string(header(658:660)))
if (bytes_per_data_point ne 2) then stop,'Error#3 in WFTREAD!'
if (keyword_set(ext_fsample)) then begin
  horizontal_norm = 1./ext_fsample
  horizontal_zero = float(string(header(1060:1083)))
  horizontal_zero = horizontal_zero*horizontal_norm
endif else begin
  horizontal_norm = float(string(header(1036:1059)))
  horizontal_zero = float(string(header(1060:1083)))
endelse
fsample = 1./horizontal_norm
tstart = horizontal_zero
user_notes = string(header(312:440))

if (keyword_set(stop)) then stop

if keyword_set(trange) then begin
  i1 = long((trange(0)-horizontal_zero)/horizontal_norm)
  if (keyword_set(pointn)) then i2 = i1+pointn-1				$
		else i2 = long((trange(1)-horizontal_zero)/horizontal_norm)
  if (i1 lt 0) then begin
    print,'Warning: trange(0) invalid!'
    i1 = 0
  endif
  if (i2 gt data_count-1) then begin
    print,'Warning: trange(1) invalid!'
    i2 = data_count-1
  endif
endif else begin
  i1 = 0
  i2 = data_count-1
endelse
rcount = i2-i1+1


if keyword_set(nodata) then begin
  rcount = 0
endif else begin
  ass_dat = assoc(lun,intarr(rcount),header_size+i1*bytes_per_data_point)
  data = ass_dat(0)
  if(sswap) then byteorder,data
  data = (data-vertical_zero)*vertical_norm
  time = (findgen(rcount)+i1)*horizontal_norm+horizontal_zero
endelse

close,lun
free_lun,lun

return
end
