pro fluc_zztcorr,sht,timefile,taurange=trange_in,taures=tres,fres=fres,frange=frange,ftype=ftype,show=show,printer=printer,$
   interval_n=interval_n,lowcut=lowcut,fitorder=fitorder,baseline_function=baseline_function,$
   inttime=inttime_in,cut_length=cut_length,extrapol_length=extrapol_length,density=dens,nocalibrate=nocalibrate,$
   channels=channels,outfile=fn,errormess=errormess,comment=comment,$
   data_source=data_source,silent=silent,afs=afs,checkstop=checkstop,$
   messageproc=message_proc,backtimefile=backtimefile,nolock=nolock,zscale=zscale,ztitle=ztitle,$
   experiment=experiment,subchannel=subchannel,timerange=timerange,$
   datapath=datapath,filename=filename,chan_prefix=chan_prefix,chan_postfix=chan_postfix,$
   filter_low=filter_low,filter_high=filter_high,filter_order=filter_order
;*****************************************************************************
; Calculates space-space-time correlation function and space-space-crosspower spectra
; and saves in file <sht>.zzt.sav.<x>, where <shot> is shotnumber and
; <x> is a serial number one above the last correlation file.
; INPUT:
;   sht: Shot number (not needed for cache signals)
;   data_source: see get_rawsignal
;   timefile: Timefile for selecting processing intervals (see fluc_correlation.pro)
;   timerange: Processing time range (alternative to timefile)
;   experiment: name of expriment file (see fluc_correlation.pro)
;   subchannel: the subchannel number
;   taurange: time lag range (microsecond)
;   taures: tima lag resolution (microsecond)
;   frange: frequency range  [Hz]
;   fres: frequency resolution [Hz]
;   interval_n: minimum number of processing intervals (see fluc_correlation)
;   lowcut: low frequency cut time constant [microsec]
;   intttime: signal integration time [microsec]
;   cut_lengh, exrapol_length: autocorrelation noise peek cut parameters (see fluc_correlation)
;   fitorder: baseline correction fit order
;   baseline_function: see fluc_correlation
;   channels: list of channels (default: defchannels())
;   chan_prefix: the first part of the channel name
;   chan_postfix: the last part of the channel name. Channel name will be chan_prefix+i2str(channel[i])+channel_postfix
;   /dens: use simulated density data (for W7-AS)
;   /nocalibrate: do not calibrate signals
;   /silent: do not print messages during processing
;   /show: show ztcorr as processed
;   /printer: print ztcorr as processed
;   checkstop: name of a function to check if stop of the calculation is
;            desired by the user
;
;   backtimefile: time file for the background light (name saved in data file)
;   /nolock: do not lock resource zzt/lock
;   filename: Name of the datafile (only for 6 and 13 and for MAST test shots)
;   datapath: Path for the datafile
;   message_proc: procedure to call for showing messages (for integratioin into corr.pro)
;   zscale: the coordinate of the channels (will be written into zztfile)
;   ztitle: The title of the z coordinate. E.g. 'r [cm]'. This will be stored in the result file
;   comment: This string will be saved in the zztfile. It can be used to store additional information on the calculation
; See other parameters at ztcorr.pro and crosscor_new.pro
;***************************************************************************

fn=''
default,message_proc,'print_message'
default,data_source,fix(local_default('data_source',/silent))
default,backtimefile,''
; Setting lowcut from configuration file if none of the signals is subchannel
if (not defined(lowcut)) then begin
  if (not keyword_set(subchannel_plot) or keyword_set(subchannel_ref)) then begin
    default,lowcut,float(local_default('lowcut',/silent))
  endif
endif
default,fitorder,2
b = local_default('baseline_function',/silent)
if (b eq '') then begin
  default,baseline_function,'baseline_poly'
endif else begin
  baseline_function = b
endelse
default,nolock,1
def_chan_prefix = local_default('chan_prefix',/silent)
if (def_chan_prefix ne '') then default,chan_prefix,def_chan_prefix

if (not keyword_set(dens)) then begin
  if (not (backtimefile eq '')) then begin
    openr,unit,dir_f_name('time',backtimefile),error=error,/get_lun
    if (error ne 0) then begin
      errormess='Cannot find background time file: '+backtimefile
      call_procedure,message_proc,errormess
      outk=0
      return
    endif
    close,unit
    free_lun,unit
  endif

  forward_function lightprof
  call_procedure,message_proc,'Calculating profile...'

    if (keyword_set(experiment)) then begin
      exp = load_experiment(experiment,/silent,errormess=errormess)
       if (errormess ne '') then begin
         if (not keyword_set(silent)) then print,errormess
      return
       endif
      shot_prof = lonarr(n_elements(exp))
       timefile_prof = strarr(n_elements(exp))
       for i=0,n_elements(exp)-1 do begin
         shot_prof(i) = exp[i].shot
         timefile_prof(i) = exp[i].timefile
       endfor
    endif else begin
      shot_prof = sht
       if (keyword_set(timefile)) then timefile_prof=timefile
    endelse

  profile=lightprof(shot_prof,timefile_prof,timerange=timerange,channels=channels,nocalibrate=nocal,$
                    data_source=data_source,afs=afs,/silent,errormess=errormess,calfac=calfac,subchannel=subchannel,$
           datapath=datapath,filename=filename,chan_prefix=chan_prefix,chan_postfix=chan_postfix)
  if ((size(profile))(0) eq 0) then begin
    call_procedure,message_proc,'Error calculating light profile:'
    call_procedure,message_proc,errormess
    outk=0
    return
  endif
  call_procedure,message_proc,'...done'

  if (not defined(zscale)) then begin
    corr_zscale,sht,channels,data_source=data_source,chan_prefix=chan_prefix,chan_postfix=chan_postfix,zscale=zscale,ztitle=ztitle,$
       errormess=errormess
    if (errormess ne '') then begin
      call_procedure,message_proc,errormess
      outk=0
      return
    endif
  endif

  if (not (backtimefile eq '') or keyword_set(experiment)) then begin
    call_procedure,message_proc,'Calculating background light profile...'

       if (keyword_set(experiment)) then begin
         shot_prof = lonarr(n_elements(exp))
         timefile_prof = strarr(n_elements(exp))
         for i=0,n_elements(exp)-1 do begin
           shot_prof(i) = exp[i].backshot
          timefile_prof(i) = exp[i].backtimefile
         endfor
       endif else begin
         shot_prof = sht
         if (keyword_set(backtimefile)) then timefile_prof=backtimefile
       endelse

    backgr_profile=lightprof(shot_prof,timefile_prof,channels=channels,nocalibrate=nocal,$
                      data_source=data_source,afs=afs,/silent,errormess=errormess,calfac=calfac,subchannel=subchannel,$
                      datapath=datapath,filename=filename,chan_prefix=chan_prefix,chan_postfix=chan_postfix)
    if ((size(profile))(0) eq 0) then begin
      call_procedure,message_proc,'Error calculating background light profile:'
      call_procedure,message_proc,errormess
      outk=0
      return
    endif
    call_procedure,message_proc,'...done'
  endif
endif  ; not keyword_set(dens)


fn=''
errormess=''

if (keyword_set(dens)) then begin
  simparafile='data/'+i2str(sht,digits=5)+'.simpara'
  openr,unit,simparafile,error=error,/get_lun
  if (error ne 0) then begin
    print,'Cannot find simulation parameter file '+simparafile
    return
  endif
  close,unit
  free_lun,unit
  if (keyword_set(channels)) then channels_save=channels
  shot_sim=0 & mode=0 & matrix=0 & z_vect=0 & p0r=0 & n0=0 & channels=0 & max_photon=0 & inttime=0 & trange=0
  sampletime=0 & multi=0 & decay=0 & ampmax=0 & period=0 & width=0 & output_sampletime=0
  flucprof=0 & dens_avr=0 & dens_flucprof=0 & nophoton=0 & background=0 & background_time=0 & startz=0
  endz=0
    restore,simparafile
  if (keyword_set(channels_save)) then channels=channels_save else channels=findgen(n_elements(z_vect))+1
endif else begin
    if (not defined(channels)) then channels=defchannels(sht,data_source=data_source)
endelse
chn=n_elements(channels)

if ((data_source le 1) or keyword_set(dens)) then begin
  default,trange_in,[-400,400]
  default,tres,11
  if (keyword_set(dens)) then default,cut_length,0 else default,cut_length,5
endif
if (data_source eq 2) then begin
  default,trange_in,[-1000,1000]
  default,tres,200
  default,cut_length,0
endif
default,trange_in,[-1000,1000]
trange=trange_in

if (not keyword_set(experiment)) then begin
  if (keyword_set(timefile)) then tf=timefile $
     else tf='['+string(timerange[0],format='(F7.4)')+','+string(timerange[1],format='(F7.4)')+']'
    default,tf,timefile
    call_procedure,message_proc,'++++++ ZZTCORR.PRO  shot:'+i2str(sht)+'  time:'+tf+' +++++++'
endif else begin
    call_procedure,message_proc,'++++++ ZZTCORR.PRO  experiment:'+experiment
endelse


for ii=0,chn-1 do begin
  if (keyword_set(checkstop)) then begin
    if (call_function(checkstop) ne 0) then return
  endif
  if (is_string(channels)) then ch_string = channels(ii) else ch_string = i2str(channels(ii))
  call_procedure,message_proc,'Reference channel: '+ch_string
  fluc_ztcorr,sht,timefile,refch=channels(ii),data_source=data_source,$
     outtime=outtime,outz=outz,outcorr=outk,outscat=outkscat,$
     outfscale=outfscale,outpower=outpower,outpwscat=outpwscat,outphase=outphase,taures=tres,$
     taurange=trange,fres=fres,frange=frange,ftype=ftype,cut_length=cut_length,norm=0,/noplot,show=show,printer=printer,$
     density=dens,inttime=inttime_in,/fft,lowcut=lowcut,fitorder=fitorder,$
     baseline_function=baseline_function,interval_n=interval_n,$
     channels=channels,dens_tvec=dens_tvec,dens_sampletime=dens_sampletime,$
     errormess=errormess,silent=silent,afs=afs,checkstop=checkstop,messageproc=message_proc,$
     proct1=proct1,proct2=proct2,procn=procn,calfac=calfac,nocalibrate=nocalibrate,$
     experiment=experiment,subchannel=subchannel,timerange=timerange,datapath=datapath,filename=filename,$
     chan_prefix=chan_prefix,chan_postfix=chan_postfix,filter_low=filter_low,filter_high=filter_high,filter_order=filter_order
     if (((size(outk))(0) eq 0) or (errormess ne '')) then return
      if (ii eq 0) then begin
         k=fltarr(chn,chn,n_elements(outtime))
         kscat=fltarr(chn,chn,n_elements(outtime))
         outpower3 = fltarr(chn,chn,n_elements(outfscale))
         outpwscat3 = fltarr(chn,chn,n_elements(outfscale))
         outphase3 = fltarr(chn,chn,n_elements(outfscale))
       endif
       k[ii,*,*]=transpose(outk)
       kscat[ii,*,*]=transpose(outkscat)
       outpower3[ii,*,*]=transpose(outpower)
       outphase3[ii,*,*]=transpose(outphase)
       outpwscat3[ii,*,*]=transpose(outpwscat)
endfor

z=zscale
t=outtime

if (not keyword_set(nolock)) then lock,dir_f_name('zzt','lock'),60

i=0
found=1
if (not keyword_set(experiment)) then begin
    if (not keyword_set(dens)) then begin
      f=i2str(sht,digits=5)+'.zzt.sav'
    endif else begin
      f=i2str(sht,digits=5)+'.zzt_ne_sim.sav'
    endelse
endif else begin
  f=experiment+'.zzt.sav'
endelse
while (found) do begin
  fn=f+'.'+i2str(i)
  openr,unit,dir_f_name('zzt',fn),error=error,/get_lun
  if (error ne 0) then begin
    found=0
  endif else begin
    close,unit
    free_lun,unit
  endelse
i=i+1
endwhile
shot=sht
f=outfscale

default,timefile,''
default,calfac,0
default,backtimefile,''
default,backgr_profile,0
default,profile,0
default,experiment,''
default,exp,0
default,subchannel,0
default,timerange,0
default,comment,''

store_freq = 1;  For compatibility with old files
save,k,kscat,z,t,outpower3,outpwscat3,outphase3,outfscale,channels,timefile,fres,frange,ftype,tres,trange,cut_length,shot,fitorder,baseline_function,lowcut,$
     data_source,f,store_freq,profile,backgr_profile,calfac,backtimefile,experiment,interval_n,$
     proct1,proct2,procn,exp,timerange,subchannel,chan_prefix,chan_postfix,ztitle,comment,file=dir_f_name('zzt',fn),filter_low,filter_high,filter_order
update_corr_list,shot,file=fn,channels=channels,trange=trange,tres=tres,$
   cut_length=cut_length,timefile=timefile,data_source=data_source,dens=dens,experiment=experiment


if (not keyword_set(nolock)) then unlock,dir_f_name('zzt','lock')

end
