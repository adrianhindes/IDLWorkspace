pro read_kstar_mdsplus,shot,mdsplus_name,time,data,erormess=errormess,no_time=no_time
;**********************************************************
; READ_KSTAR_MDSPLUS.PRO           S. Zoletnik 25.01.2012
;**********************************************************
; Reads data from the KSTAR MDSPlus tree
;
; INPUT:
;   shot: shot number
;   mdsplus_name: node name
;   /no_time: Do not read time vector. (Will return 0 in time.)
; OUTPUT:
;   time: time vector
;   data: data
;   errormess: error string or ''
;***********************************************************

data=0
time=0
errormess = ''

mdsconnect,'172.17.250.100:8005',status=stat,/quiet
;mdsconnect,'172.17.100.200:8300',status=stat,/quiet
if ((stat mod 2) eq 0) then begin
  errormess = 'Error connecting to KSTAR MDSPlus server.'
  return
endif
mdsopen,'kstar',shot,status=stat,/quiet
if ((stat mod 2) eq 0) then begin
  errormess = 'Error opening KSTAR shot.'
  return
endif
forward_function mdsvalue
data = mdsvalue('_y='+mdsplus_name,status=stat,/quiet)
if ((stat mod 2) eq 0) then begin
  errormess = 'Error reading signal from MDSPlus.'+mdsplus_name
  return
endif
if (not keyword_set(no_time)) then begin
  time = mdsvalue('dim_of(_y)',status=stat)
  if ((stat mod 2) eq 0) then begin
    errormess = 'Error reading time vector from MDSPlus.'
   return
  endif
endif

end