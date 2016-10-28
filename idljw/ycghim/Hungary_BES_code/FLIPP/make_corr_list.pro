pro make_corr_list,shot,list,experiment=experiment

;***************************************************************************
; make_corr_list                    S. Zoletnik   8.9.1997
;***************************************************************************
; Reads all correlation files for a given shot and writes its parameters
; into zzt/<shot>_lst.sav as an IDL save file containing an array of
; structures. Each structure contains the following data:
; <filename>  <shot> <channel_mask> <timefile> <tres> <trange>
; <cut_length> <data_source> <autocorr_cut> <matrix> <density_flag> ...
; If other parameters will be ne necessary in the future, then this program
; and update_corr_list.pro and load_zztcorr.pro should be modified.
;***************************************************************************


list=0

l={filename: 'x',$
   shot: 33333.0,$
   chan_prefix: ' ',$
   chan_postfix: ' ',$
   channel_mask: fltarr(28),$
   timefile: 'x',$
   tres: 1.0,$
   trange: [-1.0, 1.0],$
   cut_length: 5.0,$
   data_source: 0,$
   autocorr_cut: 1.0,$
   matrix: 'x',$
   density_flag: 0,$
   simdens_flag: 0,$
   nofix1: 0,$
   nofix2: 0}
if (keyword_set(experiment)) then basefile=experiment else basefile=i2str(shot,digits=5)
for j=0,2 do begin
  i=0
  found=1
  if (j eq 0) then fbase=basefile+'.zzt.sav'
  if (j eq 1) then fbase=basefile+'.zzt_ne_rec.sav'
  if (j eq 2) then fbase=basefile+'.zzt_ne_sim.sav'
  while (found) do begin
    fn=fbase+'.'+i2str(i)
    openr,unit,'zzt/'+fn,error=error,/get_lun
    if (error ne 0) then begin
      found=0
    endif else begin
      close,unit
      free_lun,unit
      channels=0
      if (j eq 1) then rec_w=1 else rec_w=0
      if (j eq 2) then dens_w=1 else dens_w=0
      load_zztcorr,shot,file=fn,channels=channels,trange=trange,tres=tres,cut_length=cut_length,$
                   timefile=timefile,autocorr_cut=autocorr_cut,matrix=matrix,data_source=data_source,$
                   rec=rec_w,density=dens_w,/nolock,nofix1=nofix1,nofix2=nofix2,experiment=experiment,$
                   chan_prefix=chan_prefix,chan_postfix=chan_postfix
      default,autocorr_cut,-1
      default,matrix,''
      default,nofix1,0
      default,nofix2,0
			default,shot,0
      l.shot=shot
      l.filename=fn
      l.channel_mask(*)=0
      l.channel_mask(channels-1)=1
      l.trange=trange
      l.tres=tres
      l.cut_length=cut_length
      l.timefile=timefile
      l.autocorr_cut=autocorr_cut
      l.matrix=matrix
      l.data_source=data_source
      l.density_flag=rec_w
      l.simdens_flag=dens_w
      l.nofix1=nofix1
      l.nofix2=nofix2
      l.chan_prefix=chan_prefix
      l.chan_postfix=chan_postfix
      if (not keyword_set(list)) then list=l else list=[list,l]
      i=i+1
    endelse
  endwhile
end   ; j

if (keyword_set(list)) then begin
  save,list,file='zzt/'+basefile+'_lst.sav'
endif else begin
  spawn,'rm zzt/'+basefile+'_lst.sav >& nul'
endelse
end
