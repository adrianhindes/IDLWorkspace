function flukfile,shot,ch,afs=afs,cdrom=cdrom,data_source=data_source
; returns the file name for a channel data file  (Nicolet data)
; /afs: searches in afs
; /cdrom: data from cdrom (dir: /cdrom/ff)
; data_source:  see get_rawsignal.pro
;               (only 0 and 5 is handled by flukfile.pro
; ch can be either a channel number(see below) or a channel name(see meas_config.pro) 
; Channel numbering: 1...28 Li-beam channels
;                    29:  Libeam Halpha
;                    30:  Li-beam pressure
;                    31:  Mirnov1/1
;                    32:  Mirnov1/2 
;                    33:  Li-beam 21 measured in Nicolet2
;                    34:  Mirnov A
;                    35:  Mirnov B
; Channel names:
; The channel names used in meas_config.pro can be used.
; Additionally a @1, @2, ... at the end means that the signal measured
; the first, second, ... place in the system should be used. This is useful
; if one signal is measured in more than one channel for test purposes

default,data_source,0

if ((data_source ne 0) and (data_source ne 5)) then begin
  print,'Error in flukfile.pro. This routine can be called only with data_source 0 or 5.'
  return,'???'
endif
  
if (not keyword_set(afs) and not keyword_set(cdrom)) then begin
  bfn='data/'
  exten='.wft'
endif 

if (data_source eq 0) then begin
  if (keyword_set(afs)) then begin
    bfn='/afs/ipp/w7as/fluk/ff'+i2str(fix(shot/100),digits=3)+'/'
    exten='.wft'
  endif
  if (keyword_set(cdrom)) then begin
    spawn,'grep '+i2str(shot,digits=5)+' W7_shot_locator.dat',unit=unit
    wl=long(0)
    wtxt=''
    on_ioerror,err
    readf,unit,wl,wtxt
    if (wl ne long(shot)) then begin
      err:
      print,'Cannot find shot '+i2str(shot,digits=5)+' in W7_shot_locator.dat'
      return,'???'
    endif
    wtxt=strcompress(wtxt,/remove_all)
    on_ioerror,null
    close,unit
    free_lun,unit
    cd_ok=0
    while not cd_ok do begin
      openr,unit,'cdrom/'+wtxt,error=error,/get_lun
      if (error ne 0) then begin
        print,'Please put in and mount CD named "'+wtxt+'"'
        if (not ask('Done?')) then return,'???'
      endif else begin
        close,unit
        free_lun,unit
        cd_ok=1
      endelse
    endwhile       
    bfn='cdrom/ff'+i2str(fix(shot/100),digits=3)+'/'
    exten='.wft'
  endif
endif
if (data_source eq 5) then begin
  if (keyword_set(afs)) then begin
    bfn='/afs/ipp/w7as/fluk/ff_aug'+i2str(fix(shot/100),digits=3)+'/'
    exten='.wft'
  endif
  if (keyword_set(cdrom)) then begin
    print,'CDROM data is not yet available for AUG.'
    return,'???'
  endif
endif 

     
if ((not defined(ch)) or ((size(ch))(0) ne 0)) then begin
  print,'Bad channel number or channel not defined in flukfile.pro.'
  return,'???'
endif

if (data_source eq 0) then begin
  if ((size(ch))(1) ne 7) then begin  ; convert to channel name if not string
    if ((ch ge 1) and (ch le 28)) then ch_str='Li-'+i2str(ch)
    if (ch eq 29) then ch_str='Halpha'
    if (ch eq 30) then ch_str='Pressure'
    if (ch eq 31) then ch_str='Mirnov/1'
    if (ch eq 32) then ch_str='Mirnov/2'
    if (ch eq 33) then begin
      ch_str='Li-21'
      meas_index=2
    endif  
    if (ch eq 34) then ch_str='Mir-A'
    if (ch eq 35) then ch_str='Mir-B'
    if (not defined(ch_str)) then begin
      print,'Bad channel number in flukfile.pro!'
      return,'???'
    endif  
  endif else begin
    ind=strpos(ch,'@')
    if ((ind gt 0) and (ind lt strlen(ch)-1)) then begin
      meas_index=fix(strmid(ch,ind+1,strlen(ch)-(ind+1)))
      ch_str=strmid(ch,0,ind)
    endif else begin  
      ch_str=ch
    endelse  
  endelse
endif
if (data_source eq 5) then begin
  if ((size(ch))(1) ne 7) then begin  ; convert to channel name if not string
    if ((ch ge 1) and (ch le 35)) then ch_str='Li-'+i2str(ch)
    if (not defined(ch_str)) then begin
      print,'Bad channel number in flukfile.pro!'
      return,'???'
    endif  
  endif else begin
    ind=strpos(ch,'@')
    if ((ind gt 0) and (ind lt strlen(ch)-1)) then begin
      meas_index=fix(strmid(ch,ind+1,strlen(ch)-(ind+1)))
      ch_str=strmid(ch,0,ind)
    endif else begin  
      ch_str=ch
    endelse  
  endelse
endif


default,meas_index,1

r=meas_config(shot,data_source=data_source,channel_list=channel_list,signal_list=signal_list)
if (r ne 0) then return,'???'
ind=where(signal_list eq ch_str)
get_rawsignal,data_names=syst_names
if (ind(0) lt 0) then begin
  print,'Signal '+ch_str+' is not available in '+syst_names(data_source)+' in shot '+i2str(shot,digits=5)     
  return,'???'
endif
if (meas_index eq 1) then begin
  nic_ch=channel_list(ind(0))
endif else begin
   if (n_elements(ind) lt meas_index) then begin
     print,'Signal '+ch_str+' was measuired in Nicolet system only '+$
       i2str(n_elements(ind))+' time(s) in shot '+i2str(shot,digits=5) 
     return,'???'
   endif
   nic_ch=channel_list(ind(meas_index-1))  
endelse  
if (nic_ch le 16) then begin
  system='0'
  ch1=nic_ch
endif else begin  
  system='1'
  ch1=nic_ch-16
endelse  
  

if (data_source eq 0) then begin
  fn=bfn+i2str(shot,digit=5)+system+i2str(fix(ch1/10))+i2str(ch1 mod 10)+exten
endif  
if (data_source eq 5) then begin
  fn=bfn+'aug_'+string(shot,format='(I5)')+system+i2str(fix(ch1/10))+i2str(ch1 mod 10)+exten
endif
  
return,fn
end

