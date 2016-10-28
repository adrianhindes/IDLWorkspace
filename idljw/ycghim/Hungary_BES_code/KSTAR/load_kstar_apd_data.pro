pro load_kstar_apd_data,shot,sampletime=sampletime,samplecount=samplecount_proc,errormess=errormess

; Loads the measured APDCAM data into the data array

  default,bits,12
  default,channel_masks,[255,255,255,255]
  default,samplecount_proc,3000000l
  default,sampletime,1e-7*30

  errormess = ''

start_adc = 1
stop_adc = 4
for adc=start_adc,stop_adc do begin

  channels = 0
  m = hex('01')
  for i=0,7 do begin
    if ((m and channel_masks[adc-1]) ne 0) then begin
      channels = channels+1
      if (channels eq 1) then begin
        channel_list = i
      endif else begin
        channel_list = [channel_list,i]
      endelse
    endif
    m = ishft(m,1)
  endfor

  if (channels eq 0) then continue

signal_cache_delete,/all

    for i=0,31 do begin
      adc = fix(i/8)+1
      if ((channel_masks[adc-1] and ishft(byte(1),i mod 8)) ne 0) then begin
        datafile = 'data\'+i2str(shot)+'\Channel'+i2str(i,digit=2)+'.dat'
        openr,unit,datafile,/get_lun,error=error
        if (error ne 0) then begin
          errormess = 'Error opening file: '+datafile
          if (not keyword_set(silent)) then print,errormess
          return
        endif
        on_ioerror,loaderr
        a = assoc(unit,intarr(samplecount_proc),0)
        data = reform(a[0])
        data = (data-data[0])/4096.*2000
        close,unit & free_lun,unit
        signal_cache_add,start=0,sampletime=sampletime,data=data,name='ADC'+i2str(i+1)
     endif
    endfor
endfor ; adc

return

loaderr:
  close,unit & free_lun,unit
  errormess = 'Error reading file:'+datafile
  return
end