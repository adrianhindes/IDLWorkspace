function get_kstar_efit,shot,time,errormess=errormess,silent=silent
;************************************************************
;* GET_KSTAR_EFIT.PRO                S. Zoletnik  9.2.2012  *
;************************************************************
;* Finds and reads an EFIT file in the data directory under *
;*   <shot>/EFIT                                            *
;* INPUT:                                                   *
;*   shot: Shot number                                      *
;*   time: Time in seconds                                  *
;*   /silent: Don't print error message                     *
;* OUTPUT:                                                  *
;*   errormess: Error message or ''                         *
;*   Return value is a structure                            *
;************************************************************

  default,datapath,local_default('datapath')
  if (datapath eq '') then datapath = 'data'

  errormess = ''

  if (not keyword_set(shot)) then begin
    errormess = 'GET_KSTAR_EFIT: Shot not set.'
    if (not keyword_set(silent)) then print,errormess
    return,0
  endif
  if (not defined(time)) then begin
    errormess = 'GET_KSTAR_EFIT: Time not set.'
    if (not keyword_set(silent)) then print,errormess
    return,0
  endif


  if (!version.os ne 'Win32') then begin
    spawn,'ls -1 '+datapath+'/'+i2str(shot)+'/EFIT/g'+i2str(shot,digits=6)+'.[0-9][0-9][0-9][0-9][0-9]',flist
  endif else begin
    cmd = 'dir /b '+datapath+'\'+i2str(shot)+'\EFIT\ | findstr /R /I /C:"g'+i2str(shot,digits=6)+'.[0-9][0-9][0-9][0-9][0-9]"'
    spawn,cmd,flist
  endelse
  if (flist(0) eq '') then begin
    errormess = 'No EFIT files found for shot '+i2str(shot)
    return,0
  endif
  times = float(strmid(flist,8,5))/1000
  ind = closeind(times,time)
  filename = dir_f_name(dir_f_name(dir_f_name(datapath,i2str(shot)),'EFIT'),flist[ind])
  time = times[ind]
  data = efit_reader(filename,errormess=errormess,/silent)
  if (errormess ne '') then begin
    if (not keyword_set(silent)) then print,errormess
    return,0
  endif

  return,data
end