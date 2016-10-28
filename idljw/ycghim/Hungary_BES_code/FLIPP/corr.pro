
pro get_ranges
; Reads the plot ranges from the widgets in plot control window
; and saves them in internal vaiables
@corr_common.pro
default,shot,50400
;    beam_coordinates,shot,beam_RR,beam_ZZ,xrr,data_source=data_source_com

ptype=prev_index
case ptype of
  0: begin  ; z-t
       widget_control,plot_refz1_widg,get_value=zt_z0
       if (act_options(5) eq 1) then  begin
         zt_z0=zscale(closeind(zscale,zt_z0))
         widget_control,plot_refz1_widg,set_value=zt_z0
       endif
       widget_control,z2range1_widg,get_value=w
       zt_zrange(0)=w
       widget_control,z2range2_widg,get_value=w
       zt_zrange(1)=w
       widget_control,trange1_widg,get_value=w
       zt_trange(0)=w
       widget_control,trange2_widg,get_value=w
       zt_trange(1)=w
     end
  1: begin  ; z-z
       widget_control,plot_reft_widg,get_value=zz_t0
       widget_control,z1range1_widg,get_value=w
       zz_z0range(0)=w
       widget_control,z1range2_widg,get_value=w
       zz_z0range(1)=w
       widget_control,z2range1_widg,get_value=w
       zz_z1range(0)=w
       widget_control,z2range2_widg,get_value=w
       zz_z1range(1)=w
     end
  2: begin  ; z
       widget_control,plot_refz1_widg,get_value=z_z0
       if (act_options(5) eq 1) then  begin
         z_z0=zscale(closeind(zscale,z_z0))
         widget_control,plot_refz1_widg,set_value=z_z0
       endif
       widget_control,plot_reft_widg,get_value=z_t0
       widget_control,z2range1_widg,get_value=w
       z_zrange(0)=w
       widget_control,z2range2_widg,get_value=w
       z_zrange(1)=w
     end
  3: begin  ; t
       widget_control,plot_refz1_widg,get_value=t_z0
       widget_control,plot_refz2_widg,get_value=t_z1
       if (act_options(5) eq 1) then  begin
         t_z0=zscale(closeind(zscale,t_z0))
         t_z1=zscale(closeind(zscale,t_z1))
         widget_control,plot_refz1_widg,set_value=t_z0
         widget_control,plot_refz2_widg,set_value=t_z1
       endif
       widget_control,trange1_widg,get_value=w
       t_trange(0)=w
       widget_control,trange2_widg,get_value=w
       t_trange(1)=w
     end
  4: begin  ; auto
       widget_control,plot_refz1_widg,get_value=auto_z0
       if (act_options(5) eq 1) then begin
         auto_z0=zscale(closeind(zscale,auto_z0))
         widget_control,plot_refz1_widg,set_value=auto_z0
       endif
       widget_control,trange1_widg,get_value=w
       auto_trange(0)=w
       widget_control,trange2_widg,get_value=w
       auto_trange(1)=w
     end
  5: begin  ; multi-auto
       widget_control,trange1_widg,get_value=w
       mauto_trange(0)=w
       widget_control,trange2_widg,get_value=w
       mauto_trange(1)=w
     end
  6: begin  ; times
       widget_control,plot_refz1_widg,get_value=times_z0
       widget_control,trange1_widg,get_value=w
       times_trange(0)=w
       widget_control,trange2_widg,get_value=w
       times_trange(1)=w
     end
  7: begin ; crosspower
       widget_control,plot_refz1_widg,get_value=cross_z1
       widget_control,plot_refz2_widg,get_value=cross_z2
       if (act_options(5) eq 1) then begin
         cross_z1=zscale(closeind(zscale,cross_z1))
         cross_z2=zscale(closeind(zscale,cross_z2))
         widget_control,plot_refz1_widg,set_value=cross_z1
         widget_control,plot_refz2_widg,set_value=cross_z2
       endif
       widget_control,trange1_widg,get_value=w
       cross_frange(0)=w
       widget_control,trange2_widg,get_value=w
       cross_frange(1)=w
     end
  8: begin ; autopower
       widget_control,plot_refz1_widg,get_value=autopow_z
       if (act_options(5) eq 1) then begin
         autopow_z=zscale(closeind(zscale,autopow_z))
         widget_control,plot_refz1_widg,set_value=autopow_z
       endif
       widget_control,trange1_widg,get_value=w
       autopow_frange(0)=w
       widget_control,trange2_widg,get_value=w
       autopow_frange(1)=w
     end
  9: begin  ; matrix para
       widget_control,z1range1_widg,get_value=w
       mat_zrange(0)=w
       widget_control,z1range2_widg,get_value=w
       mat_zrange(1)=w
     end
  10: begin  ; raw signal
       widget_control,plot_refz1_widg,get_value=times_z0
       widget_control,trange1_widg,get_value=w
       times_trange(0)=w
       widget_control,trange2_widg,get_value=w
       times_trange(1)=w
     end
  11: begin  ; power vs Z
       widget_control,trange1_widg,get_value=w
       power_trange(0)=w
       widget_control,trange2_widg,get_value=w
       power_trange(1)=w
       widget_control,z2range1_widg,get_value=w
       power_zrange(0)=w
       widget_control,z2range2_widg,get_value=w
       power_zrange(1)=w
     end
  12: begin  ; corr. time  vs Z
       widget_control,z2range1_widg,get_value=w
       ctime_zrange(0)=w
       widget_control,z2range2_widg,get_value=w
       ctime_zrange(1)=w
     end
  13: begin  ; ELM monitor
       widget_control,trange1_widg,get_value=w
       ELM_trange(0)=w
       widget_control,trange2_widg,get_value=w
       ELM_trange(1)=w
       widget_control,z2range1_widg,get_value=w
       ELM_zrange(0)=w
       widget_control,z2range2_widg,get_value=w
       ELM_zrange(1)=w
     end
  14: begin  ; profiles
       widget_control,z2range1_widg,get_value=w
       profiles_zrange(0)=w
       widget_control,z2range2_widg,get_value=w
       profiles_zrange(1)=w
     end
  15: begin  ; compare profiles
       widget_control,z2range1_widg,get_value=w
       profiles_zrange(0)=w
       widget_control,z2range2_widg,get_value=w
       profiles_zrange(1)=w
     end
  else: begin
     end
endcase
ranges_sens=1
end

pro ranges_on
@corr_common.pro
ptype=prev_index
case ptype of
  0: begin  ; z-t
       widget_control,plot_refz1_widg,sensitive=1,set_value=zt_z0
       widget_control,refz1_up_widg,sensitive=1
       widget_control,refz1_down_widg,sensitive=1
       widget_control,z2range1_widg,sensitive=1,set_value=zt_zrange(0)
       widget_control,z2range2_widg,sensitive=1,set_value=zt_zrange(1)
       widget_control,trange1_widg,sensitive=1,set_value=zt_trange(0)
       widget_control,trange2_widg,sensitive=1,set_value=zt_trange(1)
       widget_control,t_label_widg,set_value=' tau:'
     end
  1: begin  ; z-z
       widget_control,plot_reft_widg,sensitive=1,set_value=zz_t0
       widget_control,z1range1_widg,sensitive=1,set_value=zz_z0range(0)
       widget_control,z1range2_widg,sensitive=1,set_value=zz_z0range(1)
       widget_control,z2range1_widg,sensitive=1,set_value=zz_z1range(0)
       widget_control,z2range2_widg,sensitive=1,set_value=zz_z1range(1)
       widget_control,t_label_widg,set_value=' tau:'
     end
  2: begin  ; z
       widget_control,plot_refz1_widg,sensitive=1,set_value=z_z0
       widget_control,refz1_up_widg,sensitive=1
       widget_control,refz1_down_widg,sensitive=1
       widget_control,plot_reft_widg,sensitive=1,set_value=z_t0
       widget_control,z2range1_widg,sensitive=1,set_value=z_zrange(0)
       widget_control,z2range2_widg,sensitive=1,set_value=z_zrange(1)
       widget_control,t_label_widg,set_value=' tau:'
     end
  3: begin  ; t
       widget_control,plot_refz1_widg,sensitive=1,set_value=t_z0
       widget_control,refz1_up_widg,sensitive=1
       widget_control,refz1_down_widg,sensitive=1
       widget_control,plot_refz2_widg,sensitive=1,set_value=t_z1
       widget_control,trange1_widg,sensitive=1,set_value=t_trange(0)
       widget_control,trange2_widg,sensitive=1,set_value=t_trange(1)
       widget_control,t_label_widg,set_value=' tau:'
     end
  4: begin  ; auto
       widget_control,plot_refz1_widg,sensitive=1,set_value=auto_z0
       widget_control,refz1_up_widg,sensitive=1
       widget_control,refz1_down_widg,sensitive=1
       widget_control,trange1_widg,sensitive=1,set_value=auto_trange(0)
       widget_control,trange2_widg,sensitive=1,set_value=auto_trange(1)
       widget_control,t_label_widg,set_value=' tau:'
     end
  5: begin  ; multi-auto
       widget_control,trange1_widg,sensitive=1,set_value=mauto_trange(0)
       widget_control,trange2_widg,sensitive=1,set_value=mauto_trange(1)
       widget_control,t_label_widg,set_value=' tau:'
     end
  6: begin  ; times
       widget_control,plot_refz1_widg,sensitive=1,set_value=times_z0
       widget_control,refz1_up_widg,sensitive=1
       widget_control,refz1_down_widg,sensitive=1
       widget_control,trange1_widg,sensitive=1,set_value=times_trange(0)
       widget_control,trange2_widg,sensitive=1,set_value=times_trange(1)
       widget_control,t_label_widg,set_value='time:'
     end
  7: begin  ; crosspower
       widget_control,plot_refz1_widg,sensitive=1,set_value=cross_z1
       widget_control,refz1_up_widg,sensitive=1
       widget_control,refz1_down_widg,sensitive=1
       widget_control,plot_refz2_widg,sensitive=1,set_value=cross_z2
       widget_control,trange1_widg,sensitive=1,set_value=cross_frange(0)
       widget_control,trange2_widg,sensitive=1,set_value=cross_frange(1)
       widget_control,t_label_widg,set_value='freq:'
     end
  8: begin  ; autopower
       widget_control,plot_refz1_widg,sensitive=1,set_value=autopow_z
       widget_control,refz1_up_widg,sensitive=1
       widget_control,refz1_down_widg,sensitive=1
       widget_control,trange1_widg,sensitive=1,set_value=autopow_frange(0)
       widget_control,trange2_widg,sensitive=1,set_value=autopow_frange(1)
       widget_control,t_label_widg,set_value='freq:'
     end
  9: begin  ; mat para
       widget_control,z1range1_widg,sensitive=1,set_value=mat_zrange(0)
       widget_control,z1range2_widg,sensitive=1,set_value=mat_zrange(1)
       widget_control,t_label_widg,set_value=' tau:'
     end
  10: begin  ; raw signal
       widget_control,plot_refz1_widg,sensitive=1,set_value=times_z0
       widget_control,refz1_up_widg,sensitive=1
       widget_control,refz1_down_widg,sensitive=1
       widget_control,trange1_widg,sensitive=1,set_value=times_trange(0)
       widget_control,trange2_widg,sensitive=1,set_value=times_trange(1)
       widget_control,t_label_widg,set_value='time:'
     end
  11: begin  ; power vs Z
       widget_control,trange1_widg,sensitive=1,set_value=power_trange(0)
       widget_control,trange2_widg,sensitive=1,set_value=power_trange(1)
       widget_control,z2range1_widg,sensitive=1,set_value=power_zrange(0)
       widget_control,z2range2_widg,sensitive=1,set_value=power_zrange(1)
       widget_control,t_label_widg,set_value=' tau:'
     end
  12: begin  ; corr. time vs Z
       widget_control,z2range1_widg,sensitive=1,set_value=ctime_zrange(0)
       widget_control,z2range2_widg,sensitive=1,set_value=ctime_zrange(1)
       widget_control,t_label_widg,set_value=' tau:'
     end
  13: begin  ; ELM monitor
       widget_control,trange1_widg,sensitive=1,set_value=ELM_trange(0)
       widget_control,trange2_widg,sensitive=1,set_value=ELM_trange(1)
       widget_control,z2range1_widg,sensitive=1,set_value=ELM_zrange(0)
       widget_control,z2range2_widg,sensitive=1,set_value=ELM_zrange(1)
       widget_control,t_label_widg,set_value=' tau:'
     end
  14: begin  ; profiles
       widget_control,z2range1_widg,sensitive=1,set_value=profiles_zrange(0)
       widget_control,z2range2_widg,sensitive=1,set_value=profiles_zrange(1)
       widget_control,t_label_widg,set_value=' tau:'
     end
  15: begin  ; compare profiles
       widget_control,z2range1_widg,sensitive=1,set_value=profiles_zrange(0)
       widget_control,z2range2_widg,sensitive=1,set_value=profiles_zrange(1)
       widget_control,t_label_widg,set_value=' tau:'
     end
  else: begin
     end
endcase
ranges_sens=1
end

pro ranges_off
@corr_common.pro
widget_control,plot_refz1_widg,sensitive=0,set_value=''
widget_control,refz1_up_widg,sensitive=0
widget_control,refz1_down_widg,sensitive=0
widget_control,plot_refz2_widg,sensitive=0,set_value=''
widget_control,plot_reft_widg,sensitive=0,set_value=''
widget_control,z1range1_widg,sensitive=0,set_value=''
widget_control,z1range2_widg,sensitive=0,set_value=''
widget_control,z2range1_widg,sensitive=0,set_value=''
widget_control,z2range2_widg,sensitive=0,set_value=''
widget_control,trange1_widg,sensitive=0,set_value=''
widget_control,trange2_widg,sensitive=0,set_value=''
ranges_sens=0
end

pro corrplot,file=file,printer=printer
; ***************************************************
; * pro CORRPLOT
; ***************************************************
@corr_common.pro
widget_control,load_opt_widg,get_value=load_opt
nolock=(load_opt(0) eq 0)
ptype=prev_index
widget_control,data_val_widg,get_value=dtype
get_ranges
widget_control,corr_widg,/hourglass
if ((ptype ge 7) and (ptype le 8)) then begin
  if (dtype ne 0) then begin
    corr_message,'Power spectrum plots are available only for light.',/forward
    return
  endif
endif
; compare profiles
if (ptype eq 15) then begin
  if (compfilename eq '') then return
  if (act_options(0) eq 0) then nolegend=1 else nolegend=0
  if (coltype lt 2) then color=1 else color=0
  if (act_options(3) eq 0) then noerror=1
  if (plot_tit_widg ne 0) then begin
    widget_control,plot_tit_widg,get_value=title
    title=title(0)
  endif
  if (act_options(2) eq 1) then begin
    widget_control,lcfs_sw_widg,get_value=lcfs_type
    if (lcfs_type eq 1) then begin
      lcfs=1
    endif else begin
      widget_control,lcfs_val_widg,get_value=lcfs
    endelse
  endif
  if (keyword_set(file) or keyword_set(printer)) then begin
    hardon,/color
  endif
  show_compare,from_file=compfilename,nolegend=nolegend,$
      zrange=profiles_zrange,title=title,lcfs=lcfs,noerror=noerror,axisthick=axthick,$
      linethick=linethick,charsize=chsize,color=color,nolock=nolock
  if (keyword_set(file)) then hardfile,file
  if (keyword_set(printer)) then hardoff,printer
  return
endif
if ((ptype eq 6) or (ptype eq 10)) then begin  ; times or raw signal plot
  widget_control,shot_widg,get_value=shot
  if (shot eq 0) then begin
    corr_message,'No shot number defined.',/forward
    return
  endif

;    beam_coordinates,shot,beam_RR,beam_ZZ,xrr,data_source=data_source_com

  chlist=defchannels(shot,data_source=data_source_com)
  ch=chlist(closeind(zscale(chlist-1),times_z0))
  on_error,3
  catch,errstat
  if (errstat ne 0) then goto,err_times
  if (act_options(0) eq 0) then nolegend=1 else nolegend=0
  if (coltype lt 2) then color=1 else color=0
  if (keyword_set(file) or keyword_set(printer)) then begin
    hardon,/color
;    if (color) then hardon,/color else hardon
  endif
  if (not ((times_trange(0) eq 0) and (times_trange(1) eq 0))) then trange=times_trange
  if (ptype eq 6) then begin
    show_times,shot,ch,errorproc='corr_message',nolegend=nolegend,color=color,$
              data_source=data_source_com,afs=data_place_com,trange=trange
  endif else begin
    ch_str = ch
    get_rawsignal,shot,ch_str,data_source=data_source_com,afs=data_place_com,/nodata
    show_rawsignal,shot,ch_str,errorproc='corr_message',nolegend=nolegend,$
              data_source=data_source_com,afs=data_place_com,trange=trange
  endelse
  if (keyword_set(file)) then hardfile,file
  if (keyword_set(printer)) then hardoff,printer
  return
err_times:
   corr_message,!err_string,/forward
   on_ioerror,NULL
   return
end
if (ptype eq 9) then begin  ; mat para plot
  widget_control,matfile_widg,get_value=mfile
  mfile=mfile(0)
  if (mfile eq '') then begin
    corr_message,'Must specify matrix file name first!',/forward
    return
  endif
  if (act_options(0) eq 0) then nolegend=1 else nolegend=0
  if (act_options(4) eq 1) then nopara=0 else nopara=1
  if (plot_tit_widg ne 0) then begin
    widget_control,plot_tit_widg,get_value=title
    title=title(0)
  endif
  if (act_options(2) eq 1) then begin
    widget_control,lcfs_sw_widg,get_value=lcfs_type
    if (lcfs_type eq 1) then begin
      lcfs=1
    endif else begin
      widget_control,lcfs_val_widg,get_value=lcfs
    endelse
  endif
  if (coltype lt 2) then color=1 else color=0
  if (not ((mat_zrange(0) eq 0) and (mat_zrange(1) eq 0))) then zr=mat_zrange
  if (keyword_set(file) or keyword_set(printer)) then begin
    hardon
  endif
  show_matpara,mfile,errorproc='corr_message',lcfs=lcfs,nolegend=nolegend,zrange=zr,$
    title=title,nopara=nopara,color=color
  if (keyword_set(file)) then hardfile,file
  if (keyword_set(printer)) then hardoff,printer
  return
end


widget_control,data_val_widg,get_value=dtype
widget_control,norm_widg,get_value=norm
widget_control,lfile_widg,get_value=lfile
if (((dtype eq 0) and not lfile_OK) or $
    ((dtype eq 1) and not dfile_OK) or $
    ((dtype eq 2) and not lfile_OK and not dfile_OK)) then begin
  corr_message,'Must load data file first! After filling in fields press ENTER.',/forward
  return
endif

if ((dtype eq 2) and not lfile_OK) then begin
  dtype=1
  widget_control,data_val_widg,set_value=dtype
endif
if ((dtype eq 2) and not dfile_OK) then begin
  dtype=0
  widget_control,data_val_widg,set_value=dtype
endif

lfile=lfile(0)
if ((dtype eq 0) or (dtype eq 2)) then begin
  widget_control,load_opt_widg,get_value=load_opt
  nolock=(load_opt(0) eq 0)
  load_zztcorr,shot,k,ks,z,t,freq,pow,pows,file=lfile,channels=channels,/silent,$
    data_source=dsource,para_txt=para_txt,nolock=nolock,ztitle=ztitle
  if ((size(k))(0) ne 3) then begin
    corr_message,'Cannot open file:'+lfile,forward=0
    widget_control,lfile_widg,set_value='',sensitive=0
    return
  endif
  ; Save the z scale, will be used for stepping the ref position
   zscale = z
  if ( (((where(ptype eq [0,1,2,3,4,5]))(0) ne -1) and (norm eq 1))) then begin
    norm_k,k,ks,z,t,errormess=errormess
    if (errormess ne '') then begin
      corr_message,errormess,/forward
      return
    endif
    para_txt=para_txt+'!Cnormalized'
  endif
endif
widget_control,dfile_widg,get_value=dfile
dfile=dfile(0)
if ((dtype eq 1) or (dtype eq 2)) then begin
  widget_control,load_opt_widg,get_value=load_opt
  nolock=(load_opt(0) eq 0)
  load_zztcorr,shot,k,ks,z,t,freq,pow,pows,file=dfile,/rec,/silent,data_source=dsource,$
   para_txt=para_txt,nolock=nolock,ztitle=ztitle
  if ((size(k))(0) ne 3) then begin
    corr_message,'Cannot open file:'+dfile
    widget_control,dfile_widg,set_value='',sensitive=0
    return
  endif
  ; Save the z scale, will be used for stepping the ref position
  zscale = z

  if ( (((where(ptype eq [0,1,2,3,4,5]))(0) ne -1) and (norm eq 1))) then begin
    norm_k,k,ks,z,t,errormess=errormess
    if (errormess ne '') then begin
      corr_message,errormess,/forward
      return
    endif
    para_txt=para_txt+'!Cnormalized'
  endif
endif
if ((ptype ge 7) and (ptype le 8)) then begin
  if (not keyword_set(freq)) then begin
    corr_message,'No power spectrum data is found in file :'+lfile,/forward
    return
  endif
endif
if (act_options(0) eq 0) then nolegend=1 else nolegend=0
if (act_options(3) eq 0) then noerror=1
if (act_options(4) eq 1) then nopara=0 else nopara=1
if (act_options(1) eq 1) then pluslevels=1 else pluslevels=0
if (act_options(6) eq 1) then over=1 else over=0
if (act_options(7) eq 1) then reffscale=5 else reffscale=0
if (plot_tit_widg ne 0) then begin
  widget_control,plot_tit_widg,get_value=title
  title=title(0)
endif else begin
  title=''
endelse
if (act_options(2) eq 1) then begin
  widget_control,lcfs_sw_widg,get_value=lcfs_type
  if (lcfs_type eq 1) then begin
    lcfs=get_lcfs(shot)
    if (lcfs eq 0) then corr_message,'Cannot get LCFS value for shot '+i2str(shot)
  endif else begin
    widget_control,lcfs_val_widg,get_value=lcfs
  endelse
endif
if (act_options(3) eq 1) then noerr=0 else noerr=1
if (plot_nlev_widg ne 0) then begin
  widget_control,plot_nlev_widg,get_value=nlev
endif
if ((plot_range1_widg ne 0) and (plot_range2_widg ne 0)) then begin
  widget_control,plot_range1_widg,get_value=w1
  widget_control,plot_range2_widg,get_value=w2
  if ((w1 ne 0) or (w2 ne 0)) then plotrange=[w1,w2]
endif
if (plot_lthick_widg ne 0) then begin
  widget_control,plot_lthick_widg,get_value=linethick
endif
if (plot_athick_widg ne 0) then begin
  widget_control,plot_athick_widg,get_value=axthick
endif
if (plot_csize_widg ne 0) then begin
  widget_control,plot_csize_widg,get_value=chsize
endif

if (keyword_set(file) or keyword_set(printer)) then begin
;  if ((coltype lt 2) and (ptype lt 2)) then hardon,/color else hardon
  hardon,/color
endif


if (dtype le 1) then begin
  ; z-t plot
  if (ptype eq 0) then begin
    show_ztcorr,k,ks,z,t,refz=zt_z0,colorscheme=c_scheme_list(coltype),$
                nolegend=nolegend,pluslevels=pluslevels,zrange=zt_zrange,$
                trange=zt_trange,lcfs=lcfs,title=title,para_txt=para_txt,$
                nopara=nopara,nlev=nlev,plotrange=plotrange,axisthick=axthick,$
                linethick=linethick,charsize=chsize,ytitle=ztitle
  endif

  ; z-z plot
  if (ptype eq 1) then begin
    if ((size(where(t eq zz_t0)))(0) eq 0) then begin
      ind=closeind(t,zz_t0)
      zz_t0=t(ind)
    endif
    widget_control,plot_reft_widg,set_value=zz_t0
    show_zzcorr,k,ks,z,t,t0=zz_t0,colorscheme=c_scheme_list(coltype),$
                nolegend=nolegend,pluslevels=pluslevels,z1range=zz_z0range,$
                z2range=zz_z1range,lcfs=lcfs,title=title,para_txt=para_txt,$
                nopara=nopara,nlev=nlev,plotrange=plotrange,ytitle=ztitle
  endif

  ; z plot
  if (ptype eq 2) then begin
    if ((size(where(t eq z_t0)))(0) eq 0) then begin
      ind=closeind(t,z_t0)
      z_t0=t(ind)
    endif
    widget_control,plot_reft_widg,set_value=z_t0
    show_zcorr,k,ks,z,t,t0=z_t0,refz=z_z0,nolegend=nolegend,zrange=z_zrange,title=title,$
     para_txt=para_txt,nopara=nopara,yrange=plotrange,over=over,lcfs=lcfs,axisthick=axthick,$
     linethick=linethick,charsize=chsize
  endif

  ; t plot
  if (ptype eq 3) then begin
    show_tcorr,k,ks,z,t,refz=t_z0,plotz=t_z1,nolegend=nolegend,trange=t_trange,title=title,$
            noerr=noerr,para_txt=para_txt,nopara=nopara,yrange=plotrange,over=over,axisthick=axthick,$
            linethick=linethick,charsize=chsize
  endif

  ; autocorr
  if (ptype eq 4) then begin
    show_tcorr,k,ks,z,t,refz=auto_z0,plotz=auto_z0,nolegend=nolegend,trange=auto_trange,title=title,$
                    noerr=noerr,para_txt=para_txt,nopara=nopara,yrange=plotrange,over=over,axisthick=axthick,$
            linethick=linethick,charsize=chsize
  endif

  ; multi-autocorr plot
  if (ptype eq 5) then begin
    errormess=''
    if (dtype eq 0) then begin
      auto_plot,shot,file=lfile,channels=channels,nolegend=nolegend,trange=mauto_trange,$
          noerr=noerr,norm=norm,errormess=errormess,nopara=nopara,title=title,yrange=plotrange,nolock=nolock
    endif else begin
      auto_plot,shot,file=dfile,/rec,nolegend=nolegend,trange=mauto_trange,noerr=noerr,$
      norm=norm,errormess=errormess,nopara=nopara,title=title,yrange=plotrange,nolock=nolock
    endelse
    if (errormess ne '') then corr_message,errormess,/forward
  endif

  ; crosspower
  if (ptype eq 7) then begin
    show_crosspower,pow,pows,z,freq,title=title,nolegend=nolegend,$
      refz=cross_z1,plotz=cross_z2,para_txt=para_txt,nopara=nopara,frange=cross_frange
  endif

  ; autopower
  if (ptype eq 8) then begin
    show_crosspower,pow,pows,z,freq,title=title,nolegend=nolegend,$
      refz=autopow_z,plotz=autopow_z,para_txt=para_txt,nopara=nopara,frange=autopow_frange
  endif

  ; power vs Z
  if (ptype eq 11) then begin
    show_power,k,ks,z,t,trange=power_trange,nolegend=nolegend,zrange=power_zrange,title=title,$
     para_txt=para_txt,nopara=nopara,yrange=plotrange,lcfs=lcfs,over=over,noerror=noerror
  endif

  ; corr. time  vs Z
  if (ptype eq 12) then begin
    show_cortime,k,ks,z,t,nolegend=nolegend,zrange=ctime_zrange,title=title,$
     para_txt=para_txt,nopara=nopara,yrange=plotrange,lcfs=lcfs,over=over,noerror=noerror
  endif

  ; ELM monitor vs Z
  if (ptype eq 13) then begin
    show_elm,k,ks,z,t,fitrange=ELM_trange,nolegend=nolegend,zrange=ELM_zrange,title=title,$
     para_txt=para_txt,nopara=nopara,yrange=plotrange,lcfs=lcfs,over=over,noerror=noerror
  endif

  ; profiles
  if (ptype eq 14) then begin
    if (dtype eq 0) then begin
      show_profiles,lfile,nolegend=nolegend,zrange=profiles_zrange,title=title,$
        nopara=nopara,lcfs=lcfs,noerror=noerror,axisthick=axthick,$
        linethick=linethick,charsize=chsize,nolock=nolock
    endif else begin
      show_densprof,dfile,nolegend=nolegend,zrange=profiles_zrange,title=title,$
        nopara=nopara,lcfs=lcfs,noerror=noerror,axisthick=axthick,$
        linethick=linethick,charsize=chsize,errorproc='corr_message',nolock=nolock,$
        reffscale=reffscale
    endelse
  endif


endif else begin
  ; z-t plot
  if (ptype eq 0) then begin
    show_ztcorr_3,light=shot,file_light=lfile,file_dens=dfile,/nosim,refz=zt_z0,$
                  colorscheme=c_scheme_list(coltype),$
                  nolegend=nolegend,pluslevels=pluslevels,trange=zt_trange,$
                  zrange=zt_zrange,nlev=nlev
  endif

  ; z-z plot
  if (ptype eq 1) then begin
    widget_control,load_opt_widg,get_value=load_opt
    nolock=(load_opt(0) eq 0)
    load_zztcorr,shot,k,ks,z,t,file=lfile,/silent,nolock=nolock,ztitle=ztitle
    if ((size(where(t eq zz_t0)))(0) eq 0) then begin
      ind=closeind(t,zz_t0)
      zz_t0=t(ind)
    endif
    ; Save the z scale, will be used for stepping the ref position
    zscale = z
    load_zztcorr,shot,k,ks,z,t,/rec,file=dfile,/silent,nolock=nolock,ztitle=ztitle
    if ((size(where(t eq zz_t0)))(0) eq 0) then begin
      ind=closeind(t,zz_t0)
      zz_t0=t(ind)
    endif
    widget_control,plot_reft_widg,set_value=zz_t0
    show_zzcorr_3,light=shot,/nosim,t0=zz_t0,colorscheme=c_scheme_list(coltype),$
                 nolegend=nolegend,pluslevels=pluslevels,file_light=lfile,$
                 file_dens=dfile,z1range=zz_z0range,z2range=zz_z1range,nlev=nlev
  endif

  ; z plot
  if (ptype eq 2) then begin
    widget_control,load_opt_widg,get_value=load_opt
    nolock=(load_opt(0) eq 0)
    load_zztcorr,shot,k,ks,z,t,file=lfile,/silent,nolock=nolock,ztitle=ztitle
    if ((size(where(t eq z_t0)))(0) eq 0) then begin
      ind=closeind(t,z_t0)
      z_t0=t(ind)
    endif
    ; Save the z scale, will be used for stepping the ref position
    zscale = z
    load_zztcorr,shot,k,ks,z,t,/rec,file=dfile,/silent,nolock=nolock,ztitle=ztitle
    if ((size(where(t eq z_t0)))(0) eq 0) then begin
      ind=closeind(t,z_t0)
      z_t0=t(ind)
    endif
    widget_control,plot_reft_widg,set_value=z_t0
    show_zcorr_3,light=shot,/nosim,t0=z_t0,refz=z_z0,nolegend=nolegend,$
                 file_light=lfile,file_dens=dfile,zrange=z_zrange,lcfs=lcfs,$
                 nopara=nopara,nolock=nolock
  endif

  ; t plot
  if (ptype eq 3) then begin
    show_tcorr_3,light=shot,/nosim,refz=t_z0,plotz=t_z1,nolegend=nolegend,$
                 file_light=lfile,file_dens=dfile,trange=t_trange,$
                 nopara=nopara
  endif

  ; autocorr plot
  if (ptype eq 4) then begin
    show_tcorr_3,light=shot,/nosim,refz=auto_z0,plotz=auto_z0,nolegend=nolegend,$
                 file_light=lfile,file_dens=dfile,trange=auto_trange,nopara=nopara
  endif

endelse


if (keyword_set(file)) then hardfile,file
if (keyword_set(printer)) then hardoff,printer

end

pro corr_event,event
;**********************************************
;                 corr-event                  *
;**********************************************
@corr_common.pro

  widget_control,cutlen_widg,get_value=s
  s=s(0)
  on_ioerror,e1
  if (strlen(s) ne 0) then cut_length_com=fix(s)  else cut_length_com=-1
  goto,ok1
e1:
  cut_length_com=-1
ok1:
  if (cut_length_com ge 0) then s=i2str(cut_length_com) else s=''
  widget_control,cutlen_widg,set_value=s
  on_ioerror,NULL

if (event.ID eq dsource_widg) then begin
  data_source_com=event.index
endif

if (event.ID eq afs_widg) then begin
  widget_control,afs_widg,get_value=data_place_com
  data_place_com=(data_place_com(0) ne 0)
endif

if (event.ID eq refz1_up_widg) then begin
  widget_control,plot_refz1_widg,get_value=w
  if (act_options(5) eq 1) then begin
    i=closeind(zscale,w)
    if (i+1 ge n_elements(zscale)) then w = zscale(i) else w=zscale(i+1)
  endif else begin
    w=w+1
  endelse
  widget_control,plot_refz1_widg,set_value=w
  get_ranges
endif

if (event.ID eq refz1_down_widg) then begin
  widget_control,plot_refz1_widg,get_value=w
  if (act_options(5) eq 1) then begin
    i=closeind(zscale,w)
    if (i-1 lt 0) then w = zscale(i) else w=zscale(i-1)
  endif else begin
    w=w-1
  endelse
  widget_control,plot_refz1_widg,set_value=w
  get_ranges
endif

if ((event.ID eq calc_light_widg) or (event.ID eq calc_both_widg)) then begin
  widget_control,lfile_widg,set_value='',sensitive=0
  lfile_OK=0
  widget_control,dfile_widg,set_value='',sensitive=0
  dfile_OK=0
  widget_control,shot_widg,get_value=shot
  if (shot eq 0) then begin
    corr_message,'No shot number defined, cannot calculate crosscorrelation.',/forward
    return
  endif
  widget_control,data_val_widg,set_value=0
  widget_control,tfile_widg,get_value=tfile
  tfile=tfile(0)
  widget_control,backtfile_widg,get_value=backtimefile
  backtimefile=backtimefile(0)
  openr,unit,dir_f_name('time',tfile),error=error,/get_lun
  if (error ne 0) then begin
    corr_message,'No timefile is set or file not found. Create a timefile first.',/forward
    return
  endif
  close,unit
  free_lun,unit
  widget_control,tres_widg,get_value=tres
  widget_control,t1_widg,get_value=t1
  widget_control,t2_widg,get_value=t2
  cutlen=cut_length_com
  if ((tres eq 0) or ((t1 eq 0) and (t2 eq 0)) or (cutlen lt 0)) then begin
    corr_message,'Missing calculation parameters. Press <default> to set defaults.',/forward
    return
  endif
  w1=fltarr(max_n_chan)
  w1(channels-1)=1
  w=fltarr(max_n_chan)
  w(defchannels(shot,data_source=data_source_com)-1)=1
  ind=where(w eq 0)
  if ((size(ind))(0) ne 0) then w1(ind)=0
  if (chsel_open) then widget_control,chsel_widg,set_value=w1
  channels=findgen(max_n_chan)+1
  ind=where(w1 ne 0)
  channels=channels(ind)

  if (data_place_com eq 1) then afs=1
  if (calc_contr_widg ne 0) then widget_control,calc_contr_widg,/destroy
  widget_control,corr_widg,tlb_get_offset=off,tlb_get_size=s
  calc_contr_widg=widget_base(title='Calculation control ('+getenv('HOST')+')',$
                column=1,tlb_frame_attr=11,$
                xoff=off(0)+s(0),yoff=off(1)+s(1)/2)
  calc_contr_on=1
  w=widget_label(calc_contr_widg,value='Calculating light correlations. Shot: '+i2str(shot))
  calc_mess_widg=widget_text(calc_contr_widg,ysize=10,xsize=80,/scroll)
  calc_stop_widg=widget_button(calc_contr_widg,value='STOP',/align_right)
  widget_control,calc_stop_widg,/input_focus
  widget_control,calc_contr_widg,/realize
  stop_pressed=0
  widget_control,corr_widg,/hourglass
  zztcorr,shot,tfile,trange=[t1,t2],tres=tres,cut_length=cutlen,outfile=calcfile,$
      channels=channels,errormess=errormess,/silent,data_source=data_source_com,afs=afs,$
      checkstop='checkstop',messageproc='calc_message',backtimefile=backtimefile
  widget_control,calc_contr_widg,map=0
  calc_contr_on=0
  calc_stop_widg=0
  if (calcfile eq '') then begin
    if (errormess ne '') then begin
      corr_message,errormess
    endif else begin
      if (stop_pressed eq 1) then begin
        corr_message,'Light correlation calculation aborted.',forward=0
      endif else begin
        corr_message,'Could not calculate light crosscorrelation.'
        corr_message,errormess,/forward
      endelse
    endelse
    return
  endif
end

if ((event.ID eq calc_dens_widg) or (event.ID eq calc_both_widg)) then begin
  if (not lfile_OK) then begin
    corr_message,'Must load a light correlation file before calculating density correlations.',/forward
    return
  endif
  widget_control,matfile_widg,get_value=matrix
  matrix=matrix(0)
  if (matrix eq '') then begin
    corr_message,'Must set matrix file for calculation of density correlations!',/forward
    return
  endif
  widget_control,autocut_widg,get_value=autocut
  widget_control,lfile_widg,get_value=lfile
  lfile=lfile(0)
  trange=[0,0]
  widget_control,t1_widg,get_value=w
  trange(0)=w
  widget_control,t2_widg,get_value=w
  trange(1)=w
  if (calc_contr_widg ne 0) then widget_control,calc_contr_widg,/destroy
  widget_control,corr_widg,tlb_get_offset=off,tlb_get_size=s
  calc_contr_widg=widget_base(title='Calculation control ('+getenv('HOST')+')',$
                  column=1,tlb_frame_attr=11,$
                  xoff=off(0)+s(0),yoff=off(1)+s(1)/2)
  calc_contr_on=1
  w=widget_label(calc_contr_widg,value='Reconstructing density correlations.')
  calc_mess_widg=widget_text(calc_contr_widg,ysize=10,xsize=80,/scroll)
  w=widget_base(calc_contr_widg,/align_right,column=2)
  calc_next_widg=widget_button(w,value='next tau')
  calc_stop_widg=widget_button(w,value='STOP')
  widget_control,calc_stop_widg,/input_focus
  widget_control,calc_contr_widg,/realize
  widget_control,rec_fix_widg,get_value=w
  nofix1=(w(0) eq 0)
  nofix2=(w(1) eq 0)
  stop_pressed=0
  rec_necorr,file=lfile,matrix=matrix,errorproc='corr_message',autocorr_cut=autocut,$
            outfile=calc_dens_file,channels=channels,$
            messageproc='calc_message',checkstop='checkstop',checknext='checknext',$
            trange=trange,nofix1=nofix1,nofix2=nofix2
  widget_control,calc_contr_widg,map=0
  calc_contr_on=0
  calc_stop_widg=0
  calc_next_widg=0
  if (keyword_set(calc_dens_file)) then begin
    if (event.ID eq calc_dens_widg) then begin
      widget_control,data_val_widg,set_value=1
    endif else begin
      widget_control,data_val_widg,set_value=2
    endelse
  endif else begin
    widget_control,data_val_widg,set_value=0
    if (stop_pressed eq 1) then begin
      corr_message,'Density correlation calculation aborted.',forward=0
    endif else begin
      corr_message,'Could not calculate density crosscorrelation.'
    endelse
    return
  endelse
endif

if ((event.ID eq shot_widg) or (event.ID eq tfile_widg) or (event.ID eq tres_widg)$
    or (event.ID eq t1_widg) or (event.ID eq t2_widg) or (event.ID eq cutlen_widg)$
    or (event.ID eq data_val_widg) or (event.ID eq calc_light_widg)$
    or (event.ID eq calc_dens_widg) or (event.ID eq calc_both_widg)$
    or (event.ID eq load_light_widg) or (event.ID eq load_dens_widg)$
    or (event.ID eq load_both_widg) or (event.ID eq exp_widg)) then begin
  if (event.ID eq calc_light_widg) then file_w=calcfile
  if (event.ID eq calc_dens_widg) then file_w=calc_dens_file
  widget_control,lfile_widg,set_value='',sensitive=0
  lfile_OK=0
  widget_control,dfile_widg,set_value='',sensitive=0
  dfile_OK=0
	if (experiment_mode eq 0) then begin
    widget_control,shot_widg,get_value=shot
    if (shot eq 0) then return
	endif else begin
    widget_control,exp_widg,get_value=experiment
		experiment=experiment[0]
    if (experiment eq '') then return
	endelse
  widget_control,data_val_widg,get_value=dtype
  ; for multi-auto plot disable data type 2 (both)
  if ((prev_index eq 5) and (dtype eq 2)) then dtype=0
  if (event.ID eq load_light_widg) then dtype=0
  if (event.ID eq load_dens_widg) then dtype=1
  if (event.ID eq load_both_widg) then dtype=2
  widget_control,data_val_widg,set_value=dtype

  if (event.ID eq shot_widg) then begin
    widget_control,tfile_widg,set_value=''
    widget_control,matfile_widg,set_value=''
  endif
  widget_control,tfile_widg,get_value=tfile
  tfile=tfile(0)
  widget_control,tres_widg,get_value=tres
  widget_control,t1_widg,get_value=t1
  widget_control,t2_widg,get_value=t2
  widget_control,matfile_widg,get_value=matrix
  matrix=matrix(0)
  widget_control,autocut_widg,get_value=autocut
  if ((autocut lt 0) and (autocut ne -1)) then begin
    autocut=-1
    widget_control,autocut_widg,get_value=autocut
  endif
  cutlen=cut_length_com
  found=0
  widget_control,corr_widg,/hourglass
  if (((experiment_mode eq 0) and keyword_set(shot)) or $
      ((experiment_mode ge 1) and keyword_set(experiment))) then begin
    found=1
    if (tfile ne '') then begin
      tfile_w=tfile
    endif
    if (tres ne 0) then tres_w=tres
    if ((t1 ne 0) and (t2 ne 0)) then trange_w=[t1,t2]
    if (cutlen ge 0) then cutlen_w=cutlen
    if (matrix ne '') then begin
      matrix_w=matrix
    endif
    if (autocut ne 0) then autocut_w=autocut
    if ((dtype eq 0) or (dtype eq 2)) then begin
      widget_control,load_opt_widg,get_value=load_opt
      nolock=(load_opt(0) eq 0)
      load_zztcorr,shot,k,ks,z,t,freq,pow,pows,timefile=tfile_w,tres=tres_w,trange=trange_w,$
                   cut_len=cutlen_w,file=file_w,channels=channels_w,/silent,ztitle=ztitle,$
                   data_source=data_source_w,backtimefile=backtimefile,nolock=nolock,experiment=experiment
      if ((size(k))(0) eq 3) then begin
        widget_control,lfile_widg,set_value=file_w,sensitive=1
        corr_message,'Crosscorrelation file for light is found:'+file_w,forward=0
        lfile_OK=1
        ; Save the z scale, will be used for stepping the ref position
        zscale = z
      endif else begin
        found=0
        lfile_OK=0
        corr_message,'No light crosscorrelation file found.',/forward
      endelse
    endif
    if ((dtype eq 1) or (dtype eq 2)) then begin
      widget_control,load_opt_widg,get_value=load_opt
      nolock=(load_opt(0) eq 0)
      widget_control,rec_fix_widg,get_value=w
      nofix1=(w(0) eq 0)
      nofix2=(w(1) eq 0)
      load_zztcorr,shot,kd,ksd,zd,td,timefile=tfile_w,tres=tres_w,trange=trange_w,$
                   cut_len=cutlen_w,file=file_w1,/rec,/silent,data_source=data_source_w,$
                   matrix=matrix_w,autocorr_cut=autocut_w,backtimefile=backtimefile,nolock=nolock,$
                   nofix1=nofix1,nofix2=nofix2,experiment=experiment,ztitle=ztitle
      if ((size(kd))(0) eq 3) then begin
        widget_control,dfile_widg,set_value=file_w1,sensitive=1
        corr_message,'Crosscorrelation file for density is found:'+file_w1,forward=0
        dfile_OK=1
      endif else begin
        found=0
        dfile_OK=0
        corr_message,'No density crosscorrelation file found.',/forward
      endelse
    endif
		if ((dtype eq 2) and not found and (lfile_OK or dfile_OK)) then begin
		  if (lfile_OK) then dtype=0 else dtype=1
      widget_control,data_val_widg,set_value=dtype
			found=1
		endif
    if (found) then begin
		  if (experiment_mode eq 0) then begin
        widget_control,tfile_widg,set_value=tfile_w,sensitive=1
        widget_control,backtfile_widg,set_value=backtimefile,sensitive=1
		  endif
      widget_control,tres_widg,set_value=tres_w,sensitive=1
      widget_control,t1_widg,set_value=trange_w(0),sensitive=1
      widget_control,t2_widg,set_value=trange_w(1),sensitive=1
      widget_control,cutlen_widg,set_value=string(cutlen_w),sensitive=1
      data_source_com=data_source_w
      cut_length_com=cutlen_w
      if ((dtype eq 0) or (dtype eq 2)) then begin
        filechannels=channels
        set_channels,channels_w
      endif
      if (dfile_OK) then begin
        widget_control,matfile_widg,set_value=matrix_w
        widget_control,autocut_widg,set_value=autocut_w
        w=[(nofix1 eq 0),(nofix2 eq 0)]
        widget_control,rec_fix_widg,set_value=w
      endif
      default,z,zd
      default,zd,z
      default,t,td
      default,td,t
      widget_control,ranges_opt_widg,get_value=w
      if (ranges_empty or w(0) ne 0) then begin
        zt_z0=min(z)+3
        if (zt_z0 gt max(z)) then zt_z0=(float(max(z)+min(z)))/2
        z_z0=zt_z0
        t_z0=zt_z0
        t_z1=zt_z0
        cross_z1=zt_z0
        cross_z2=zt_z0
        autopow_z=zt_z0
        auto_z0=zt_z0
        zz_t0=t(closeind(t,0))
        z_t0=zz_t0
        zt_zrange=[max([min(z),min(zd)]),min([max(z),max(zd)])]
        zt_trange=[max([min(t),min(td)]),min([max(t),max(td)])]
        print,min(z),max(z),zt_zrange
        zz_z0range=zt_zrange
        zz_z1range=zt_zrange
        z_zrange=zt_zrange
        t_trange=zt_trange
        auto_trange=zt_trange
        mauto_trange=zt_trange
        if (keyword_set(freq)) then cross_frange=[min(freq),max(freq)] $
             else cross_frange=[0,100]
        autopow_frange=cross_frange
        power_trange=[0,0]
        power_zrange=zt_zrange
        ELM_zrange=zt_zrange
        ctime_zrange=zt_zrange
        profiles_zrange=zt_zrange
        ranges_empty=0
      endif
      ranges_on
    endif else begin
      widget_control,sensitive=0,set_value='',lfile_widg
      widget_control,sensitive=0,set_value='',dfile_widg
;      ranges_off
;      if (chsel_open) then begin
;        widget_control,/destroy,chsel_base_widg
;        chsel_open=0
;      endif
;      widget_control,chan_widg,sensitive=0
    endelse
  endif else begin
    widget_control,sensitive=0,lfile_widg
    widget_control,sensitive=0,dfile_widg
    widget_control,sensitive=0,tfile_widg
    widget_control,sensitive=0,tres_widg
    widget_control,sensitive=0,t1_widg
    widget_control,sensitive=0,t2_widg
    widget_control,sensitive=0,cutlen_widg
    if (chsel_open) then begin
      widget_control,/destroy,chsel_base_widg
      chsel_open=0
    endif
    widget_control,chan_widg,sensitive=0
  endelse
endif

if ((event.ID eq shot_clear_widg)) then begin
  clear_corr_para
  return
endif

if ((event.ID eq shot_def_widg)) then begin
  set_shot_def
  return
endif

if ((event.ID eq add_prof_widg) or (event.ID eq repl_prof_widg)) then begin
  if (not lfile_OK and not dfile_OK) then begin
    corr_message,'Must load data file first!',/forward
    return
  endif
  if (event.ID eq repl_prof_widg) then replace=1 else replace=0
  widget_control,backtfile_widg,get_value=backtimefile
  backtimefile=backtimefile(0)
  widget_control,lfile_widg,get_value=lfile
  lfile=lfile(0)
  widget_control,dfile_widg,get_value=dfile
  dfile=dfile(0)
  if (data_place_com eq 1) then afs=1
  if (calc_contr_widg ne 0) then widget_control,calc_contr_widg,/destroy
  widget_control,corr_widg,tlb_get_offset=off,tlb_get_size=s
  calc_contr_widg=widget_base(title='Calculation control ('+getenv('HOST')+')',$
                column=1,tlb_frame_attr=11,$
                xoff=off(0)+s(0),yoff=off(1)+s(1)/2)
  calc_contr_on=1
  calc_mess_widg=widget_text(calc_contr_widg,ysize=10,xsize=80,/scroll)
  widget_control,calc_contr_widg,/realize
  if (lfile_OK) then begin
    errormess=''
    add_profiles,lfile,backtimefile,errormess=errormess,message_proc='calc_message',afs=afs,replace=replace
    if (errormess ne '') then begin
      widget_control,calc_contr_widg,map=0
      calc_contr_on=0
      corr_message,errormess,/forward
      return
    endif
  endif
  if (dfile_OK) then begin
    errormess=''
    add_profiles,dfile,backtimefile,errormess=errormess,message_proc='calc_message',afs=afs,replace=replace,/rec
    if (errormess ne '') then begin
      widget_control,calc_contr_widg,map=0
      calc_contr_on=0
      corr_message,errormess,/forward
      return
    endif
  endif
  widget_control,calc_contr_widg,map=0
  calc_contr_on=0
  return
endif

if ((event.ID eq save_comp_widg) and (compfilename ne '')) then begin
; dialog_pickfile is and IDL 5 feature, disabling for compatibility
;  fff=dialog_pickfile(filter='*.compare',titte='Select compare file to write')
  print,'Enter filename:'
  fff=''
  read,fff
  if (fff ne '') then begin
    spawn,'cp '+compfilename+' '+fff
  endif
  return
endif

if ((event.ID eq start_comp_widg) or (event.ID eq add_comp_widg)) then begin
  if ((event.ID eq start_comp_widg) or (compfilename eq '')) then begin
    compfilename=getenv('HOST')+i2str(getpid())+'.compare'
    openw,unit,compfilename,/get_lun,error=error
    if (error ne 0) then begin
      corr_message,'Cannot open file: '+compfilename,/forward
      return
    endif
    close,unit
    free_lun,unit
    if (event.ID eq start_comp_widg) then return
  endif
  if (not dfile_OK) then begin
    corr_message,'Load a density file before adding it to comparison!',/forward
    return
  endif
  widget_control,dfile_widg,get_value=dfile
  dfile=dfile(0)
  print,'Enter label:'
  w_txt=''
  read,w_txt
  if (w_txt eq '') then w_txt=dfile
  openu,unit,compfilename,/get_lun,/append,error=error
  if (error ne 0) then begin
    corr_message,'Cannot open file: '+compfilename,/forward
    return
  endif
  !error=0
  on_ioerror,corr_err
  printf,unit,dfile+' '+w_txt
corr_err:
  if (!error ne 0) then begin
    corr_message,'Error writing file: '+compfilename,/forward
    return
  endif
  close,unit
  free_lun,unit
  return
endif

if ((event.ID eq sel_time_widg)) then begin
  widget_control,shot_widg,get_value=shot
  if (shot eq 0) then begin
    corr_message,'No shot number is set, cannot select time ranges.',/forward
    return
  endif
  c=defchannels(shot,data_source=data_source_com)
  widget_control,plot_refz1_widg,get_value=w
;  if (w ge 10) then begin
    corr_zscale,shot,c,data_source=data_source_com
;    beam_coordinates,shot,beam_RR,beam_ZZ,xrr,data_source=data_source_com
    w=closeind(zscale,w)+1
;  endif else begin
;    w=18
;  endelse
  ch = c[w];
 ; ch=c(closeind(c,w))
  if (data_source_com eq 0) then begin
    if (data_place_com eq 1) then afs=1
    openr,unit,flukfile(shot,ch,afs=afs),/get_lun,error=error
    if (error ne 0) then begin
      corr_message,'Cannot find raw data for channel '+i2str(ch)+', shot'+i2str(shot)+$
                ' ('+flukfile(shot,ch,afs=afs)+')',/forward
      return
    endif
    close,unit
    free_lun,unit
  endif
  if (prev_index eq 6) then begin
    get_ranges
    if (not ((times_trange(0) eq 0) and (times_trange(1) eq 0))) then trange=times_trange
  endif
  select_time,shot,ch,file=fn,errorproc='corr_message',data_source=data_source_com,$
     afs=afs,trange=trange
  if (fn ne '') then begin
    widget_control,tfile_widg,set_value=fn
  endif
endif

if ((event.ID eq lfile_next_widg) or (event.ID eq lfile_prev_widg)) then begin
  widget_control,corr_widg,/hourglass
  widget_control,load_opt_widg,get_value=load_opt
  nolock=(load_opt(0) eq 0)
  if (not lfile_OK) then begin
    if (experiment_mode eq 0) then begin
      widget_control,shot_widg,get_value=shot
		endif else begin
      widget_control,exp_widg,get_value=experiment
			experiment=experiment[0]
		endelse
    if (((experiment_mode eq 0) and keyword_set(shot)) or $
        ((experiment_mode eq 1) and keyword_set(experiment)) or $
        ((experiment_mode eq 2) and keyword_set(experiment))) then begin
			if (experiment_mode eq 2) then begin
      	load_zztcorr,shot,k,ks,z,t,file=fn,/silent,nolock=nolock,experiment=experiment,ztitle=ztitle,/twodim
			endif else begin
      	load_zztcorr,shot,k,ks,z,t,file=fn,/silent,nolock=nolock,experiment=experiment,ztitle=ztitle
			endelse
      if ((size(k))(0) ne 3) then return
      ; Save the z scale, will be used for stepping the ref position
      zscale = z
      set_corr_para,file=fn,found=found
      return
    endif else return
  endif
  widget_control,lfile_widg,get_value=fn
  fn=fn(0)
  ind=rstrpos(fn,'.')
  ind=ind(0)
  fni=-1
  if ((ind ge 0) and (ind ne strlen(fn)-1)) then begin
    s=strmid(fn,ind+1,strlen(fn)-ind-1)
    on_ioerror,e2
    fni=fix(s)
    goto,ok2
e2:
    fni=-1
ok2:
  on_ioerror,NULL
  endif
  if (fni lt 0) then return
  if (event.id eq lfile_next_widg) then begin
    fni=fni+1
  endif else begin
    fni=fni-1
    if (fni lt 0) then return
  endelse
  fn1=strmid(fn,0,ind)+'.'+i2str(fni)
  set_corr_para,file=fn1
  return
endif
if (((event.ID eq lfile_del_widg) and lfile_OK) or $
    ((event.ID eq dfile_del_widg) and dfile_OK)) then begin
  widget_control,corr_widg,/hourglass
  if (not keyword_set(nolock)) then lock,'zzt/lock',20
  if (event.ID eq lfile_del_widg) then fwidg=lfile_widg else fwidg=dfile_widg
  widget_control,fwidg,get_value=fn
  fn=fn(0)
  spawn,'rm '+'zzt/'+fn
  update_corr_list,file=fn,list=list,/delete
  fndel=fn
  ind=rstrpos(fn,'.')
  ind=ind(0)
  fni=-1
  if ((ind ge 0) and (ind ne strlen(fn)-1)) then begin
    s=strmid(fn,ind+1,strlen(fn)-ind-1)
    on_ioerror,e3
    fni=fix(s)
    goto,ok3
e3:
    fni=-1
ok3:
  on_ioerror,NULL
  endif
  if (fni lt 0) then return
  cont=1
  moved=0
  while (cont) do begin
    fni1=fni+1
    fn1=strmid(fndel,0,ind)+'.'+i2str(fni1)
    openr,unit,'zzt/'+fn1,/get_lun,error=error
    if (error ne 0) then begin
      cont=0
    endif else begin
      close,unit
      free_lun,unit
      spawn,'mv zzt/'+fn1+' zzt/'+fn
      update_corr_list,file=fn,list=list,rename_from=fn1
      moved=1
      fni=fni1
      fn=fn1
    endelse
  endwhile
  if (moved) then begin
    if (event.ID eq lfile_del_widg) then begin
      set_corr_para,file=fndel
    endif else begin
      set_corr_para,file=fndel,/rec
    endelse
  endif else begin
    if (fni eq 0) then begin
      widget_control,sensitive=0,fwidg,set_value=''
    endif else begin
      fni=fni-1
      fn=strmid(fndel,0,ind)+'.'+i2str(fni)
      if (event.ID eq lfile_del_widg) then begin
        set_corr_para,file=fn
      endif else begin
        set_corr_para,file=fn,/rec
      endelse
    endelse
  endelse
  if (not keyword_set(nolock)) then unlock,'zzt/lock'
endif
if ((event.ID eq dfile_next_widg) or (event.ID eq dfile_prev_widg)) then begin
  widget_control,corr_widg,/hourglass
  if (not dfile_OK) then begin
    widget_control,shot_widg,get_value=shot
    widget_control,load_opt_widg,get_value=load_opt
    nolock=(load_opt(0) eq 0)
    if (shot ne 0) then begin
      load_zztcorr,shot,k,ks,z,t,file=fn,/rec,/silent,nolock=nolock,ztitle=ztitle
      if ((size(k))(0) ne 3) then return
      set_corr_para,file=fn,/rec,found=found
      return
    endif else return
  endif
  widget_control,dfile_widg,get_value=fn
  fn=fn(0)
  ind=rstrpos(fn,'.')
  ind=ind(0)
  fni=-1
  if ((ind ge 0) and (ind ne strlen(fn)-1)) then begin
    s=strmid(fn,ind+1,strlen(fn)-ind-1)
    on_ioerror,e4
    fni=fix(s)
    goto,ok4
e4:
    fni=-1
ok4:
  on_ioerror,NULL
  endif
  if (fni lt 0) then return
  if (event.id eq dfile_next_widg) then begin
    fni=fni+1
  endif else begin
    fni=fni-1
    if (fni lt 0) then return
  endelse
  fn1=strmid(fn,0,ind)+'.'+i2str(fni)
;  load_zztcorr,shot,k,ks,z,t,timefile=tfile_w,tres=tres_w,trange=trange_w,$
;                   cut_len=cutlen_w,file=fn1,/rec,/silent
;  if ((size(k))(0) ne 3) then return
  set_corr_para,file=fn1,/rec,found=found
endif
if (event.ID eq xplot_widg) then corrplot
if (event.ID eq fileplot_widg) then begin
    widget_control,fname_widg,get_value=txt
    txt=txt(0)
    corrplot,file=txt
endif
if (event.ID eq printplot_widg) then begin
    widget_control,pname_widg,get_value=txt
    txt=txt(0)
    corrplot,print=txt
endif
if (event.ID eq plot_type_widg) then begin
  ranges_sens_save=ranges_sens
  if (ranges_sens_save) then begin
    get_ranges
    ranges_off
  endif
  prev_index=event.index
  if (ranges_sens_save) then ranges_on
endif
if (event.ID eq window_widg) then begin
  if (event.index lt window_n) then begin
    wset,event.index
    act_window=event.index
    return
  endif
  window,window_n
  window_n=window_n+1
  act_window=window_n-1
  lst=strarr(window_n+1)
  for i=0,window_n-1 do lst(i)='window '+i2str(i)
  lst(window_n)='new window'
  widget_control,window_widg,set_value=lst,set_droplist_select=act_window
  return
endif

if (event.ID eq chan_widg) then begin
  if (not chsel_open) then begin
    widget_control,corr_widg,tlb_get_offset=off,tlb_get_size=s
    chsel_base_widg=widget_base(title='Channel selection',$
            event_pro='chsel',column=1,xoff=off(0)+s(0),yoff=off(1),$
            tlb_frame_attr=11)
    c=fltarr(max_n_chan)
    c(channels-1)=1
    l=strarr(max_n_chan)
    for i=0,max_n_chan-1 do l(i)=i2str(i+1)
    chsel_widg=cw_bgroup(chsel_base_widg,l,/nonexclusive,$
                          set_value=c,column=5)
    chsel_OK_widg=widget_button(chsel_base_widg,value='Hide',/align_right)
    widget_control,chsel_base_widg,/realize
    chsel_open=1
		return
  endif else begin
    widget_control,/destroy,chsel_base_widg
    chsel_open=0
		return
  endelse
endif

if (event.ID eq opt_button_widg) then begin
  if (not option_exists) then begin
    widget_control,control_widg,tlb_get_offset=off,tlb_get_size=s
    opt_widg=widget_base(title='Plot options ('+getenv('HOST')+')',$
            event_pro='opt_event',column=1,xoff=off(0)+s(0),yoff=off(1)+s(1)*0.45,$
            tlb_frame_attr=11)
    opt_val_widg=cw_bgroup(opt_widg,['plot legend','plus contours','plot LCFS','plot error','plot parameters',$
        'Z to channels','overplot','Reff scale'],/nonexclusive,$
                        set_value=act_options,column=2)
    lcfs_base_widg=widget_base(opt_widg,column=2,frame=1)
    lcfs_sw_widg=cw_bgroup(lcfs_base_widg,['value:','auto LCFS'],/exclusive,$
                        set_value=1,column=1)
    lcfs_val_widg=cw_field(lcfs_base_widg,title='Z(LCFS) [cm]:',xsize=3,value='',/float)
    widget_control,lcfs_val_widg,sensitive=0
    w=widget_base(opt_widg,column=2,frame=1)
    w1=widget_label(w,value='Colorscheme:')
    plot_col_widg=widget_droplist(w,value=c_scheme_list)
    plot_nlev_widg=cw_field(opt_widg,title='Number of contours:',xsize=2,value=30,/int)
    w=widget_base(opt_widg,column=2,frame=1)
    plot_lthick_widg=cw_field(w,title='Line thickness:',xsize=1,value=1,/int)
    plot_athick_widg=cw_field(w,title='Axis thickness:',xsize=1,value=1,/int)
    plot_csize_widg=cw_field(w,title='Char size:',xsize=3,value=1.0,/float)
    w=widget_base(opt_widg,column=2,frame=1)
    plot_range1_widg=cw_field(w,title='Plot range:',xsize=8,value=0,/float)
    plot_range2_widg=cw_field(w,title='to',xsize=8,value=0,/float)
    plot_tit_widg=cw_field(opt_widg,title='Title:',value='',xsize=30,/string)
    opt_OK_widg=widget_button(opt_widg,value='Hide',/align_right)
		widget_control,opt_widg,/realize
		opt_on=1
		option_exists=1
		return
	endif
	if (not opt_on) then begin
    widget_control,opt_widg,map=1
		opt_on=1
	endif else begin
    widget_control,opt_widg,map=0
		opt_on=0
	endelse
	return
endif

if (event.ID eq calc_butt_widg) then begin
  if (calc_contr_widg eq 0) then begin
    corr_message,'No calculation results are available',/forward
    return
  endif
  if (calc_contr_on) then begin
    widget_control,calc_contr_widg,map=0
    calc_contr_on=0
  endif else begin
    widget_control,calc_contr_widg,map=1
    calc_contr_on=1
  endelse
  return
endif

if (event.ID eq mess_butt_widg) then begin
  if (not mess_exists) then begin
    create_message,1
    return
  end
  if (not mess_on) then begin
    widget_control,mess_base_widg,map=1
    mess_on=1
  endif else begin
    widget_control,mess_base_widg,map=0
    mess_on=0
  endelse
endif
widget_control,data_val_widg,get_value=dtype
ptype=prev_index
if (experiment_mode eq 0) then widget_control,shot_widg,get_value=shot
if ( ( (((dtype eq 0) or (dtype eq 2)) and lfile_OK) or $
       (((dtype eq 1) or (dtype eq 2)) and dfile_OK) or $
       (((ptype eq 6) or (ptype eq 10)) and (shot ne 0)) $
     ) $
      and ((event.ID eq plot_refz1_widg) or (event.ID eq plot_refz2_widg) or $
          (event.ID eq plot_reft_widg) or $
          (event.ID eq z1range1_widg) or (event.ID eq z1range2_widg) or $
          (event.ID eq z2range1_widg) or (event.ID eq z2range2_widg) or $
          (event.ID eq trange1_widg) or (event.ID eq trange2_widg) or $
          (event.ID eq refz1_down_widg) or (event.ID eq refz1_up_widg)))$
     then corrplot
if (event.ID eq stop_widg) then begin
    widget_control,/destroy,corr_widg
    if (chsel_open) then widget_control,/destroy,chsel_base_widg
    if (option_exists) then widget_control,/destroy,opt_widg
    if (mess_exists) then widget_control,/destroy,mess_base_widg
    widget_control,/destroy,plot_contr_widg
endif

if (event.ID eq shot_exp_widg) then begin
  if (event.index eq 0) then begin
    ; Shot
    widget_control,sensitive=0,exp_widg
    widget_control,sensitive=1,shot_widg
     widget_control,sensitive=1,tfile_widg
	  experiment_mode = 0
  endif
  if (event.index eq 1) then begin
    ; 1D Experiment
    widget_control,sensitive=1,exp_widg
    widget_control,sensitive=0,shot_widg
     widget_control,sensitive=0,tfile_widg
  	experiment_mode = 1
  endif
  if (event.index eq 2) then begin
    ; 2D Experiment
    widget_control,sensitive=1,exp_widg
    widget_control,sensitive=0,shot_widg
     widget_control,sensitive=0,tfile_widg
  	experiment_mode = 2
  endif
endif

end		  ; corr_event

pro calc_message,txt,no_newline=no_newline
@corr_common.pro
if (keyword_set(no_newline)) then no_newline=1 else no_newline=0
widget_control,calc_mess_widg,/append,set_value=txt,no_newline=no_newline
end

function checkstop
; Returns 1 if stop button is pressed  0 otherwise
@corr_common.pro
if (stop_pressed ne 0) then return,1
if (not keyword_set(calc_stop_widg)) then return,0
if (calc_stop_widg eq 0) then return,0
w=widget_event(calc_stop_widg,/nowait)
if (w.ID eq 0) then return,0
stop_pressed=1
return,1
end

function checknext
; Returns 1 if next button is pressed (in calculation control widget)
;  0 otherwise
@corr_common.pro
if (not keyword_set(calc_next_widg)) then return,0
if (calc_next_widg eq 0) then return,0
w=widget_event(calc_next_widg,/nowait)
if (w.ID eq 0) then return,0
return,1
end


pro set_shot_def
@corr_common.pro
  widget_control,shot_widg,get_value=shot
  clear_corr_para
  if (shot ne 0) then begin
    widget_control,shot_widg,set_value=shot,sensitive=1
    tfile=i2str(shot)+'on.time'
    backtfile=i2str(shot)+'off.time'
    mfile=i2str(shot)+'_m_corr.mx'
    if ((data_source_com eq 3) or (data_source_com eq 5)) then begin
      tfile='AUG_'+tfile
      backtfile='AUG_'+backtfile
      mfile='AUG_'+mfile
    endif
    filechannels=defchannels(shot,data_source=data_source_com)
    set_channels,filechannels
  endif else begin
    widget_control,shot_widg,set_value=' ',sensitive=1
    tfile=''
    backtfile=''
    mfile=''
    set_channels,findgen(28)+1
  endelse
  widget_control,tfile_widg,set_value=tfile,sensitive=1
  widget_control,backtfile_widg,set_value=backtfile,sensitive=1
  widget_control,tres_widg,set_value=def_tres(data_source_com),sensitive=1
  widget_control,t1_widg,set_value=def_trange(0,data_source_com),sensitive=1
  widget_control,t2_widg,set_value=def_trange(1,data_source_com),sensitive=1
  widget_control,cutlen_widg,set_value=def_cut_length(data_source_com),sensitive=1
  cut_length_com=def_cut_length(data_source_com)
  widget_control,autocut_widg,set_value=def_autocorr_cut,sensitive=1
  widget_control,matfile_widg,set_value=mfile,sensitive=1
  widget_control,rec_fix_widg,set_value=def_rec_fix,sensitive=1
  return
end

pro set_channels,chlist,defchannels=defchannels
@corr_common.pro
chlist1=chlist
if (keyword_set(defchannels)) then begin
  chlist1=0
  for i=0,n_elements(chlist)-1 do begin
    ind=where(chlist(i) eq defchannels)
    if ((size(ind))(0) ne 0) then chlist1=[chlist1,chlist(ind)]
  endfor
  chlust1=chlist1(1:n_elements(chlist1)-2)
endif
channels=chlist1
if (chsel_open) then begin
  c=fltarr(max_n_chan)
  c(channels-1)=1
  widget_control,chsel_widg,set_value=c
endif

end


pro set_corr_para,file=file,rec=rec,found=found
;***********************************************************************
;  loads the parameters of the crosscorrelation calculation and
;  writes them into the appropriate widgets.
;  Enables the plot buttons.
;  found will be set to 1 if the file exists otherwise to 0
;***********************************************************************
@corr_common.pro
  widget_control,load_opt_widg,get_value=load_opt
  nolock=(load_opt(0) eq 0)
  load_zztcorr,shot,k,ks,z,t,timefile=tfile_w,tres=tres_w,trange=trange_w,$
                    cut_len=cutlen_w,file=file,rec=rec,channels=channels_w,/silent,$
                    data_source=data_source,matrix=matrix,autocorr_cut=autocorr_cut,$
                    backtimefile=backtimefile,nolock=nolock,nofix1=nofix1,nofix2=nofix2,ztitle=ztitle
  if ((size(k))(0) eq 0) then begin
    found=0
    return
  endif
  found=1
  ; Save the z scale, will be used for stepping the ref position
  zscale = z
  widget_control,tfile_widg,set_value=tfile_w,sensitive=1
  widget_control,backtfile_widg,set_value=backtimefile,sensitive=1
  widget_control,tres_widg,set_value=tres_w,sensitive=1
  widget_control,t1_widg,set_value=trange_w(0),sensitive=1
  widget_control,t2_widg,set_value=trange_w(1),sensitive=1
  widget_control,cutlen_widg,set_value=string(cutlen_w),sensitive=1
  data_source_com=data_source
  if (data_source gt 0) then data_source=data_source+1
  widget_control,dsource_widg,set_droplist_select=data_source
  cut_length_com=cutlen_w
  if (not keyword_set(rec)) then begin
    channels=channels_w
    filechannels=channels
    widget_control,chan_widg,sensitive=1
    if (chsel_open) then begin
      c=fltarr(28)
      c(channels-1)=1
      widget_control,chsel_widg,set_value=c
    endif
    widget_control,lfile_widg,set_value=file,sensitive=1
    widget_control,dfile_widg,set_value='',sensitive=0
    dtype=0
    lfile_OK=1
    dfile_OK=0
  endif else begin
    widget_control,lfile_widg,set_value='',sensitive=0
    widget_control,dfile_widg,set_value=file,sensitive=1
;    if (chsel_open) then begin
;      widget_control,/destroy,chsel_base_widg
;      chsel_open=0
;    endif
;    widget_control,chan_widg,sensitive=0
     filechannels=defchannels(shot,data_source=data_source_com)
    widget_control,matfile_widg,set_value=matrix,sensitive=1
    widget_control,autocut_widg,set_value=autocorr_cut,sensitive=1
    widget_control,rec_fix_widg,set_value=[(nofix1 eq 0), (nofix2 eq 0)],sensitive=1
    dtype=1
    lfile_OK=0
    dfile_OK=1
  endelse
  widget_control,ranges_opt_widg,get_value=w
  if (ranges_empty or (w(0) ne 0)) then begin
    zt_z0=min(z)+3
    z_z0=zt_z0
    t_z0=zt_z0
    t_z1=zt_z0
    auto_z0=zt_z0
    zz_t0=t(closeind(t,0))
    z_t0=zz_t0
    zt_zrange=[min(z),max(z)]
    zt_trange=[min(t),max(t)]
    zz_z0range=zt_zrange
    zz_z1range=zt_zrange
    z_zrange=zt_zrange
    t_trange=zt_trange
    auto_trange=zt_trange
    mauto_trange=zt_trange
    ctime_zrange=zt_zrange
    ELM_zrange=zt_zrange
    profiles_zrange=zt_zrange
    ranges_empty=0
  endif
  ranges_on
  widget_control,data_val_widg,set_value=dtype
;  if (dtype eq 2) then begin
;    widget_control,shot_widg,get_value=shot
;    ev={ID:long(shot_widg),TOP:long(corr_widg),HANDLER:long(corr_widg),$
;        VALUE:long(shot),TYPE:3,UPDATE:1}
;    widget_control,corr_widg,send_event=ev
;  endif
end

pro clear_corr_para
;***********************************************************************
;  Clears the parameters of the crosscorrelation calculation.
;***********************************************************************
@corr_common.pro
  widget_control,shot_widg,set_value=' ',sensitive=1
  widget_control,tfile_widg,set_value='',sensitive=1
  widget_control,tres_widg,set_value=' ',sensitive=1
  widget_control,t1_widg,set_value=' ',sensitive=1
  widget_control,t2_widg,set_value=' ',sensitive=1
  widget_control,cutlen_widg,set_value='',sensitive=1
  cut_length_com=-1
  widget_control,lfile_widg,set_value='',sensitive=0
  widget_control,dfile_widg,set_value='',sensitive=0
  set_channels,findgen(28)+1
  widget_control,matfile_widg,set_value='',sensitive=1
  widget_control,autocut_widg,set_value='',sensitive=1
  ranges_off
end


pro create_message,on
@corr_common.pro
default,on,0

  widget_control,corr_widg,tlb_get_offset=off,tlb_get_size=s
  mess_base_widg=widget_base(title='Messages',$
              event_pro='mess_event',column=1,xoff=off(0)+s(0),yoff=off(1)+s(1)/2,$
              tlb_frame_attr=11)
  mess_widg=widget_text(mess_base_widg,ysize=10,xsize=80,/scroll)
  mess_OK_widg=widget_button(mess_base_widg,value='Hide',/align_right)
  if (on) then begin
    widget_control,mess_base_widg,/realize,map=1
    mess_on=1
  endif else begin
    widget_control,mess_base_widg,/realize,map=0
    mess_on=0
  endelse
  mess_exists=1
end

pro opt_event,event
@corr_common.pro
if (event.ID eq plot_col_widg) then  begin
    coltype=event.index
endif
if (event.ID eq opt_OK_widg) then begin
  widget_control,opt_widg,map=0
	opt_on=0
endif
if (event.ID eq opt_val_widg) then begin
  widget_control,opt_val_widg,get_value=act_options
endif
if (event.ID eq lcfs_sw_widg) then begin
  if (event.value eq 0) then begin
    widget_control,lcfs_val_widg,sensitive=1
  endif else begin
    widget_control,lcfs_val_widg,sensitive=0
  endelse
endif
end


pro corr_message,txt,forward=forward
@corr_common.pro
default,forward,1
if (not mess_exists) then create_message,0
widget_control,mess_widg,/append,set_value=txt
if (keyword_set(forward)) then begin
  widget_control,mess_base_widg,show=1,map=1
endif
end

pro mess_event,event
@corr_common.pro
if (event.ID eq mess_OK_widg) then begin
    widget_control,mess_base_widg,map=0
    mess_on=0
endif
end

pro chsel,event
@corr_common.pro
if (event.ID eq chsel_OK_widg) then begin
  widget_control,/destroy,chsel_base_widg
  chsel_open=0
endif
if (event.ID eq chsel_widg) then begin
  widget_control,chsel_widg,get_value=i
  widget_control,shot_widg,get_value=shot
  w=fltarr(max_n_chan)
  w(filechannels-1)=1
  ind=where(w eq 0)
  if ((size(ind))(0) ne 0) then i(ind)=0
  w=fltarr(max_n_chan)
  w(defchannels(shot,data_source=data_source_com)-1)=1
  ind=where(w eq 0)
  if ((size(ind))(0) ne 0) then i(ind)=0
  widget_control,chsel_widg,set_value=i
  c=findgen(max_n_chan)+1
  ind=where(i ne 0)
  channels=c(ind)
endif
end


pro main
corr
end

pro corr,shot_corr
@corr_common.pro

max_n_chan=35

if (!d.window lt 0) then window
xs=350
ys=150
def_tres=[15,15,200,200,3,10,3,1,1,1,1]
def_trange=fltarr(2,10)
def_trange(*,0)=[-400,400]
def_trange(*,1)=[-400,400]
def_trange(*,2)=[-800,800]
def_trange(*,3)=[-800,800]
def_trange(*,4)=[-300,300]
def_trange(*,5)=[-300,300]
def_trange(*,6)=[-300,300]
def_trange(*,7)=[-300,300]
def_trange(*,8)=[-50,50]
def_cut_length=[5,5,0,0,0,5,5,2,2]
def_autocorr_cut=-1
def_rec_fix=[0,0]
filechannels=findgen(max_n_chan)+1
times_trange=[0.0,0.0]
times_z0=20
chsel_open=0

zt_z0=15.
z_z0=zt_z0
t_z0=zt_z0
t_z1=zt_z0
auto_z0=zt_z0
cross_z1=zt_z0
cross_z2=zt_z0
autopow_z=zt_z0
zz_t0=0
z_t0=zz_t0
zt_zrange=[10,20]
zt_trange=[-100,100]
zz_z0range=zt_zrange
zz_z1range=zt_zrange
z_zrange=zt_zrange
t_trange=zt_trange
auto_trange=zt_trange
power_trange=[0,0]
power_zrange=zt_zrange
ctime_zrange=zt_zrange
ELM_zrange=zt_zrange
ELM_trange=[100,250]
mauto_trange=zt_trange
autopow_frange=[0,100]
cross_frange=[0,100]
data_place_com=0
mat_zrange=[0,0]
profiles_zrange=zt_zrange
zscale = 0
ztitle='???'

compfilename=''

channels=findgen(max_n_chan)+1

corr_widg=widget_base(title='Li-beam fluctuation proc. ('+getenv('HOST')+')',$
          xoff=200,yoff=80,event_pro='corr_event',col=1,resource_name='corr')

corpar1_widg=widget_base(corr_widg,col=1,frame=1)
corpar_widg=widget_base(corpar1_widg,col=1)
corpar_shot_widg=widget_base(corpar_widg,col=2)
shot_exp_widg=widget_droplist(corpar_shot_widg,value=['One shot','1D Experiment','2D Experiment'])
shot_widg=cw_field(title='Shot:',corpar_shot_widg,xsize=7,value='',$
   /long,/return_events)
exp_widg=cw_field(title='Experiment:',corpar_shot_widg,xsize=18,value='',$
   /string,/return_events)
widget_control,sensitive=0,exp_widg
experiment_mode = 0
tfile_widg=cw_field(title='Timefile:',corpar_shot_widg,xsize=18,value='',$
   /string,/return_events)
corpar_other_widg=widget_base(corpar_widg,col=2)
tres_widg=cw_field(title='tau res:',corpar_other_widg,value='',xsize=4,/int,/return_events)
cutlen_widg=cw_field(title='cut_length:',corpar_other_widg,value='',xsize=3,/string,$
      /return_event)
cut_length_com=-1
trange_widg=widget_base(corpar_other_widg,col=1,frame=0)
trange_val_widg=widget_base(trange_widg,column=2)
t1_widg=cw_field(title='tau range ',trange_val_widg,value='',/int,xsize=6,/return_events)
t2_widg=cw_field(title='to',trange_val_widg,value='',/int,xsize=5,/return_events)
chan_widg=widget_button(corpar_other_widg,value='channels')
ww1=widget_base(corpar1_widg,col=2)
get_rawsignal,data_names=data_names
dsource_widg=widget_droplist(ww1,value=data_names)
w = local_default('data_source')
if (w ne '') then begin
  data_source_com = fix(w)
endif
widget_control,dsource_widg,set_droplist_select=data_source_com

afs_widg=cw_bgroup(ww1,['Data from AFS'],/nonexclusive,set_value=[0])
data_place_com=0  ; no afs as default

back_widg=widget_base(corr_widg,col=1,frame=1)
backtfile_widg=cw_field(title='Background timefile:',back_widg,xsize=20,value='',/string)


rec_widg=widget_base(corr_widg,col=1,frame=1)
w=widget_label(rec_widg,value='Reconstruction parameters')
rec1_widg=widget_base(rec_widg,col=2)
matfile_widg=cw_field(title='Matrix:',rec1_widg,xsize=19,value='',$
   /string,/return_events)
autocut_widg=cw_field(title='autocorr cut:',rec1_widg,value='-1',xsize=3,/int,/return_events)
rec_fix_widg=cw_bgroup(rec_widg,['fix low Z','fix high Z'],/nonexclusive,set_value=[0,0],column=2)

fname_widg=widget_base(corr_widg,col=1,frame=1)
w=widget_label(fname_widg,value='Correlation files:')
lfile_base_widg=widget_base(fname_widg,col=4)
lfile_widg=cw_field(title='Light:',lfile_base_widg,xsize=24,value='',$
   /string,/return_events,/noedit)
lfile_next_widg=widget_button(lfile_base_widg,value='next')
lfile_prev_widg=widget_button(lfile_base_widg,value='prev')
lfile_del_widg=widget_button(lfile_base_widg,value='del')
dfile_base_widg=widget_base(fname_widg,col=4)
dfile_widg=cw_field(title='Dens.:',dfile_base_widg,xsize=24,value='',$
   /string,/return_events,/noedit)
dfile_next_widg=widget_button(dfile_base_widg,value='next')
dfile_prev_widg=widget_button(dfile_base_widg,value='prev')
dfile_del_widg=widget_button(dfile_base_widg,value='del')
widget_control,sensitive=0,lfile_widg
lfile_OK=0
widget_control,sensitive=0,dfile_widg
dfile_OK=0

control_widg=widget_base(corr_widg,col=3,frame=1)
sel_time_widg=widget_button(control_widg,value='New timefile')
calc_light_widg=widget_button(control_widg,value='Calculate light')
load_light_widg=widget_button(control_widg,value='Load light')
add_prof_widg=widget_button(control_widg,value='Add profiles')
start_comp_widg=widget_button(control_widg,value='Start compare')

shot_clear_widg=widget_button(control_widg,value='Clear parameters')
calc_dens_widg=widget_button(control_widg,value='Calculate dens.')
load_dens_widg=widget_button(control_widg,value='Load dens.')
repl_prof_widg=widget_button(control_widg,value='Replace profiles')
add_comp_widg=widget_button(control_widg,value='Add to compare')

shot_def_widg=widget_button(control_widg,value='Default parameters')
calc_both_widg=widget_button(control_widg,value='Calculate both')
load_both_widg=widget_button(control_widg,value='Load both')
w=widget_button(control_widg,value='    ')
save_comp_widg=widget_button(control_widg,value='Save compare')


corr_control_widg=widget_base(corr_widg,col=4,/align_right)
load_opt_widg=cw_bgroup(corr_control_widg,['lock zzt/'],/nonexclusive,set_value=[0])
calc_butt_widg=widget_button(corr_control_widg,value='Calculation results')
calc_contr_widg=0
calc_contr_on=0
mess_butt_widg=widget_button(corr_control_widg,value='Messages')
mess_on=0
mess_exists=0

stop_widg=widget_button(corr_control_widg,value='EXIT')
widget_control,corr_widg,/realize


; ****************** plot control widget *******************************
widget_control,corr_widg,tlb_get_offset=off,tlb_get_size=s
plot_contr_widg=widget_base(title='Fluctuation plot control ('+getenv('HOST')+')',$
          xoff=off(0)+s(0)+5,yoff=off(1)+s(1)*0.8,event_pro='corr_event',col=2,tlb_frame_attr=11)
plot_widg=widget_base(plot_contr_widg,col=2,frame=1)
w=widget_label(plot_widg,value='Plot type')
plot_type_widg=widget_droplist(plot_widg,value=['z-t','z-z','z','t','autocorr',$
   'multi-auto','times','crosspower','autopower','matrix para','raw signal',$
   'power vs Z','corr. time vs Z','ELM monitor','profiles','compare prof.'])
prev_index=0
data_val_widg=cw_bgroup(plot_widg,['light','density','both'],/exclusive,$
                        set_value=0,column=3)
norm_widg=cw_bgroup(plot_widg,['w/o norm.','with norm'],/exclusive,$
                        set_value=0,column=2)

doplot_widg=widget_base(plot_contr_widg,col=1,frame=1)
xplot_base_widg=widget_base(doplot_widg,col=2)
xplot_widg=widget_button(xplot_base_widg,value='Plot X')
window_widg=widget_droplist(xplot_base_widg,value=['window 0','new window'])
window_n=1
act_window=0
dofile_widg=widget_base(doplot_widg,col=2)
fileplot_widg=widget_button(dofile_widg,value='Plot file')
fname_widg=cw_field(title='File:',dofile_widg,xsize=15,value='corr.ps',/string)
doprint_widg=widget_base(doplot_widg,col=2)
printplot_widg=widget_button(doprint_widg,value='Plot printer')
pname_widg=cw_field(title='Printer:',doprint_widg,xsize=10,value=getenv('PRINTER'),/string)


range_widg=widget_base(plot_contr_widg,frame=1,col=1)


range1_widg=widget_base(range_widg,row=1,frame=1)
w=widget_label(range1_widg,value='Z0:')
plot_refz1_widg=cw_field(range1_widg,title=' ',value='',xsize=5,/float,/return_events)
w=widget_base(range1_widg,col=1)
refz1_up_widg=widget_button(w,value=arrow_bitmap(8,/up))
refz1_down_widg=widget_button(w,value=arrow_bitmap(8,/down))
z1range1_widg=cw_field(range1_widg,title='range:',value='',xsize=5,/float,/return_events)
z1range2_widg=cw_field(range1_widg,title='to',value='',xsize=5,/float,/return_events)

range2_widg=widget_base(range_widg,col=4,frame=1)
w=widget_label(range2_widg,value='Z1:')
plot_refz2_widg=cw_field(range2_widg,title=' ',value='',xsize=5,/float,/return_events)
z2range1_widg=cw_field(range2_widg,title='range:',value='',xsize=5,/float,/return_events)
z2range2_widg=cw_field(range2_widg,title='to',value='',xsize=5,/float,/return_events)

range3_widg=widget_base(range_widg,col=4,frame=1)
t_label_widg=widget_label(range3_widg,value=' tau:')
plot_reft_widg=cw_field(range3_widg,title=' ',value='',xsize=5,/float,/return_events)
trange1_widg=cw_field(range3_widg,title='range:',value='',xsize=5,/float,/return_events)
trange2_widg=cw_field(range3_widg,title='to',value='',xsize=5,/float,/return_events)
widget_control,z1range1_widg,sensitive=0
widget_control,z1range2_widg,sensitive=0
widget_control,z2range1_widg,sensitive=0
widget_control,z2range2_widg,sensitive=0
widget_control,trange1_widg,sensitive=0
widget_control,trange2_widg,sensitive=0
widget_control,plot_refz1_widg,sensitive=0
widget_control,plot_refz2_widg,sensitive=0
widget_control,plot_reft_widg,sensitive=0
ranges_sens=0
ranges_empty=1

w=widget_base(plot_contr_widg,column=2)
ranges_opt_widg=cw_bgroup(w,['Auto ranges'],/nonexclusive,$
                        set_value=0,column=1)
opt_button_widg=widget_button(w,value='Plot options')
opt_on=0
option_exists=0
act_options=[1,0,0,1,1,1,0,0] ; The 8 tick boxes on top of the widget
plot_tit_widg=0
plot_nlev_widg=0
plot_range1_widg=0
plot_range2_widg=0
plot_lthick_widg=0
plot_athick_widg=0
plot_csize_widg=0

c_scheme_list=['blue-white-red','blue-black-red','black-white','white-black']
coltype=0



widget_control,plot_contr_widg,/realize
ranges_on
if (keyword_set(shot_corr)) then begin
  widget_control,shot_widg,set_value=shot_corr
endif
widget_control,shot_widg,/input_focus
xmanager,'correlation',corr_widg,event_handler='corr_event'
end
