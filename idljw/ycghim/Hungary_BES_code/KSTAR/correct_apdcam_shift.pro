pro correct_apdcam_shift,shot,data_source=data_source,shift_sample=shift_sample,$
  datapath=datapath,sample_n=sample_n

default,data_source,32
default,datapath,local_default('datapath')

chn = n_elements(shift_sample)*8

path_orig = dir_f_name(datapath,i2str(shot))
path_mod = dir_f_name(datapath,i2str(shot)+'_mod')
cmd = 'mkdir '+path_mod
spawn,cmd
for i=0,chn-1 do begin
  block = i/8
  fn = 'Channel_'+i2str(i,digits=3)+'.dat'
  fn_orig = dir_f_name(path_orig,fn)
  fn_mod = dir_f_name(path_mod,fn)
  if ((block mod 4) eq 0) or (shift_sample[block] eq 0) then begin
    if (strupcase(!version.os) eq 'WIN32') then begin
      cmd = 'copy '+fn_orig+' '+fn_mod
    endif else begin
      cmd = 'cp '+fn_orig+' '+fn_mod
    endelse
    spawn,cmd
  endif else begin
    openr,unit,fn_orig,error=e,/get_lun
    if (e ne 0) then begin
      print,'Cannot open file: '+fn_orig
      return
    endif
    a = assoc(unit,intarr(sample_n),0)
    d = a[0]
    close,unit & free_lun,unit

    if (shift_sample[block] lt 0) then begin
      d[shift_sample[block]:sample_n-1] = d[0:sample_n-1-shift_sample[block]]
      d[0:shift_sample[block]-1] = 0
    endif
    if (shift_sample[block] gt 0) then begin
      d[0:sample_n-1-shift_sample[block]] = d[shift_sample[block]:sample_n-1]
      d[sample_n-1-shift_sample[block]:sample_n-1] = 0
    endif

    openw,unit,fn_mod,error=e,/get_lun
    if (e ne 0) then begin
      print,'Cannot open file: '+fn_mod
      return
    endif
    a = assoc(unit,intarr(sample_n),0)
    a[0] = d
    close,unit & free_lun,unit
  endelse
endfor

if (strupcase(!version.os) eq 'WIN32') then begin
  cmd = 'rename '+path_orig+' '+path_orig+'_orig'
  cmd1 = 'rename '+path_mod+' '+path_orig
endif else begin
  cmd = 'mv '+path_orig+' '+path_orig+'_orig'
  cmd1 = 'mv '+path_mod+' '+path_orig
endelse
spawn,cmd




readerr:
print,'Error reading file: '+fn_orig
return

writeerr:
print,'Error writing file: '+fn_mod
return


end