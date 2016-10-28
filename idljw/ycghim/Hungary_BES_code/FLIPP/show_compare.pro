pro show_compare,filelist,txtlist,zrange=zrange,title=title,nolegend=nolegend,$
    lcfs=lcfs,errorproc=errorproc,linethick=linethick,$
    axisthick=axisthick,charsize=charsize,noerror=noerror,$
    ne_range=ne_range,ne_log_range=ne_log_range,nefluc_range=nefluc_range,li2p_range=li2p_range,$
    nefluc_rel_range=nefluc_rel_range,color=color,nolock=nolock,from_file=from_file,$
    statistics=stat,stat_av_range=stat_av_range,stat_scat_range=stat_scat_range,$
    stat_relscat_range=stat_relscat_range,$
    shift_list=shift_list,col_list=col_list,ltype_list=ltype_list,reffscale=reffscale,$
    match_lcfs=match_lcfs,notxt=notxt,r_over_a_scale=r_over_a_scale,r_over_a_range=r_over_a_range,$
    figure_mask=figure_mask,pos1=pos1,pos2=pos1a,pos3=pos2,pos4=pos4,pos5=pos5

; ******** show_compare.pro *************************** S. Zoletnik 30.1.1998 ****************
; Compares density, density fluctuation, 2p and relative density fluctuations
;
; filelist: string array containing the reconstructed density crosscorrelation files to process
; txtlist: optional string array with texts for marking the curves of the files
; from_file: an optional filename from which the filelist and txtlist arrays are read:
;                <1st file-name>  [<1st text>]
;                <2nd file-name>  [<1nd text>]
;                  ...
; /lcfs: plot LCFS values
; xxx_range: vertical plot range for the different plots
; /statistics: plot scatter vs z
; shift_list: shift Z scales by these values
; col_list: list of color numbers
; ltype_list: list of linetype numbers
; /match_lcfs: shift profiles to match the lcfs positions
; /notxt: do not print comment texts
; /r_over_a_scale: plots spatial coordinate in r/a units (a is LCFS minor radius, r: minor radius)
; figure_mask: a 5 element array, each element corresponds to one figure in the following order:
;                [n_e, n_e(log), Li(2p), n_e fluctuation abs., n_e fluctuation rel.]
;              1 enables a figure, 0 disables      (default: [1,1,1,1,1]
; pos..: position of the 5 figures (see at figure_mask) in normal ccordinates
; *******************************************************************************************

default,figure_mask,[1,1,1,1,1]

if (not keyword_set(filelist)) then begin
  if (not keyword_set(from_file)) then begin
    print,'If filelist is not set then from_file should be given!'
    return
  endif
  openr,unit,from_file,error=error,/get_lun
  if (error ne 0) then begin
    print,'Error reading '+from_file
    return
  endif
  n=0
  !error=0
  on_ioerror,err_from   
  while (!error eq 0) do begin
    ttt=' '
    readf,unit,ttt
    if (strlen(ttt) eq 0) then goto,err_from
    i=strpos(ttt,' ')
    if (i lt 0) then i=strlen(ttt)
    www_fn=strmid(ttt,0,i)
    if (i eq strlen(ttt)) then www_txt='' else www_txt=strmid(ttt,i+1,strlen(ttt)-i+1)
    if (n eq 0) then begin
      filelist=[www_fn]
      txtlist=[www_txt]
    endif else begin    
      filelist=[filelist,www_fn]
      txtlist=[txtlist,www_txt]
    endelse
    n=n+1
err_from:
  endwhile
  close,unit
  free_lun,unit    
  if (n eq 0) then begin
    print,'Could not find file list in '+from_file
    return
  endif 
end


default,title,''
default,color,1

default,pos,[0.07,0.15,0.7,0.9] ; whole plot area
default,pos1,[0.1,0.7,0.32,0.9]  ; density profile
default,pos1a,[0.1,0.4,0.32,0.6]    ; density profile (log)
default,pos2,[0.1,0.1,0.32,0.3]    ; li2p
default,pos4,[0.43,0.55,0.68,0.85]  ; dens fluct. amp
default,pos5,[0.43,0.1,0.68,0.4]  ; rel dens. fluct

default,pos_stat_1,[0.2,0.7,0.5,0.9] ; stat plot /average
default,pos_stat_2,[0.2,0.4,0.5,0.6] ; stat plot /scat
default,pos_stat_3,[0.2,0.1,0.5,0.3] ; stat plot /rel scat

txt_top=0.9
txt_xstart=0.71
txt_linedist=0.03


default,linethick,1
default,axisthick,1
if (!d.name eq 'X') then default,charsize,1 else default,charsize,0.6

nprof=n_elements(filelist)
if (keyword_set(color)) then begin
  setfigcol
  default,col_list,(indgen(nprof) mod 10) + 1
  default,ltype_list,fix(indgen(nprof) / 10)
endif else begin
  default,ltype_list,indgen(nprof)
  default,col_list,intarr(nprof)+!p.color
endelse  
  

ytit='n!De!N fluct. amp. /10!U19!N [m!U-3!N]'

z0_list=fltarr(nprof,200)
r_a0_list=fltarr(nprof,200)
z_list=fltarr(nprof,50)
r_a_list=fltarr(nprof,200)
ne_list=fltarr(nprof,200)
li2p_list=fltarr(nprof,200)
li2p_z_list=fltarr(nprof,50)
li2p_r_a_list=fltarr(nprof,50)
fluc_list=fltarr(nprof,50)
fluc_l_list=fltarr(nprof,50)
fluc_h_list=fltarr(nprof,50)
fluc_rel_list=fltarr(nprof,50)
fluc_rel_l_list=fltarr(nprof,50)
fluc_rel_h_list=fltarr(nprof,50)
lcfs_list=fltarr(nprof)
txt_lab=strarr(nprof)

for ci=0,nprof-1 do begin

  file=filelist(ci)
  if (n_elements(txtlist) ge ci+1) then begin
    if (txtlist(ci) ne '') then txt_lab(ci)=txtlist(ci) else txt_lab(ci)=file
  endif else begin
    txt_lab(ci)=file
  endelse  

  channels=0
  load_zztcorr,shot,k,ks,z,t,file=file,profile=profile,backgr_profile,$
               para_txt=para_txt,backtimefile=backtimefile,backgr_profile=backgr_profile,$
               channels=channels,/rec,matrix=matrix,$
               cut_length=cut_length,data_source=data_source,n0=n0,z0=z0,li2p_rec=p0,$
               abs_calfac=c,nolock=nolock
  default,p0,0
  n0=n0/1e13
  if ((size(k))(0) eq 0) then begin
    txt='Cannot open data file '+file+' !'
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,txt,/forward
    endif else begin
      print,txt
    endelse
    return
  endif  
  
  if (keyword_set(lcfs) or keyword_set(r_over_a_scale)) then begin
    if (lcfs lt 10) then lcfs_list(ci)=get_lcfs(shot) else lcfs_list(ci)=lcfs
  endif      

  nz0=n_elements(z0)
  z0_list(ci,0:nz0-1)=z0
  ne_list(ci,0:nz0-1)=n0
  
  if (not keyword_set(noli2p)) then begin
    if (not keyword_set(profile) or not keyword_set(backgr_profile)) then begin
      noli2p=1
    endif else begin
      nch=n_elements(profile)
      loadxrr,xrr
      li2p_z_list(ci,0:nch-1)=xrr(channels-1)
      li2p_list(ci,0:nch-1)=profile-backgr_profile
    endelse    
  endif   
  
  nz=(size(z))(1)
  z_list(ci,0:nz-1)=z
  t0time=where(t eq 0)
  flucprof=fltarr(nz)
  for i=0,nz-1 do flucprof(i)=sign_sqrt(k(i,i,t0time))
  flucp_l=fltarr(nz)
  for i=0,nz-1 do flucp_l(i)=sign_sqrt(k(i,i,t0time)-ks(i,i,t0time))
  flucp_h=fltarr(nz)
  for i=0,nz-1 do flucp_h(i)=sign_sqrt(k(i,i,t0time)+ks(i,i,t0time))


  if ((c eq 0) and (not keyword_set(nocalibrated))) then begin
    ytit='n!De!N fluct. amp. [a.u.]'
    nocalibrated=1
  endif  
           
  fluc_list(ci,0:nz-1)=flucprof
  fluc_l_list(ci,0:nz-1)=flucp_l
  fluc_h_list(ci,0:nz-1)=flucp_h
  
  if (not keyword_set(nocalibrated)) then begin
    ok=1
    if (n_elements(z0) ne n_elements(z)) then begin
      ok=0 
    endif else begin
      if ((where(z0-z ne 0))(0) ge 0) then ok=0
    endelse
    if (not ok) then n0scale=xy_interpol(z0,n0,z) else n0scale=n0  
    ind=where(n0scale gt 0)
    rel=flucprof
    rel(*)=0
    rel_l=rel
    rel_h=rel
    rel(ind)=flucprof(ind)/n0scale(ind)
    rel_h(ind)=flucp_h(ind)/n0scale(ind)
    rel_l(ind)=flucp_l(ind)/n0scale(ind)
    fluc_rel_list(ci,0:nz-1)=rel
    fluc_rel_l_list(ci,0:nz-1)=rel_l
    fluc_rel_h_list(ci,0:nz-1)=rel_h
  endif
  
  if (keyword_set(r_over_a_scale)) then begin
    refffile=i2str(shot)+'.reff'
    openr,unit,'reff/'+refffile,error=error,/get_lun
    if (error ne 0) then begin
      spawn,'rcp das3:/u/fiedler/libeam/reff/'+refffile+' reff/'+refffile
      openr,unit,'reff/'+refffile,error=error,/get_lun
    endif  
    if (error eq 0) then begin
      a=' '
      readf,unit,a
      lcfs_reff=float(a)
      close,unit
      free_lun,unit
      d=loadncol('reff/'+refffile,2,headerline=10,/silent)
    endif else begin
      if (not keyword_set(silent)) then print,'Cannot find Reff data for shot!'
      return
    endelse
    ; d(*,0) is Z
    ; d(*,1) is Reff
    lcfs_reff=(xy_interpol(d(*,0),d(*,1),[lcfs_list(ci),lcfs_list(ci)]))(0)
    nz=n_elements(where(z0_list(ci,*) ne 0))
    r_a0_list(ci,0:nz-1) = xy_interpol(d(*,0),d(*,1),transpose(z0_list(ci,0:nz-1)))/lcfs_reff
    nz=n_elements(where(z_list(ci,*) ne 0))
    r_a_list(ci,0:nz-1) = xy_interpol(d(*,0),d(*,1),transpose(z_list(ci,0:nz-1)))/lcfs_reff
    nz=n_elements(where(li2p_z_list(ci,*) ne 0))
    li2p_r_a_list(ci,0:nz-1) = xy_interpol(d(*,0),d(*,1),transpose(li2p_z_list(ci,0:nz-1)))/lcfs_reff
  endif
endfor
   

ind=where(z_list ne 0)
default,zrange,[min(z_list(ind))-0.5,max(z_list(ind))+0.5]
default,r_over_a_range,[0,1.5]

if (keyword_set(stat)) then begin
  ind=where((z_list(0,*) ge zrange(0)) and (z_list(0,*) le zrange(1)))
  if (ind(0) lt 0) then begin
    print,'No data points in zrange!'
    return
  endif  
  zzz=z_list(0,ind)
  nzzz=n_elements(zzz)
  s=fltarr(nzzz)
  s2=fltarr(nzzz)
  averr=fltarr(nzzz)
  for j=0,nzzz-1 do begin
    count=0
    for i=0,nprof-1 do begin
      iii=where(z_list(i,*) eq zzz(j))
      if (iii(0) ge 0) then begin
        s(j)=s(j)+fluc_list(i,iii(0))
        averr(j)=averr(j)+(fluc_h_list(i,iii(0))-fluc_l_list(i,iii(0)))/2
        count=count+1
      endif
    endfor
    s(j)=s(j)/count
    averr(j)=averr(j)/count
    count=0
    for i=0,nprof-1 do begin
      iii=where(z_list(i,*) eq zzz(j))
      if (iii(0) ge 0) then begin
        s2(j)=s2(j)+(fluc_list(i,iii(0))-s(j))^2
        count=count+1
      endif
    endfor
    s2(j)=sqrt(s2(j)/count)
  endfor
        
  
  rels2=fltarr(nzzz)
  ind=where(s ne 0)
  rels2(ind)=s2(ind)/s(ind)
  
  default,stat_av_range,[0,max(s)*1.05]
  default,stat_scat_range,[0,max(s2)*1.05]
  default,stat_relscat_range,[0,max(rels2)*1.05]

  erase
  if (not keyword_set(nolegend)) then time_legend,'show_compare.pro/stat'
  if (keyword_set(title)) then xyouts,0.1,0.95,title,charsize=1.3,/normal

  plot,zzz,s,xrange=zrange,xstyle=1,xtitle='Z [cm]',yrange=stat_av_range,ystyle=1,$
    ytitle=ytit,position=pos_stat_1,/noerase,title='Average fluct. amplitude'
    
  plot,zzz,s2,xrange=zrange,xstyle=1,xtitle='Z [cm]',yrange=stat_scat_range,ystyle=1,$
    position=pos_stat_2,/noerase,title='Scatter of fluct. amplitude and average error'
  oplot,zzz,averr,linestyle=2  
    
  plot,zzz,rels2,xrange=zrange,xstyle=1,xtitle='Z [cm]',yrange=stat_relscat_range,ystyle=1,$
    position=pos_stat_3,/noerase,title='Rel. scatter of amplitude'
  
  for ci=0,nprof-1 do begin
    y=txt_top-ci*txt_linedist
    xyouts,txt_xstart+0.06,y,txt_lab(ci),/normal
  endfor        
stop
  return
endif      

if (keyword_set(lcfs) and keyword_set(match_lcfs)) then begin
  shift_list=fltarr(nprof)
  for i=1,nprof-1 do begin
    shift_list(i)=lcfs_list(0)-lcfs_list(i)
  endfor
endif     

if (keyword_set(shift_list)) then begin
  for i=0,nprof-1 do begin
    ind=where(z0_list(i,*) ne 0)
    z0_list(i,ind)=z0_list(i,ind)+shift_list(i)
    ind=where(z_list(i,*) ne 0)
    z_list(i,ind)=z_list(i,ind)+shift_list(i)
    ind=where(li2p_z_list(i,*) ne 0)
    li2p_z_list(i,ind)=li2p_z_list(i,ind)+shift_list(i)
    lcfs_list(i)=lcfs_list(i)+shift_list(i)
  endfor   
endif
        
if (not keyword_set(r_over_a_scale)) then begin
  ind=where((z0_list ge zrange(0)) and (z0_list le zrange(1)))
  default,ne_range,[0,max(ne_list(ind))*1.05]
  default,ne_log_range,[ne_range(1)/200,ne_range(1)*2]
  ind=where((z_list ge zrange(0)) and (z_list le zrange(1)))
  default,nefluc_range,[0,max(fluc_h_list(ind))*1.05]
  default,nefluc_rel_range,[0,max(fluc_rel_h_list(ind))*1.05]
  default,li2p_range,[0,max(li2p_list(ind))*1.05]                       
endif else begin
  ind=where((r_a0_list ge r_over_a_range(0)) and (r_a0_list le r_over_a_range(1)))
  default,ne_range,[0,max(ne_list(ind))*1.05]
  default,ne_log_range,[ne_range(1)/200,ne_range(1)*2]
  ind=where((r_a_list ge r_over_a_range(0)) and (r_a_list le r_over_a_range(1)))
  default,nefluc_range,[0,max(fluc_h_list(ind))*1.05]
  default,nefluc_rel_range,[0,max(fluc_rel_h_list(ind))*1.05]
  default,li2p_range,[0,max(li2p_list(ind))*1.05]                       
endelse

erase
if (not keyword_set(nolegend)) then time_legend,'show_compare.pro'
if (keyword_set(title)) then xyouts,0.1,0.95,title,charsize=1.3,/normal

if (not keyword_set(r_over_a_scale)) then begin
  if (figure_mask(0) ne 0) then begin
    plot,z0_list(0,*),ne_list(0,*),xrange=zrange,xtitle='Z [cm]',xstyle=1,$
          ytitle='n!De!N [10!U19!N m!U-3!N]',yrange=ne_range,ystyle=1,$
          position=pos1,/noerase,thick=linethick,xthick=axisthick,ythick=axisthick,$
          charsize=charsize,charthick=axisthick,symsize=0.7,$
          title='Electron density',/nodata
    for ci=0,nprof-1 do begin
    ;  ind=where((z0_list(ci,*) ge zrange(0)) and (z0_list(ci,*) le zrange(1)))
      ind=where((z0_list(ci,*) gt 0))
      if (ind(0) ge 0) then oplot,z0_list(ci,ind),ne_list(ci,ind),color=col_list(ci),$
                            linestyle=ltype_list(ci),thick=linethick
      if (keyword_set(lcfs)) then plots,[lcfs_list(ci),lcfs_list(ci)],ne_range,linestyle=2,/clip
    endfor
  endif
  
  if (figure_mask(1) ne 0) then begin
    plot,z0_list(0,*),ne_list(0,*),xrange=zrange,xtitle='Z [cm]',xstyle=1,$
          ytitle='n!De!N [10!U19!N m!U-3!N]',yrange=ne_log_range,ystyle=1,ytype=1,$
          position=pos1a,/noerase,thick=linethick,xthick=axisthick,ythick=axisthick,$
          charsize=charsize,charthick=axisthick,symsize=0.7,$
          title='Electron density',/nodata
    for ci=0,nprof-1 do begin
    ;  ind=where((z0_list(ci,*) ge zrange(0)) and (z0_list(ci,*) le zrange(1)))
      ind=where((z0_list(ci,*) gt 0))
      if (ind(0) ge 0) then oplot,z0_list(ci,ind),ne_list(ci,ind),color=col_list(ci),$
                            linestyle=ltype_list(ci),thick=linethick
      if (keyword_set(lcfs)) then plots,[lcfs_list(ci),lcfs_list(ci)],ne_log_range,linestyle=2,/clip
    endfor
  endif
  
  if (figure_mask(2) ne 0) then begin
    if (not keyword_set(noli2p)) then begin
      plot,li2p_z_list(0,*),li2p_list(0,*),xrange=zrange,xtitle='Z [cm]',xstyle=1,$
          ytitle='[a. u.]',yrange=li2p_range,ystyle=1,$
          position=pos2,/noerase,thick=linethick*2,xthick=axisthick,ythick=axisthick,$
          charsize=charsize,charthick=axisthick,$
          title='Li!D2p!N profile',/nodata
      for ci=0,nprof-1 do begin
    ;    ind=where((li2p_z_list(ci,*) ge zrange(0)) and (z0_list(ci,*) le zrange(1)))
        ind=where((li2p_z_list(ci,*) gt 0))
        if (ind(0) ge 0) then oplot,li2p_z_list(ci,ind),li2p_list(ci,ind),color=col_list(ci),$
                              linestyle=ltype_list(ci),thick=linethick
        if (keyword_set(lcfs)) then plots,[lcfs_list(ci),lcfs_list(ci)],li2p_range,linestyle=2,/clip
      endfor
    endif
  endif
       
  if (figure_mask(3) ne 0) then begin
    plot,z_list(0,*),fluc_list(0,*),xrange=zrange,xtitle='Z [cm]',xstyle=1,$
          ytitle=ytit,yrange=nefluc_range,ystyle=1,$
          position=pos4,/noerase,thick=linethick,xthick=axisthick,ythick=axisthick,$
          charsize=charsize,charthick=axisthick,$
          title='n!De!N fluctuation amplitude',/nodata
    for ci=0,nprof-1 do begin
    ;  ind=where((z_list(ci,*) ge zrange(0)) and (z0_list(ci,*) le zrange(1)))
      ind=where((z_list(ci,*) gt 0))
      if (ind(0) ge 0) then oplot,z_list(ci,ind),fluc_list(ci,ind),color=col_list(ci),$
                            linestyle=ltype_list(ci),thick=linethick
      if (not keyword_set(noerror)) then begin
        w=!p.color
        if (keyword_set(color)) then begin
          !p.color=col_list(ci)
        endif
        w_thick=!p.thick
        !p.thick=linethick  
        errplot,z_list(ci,ind),fluc_l_list(ci,ind),fluc_h_list(ci,ind)                      
        !p.color=w
        !p.thick=w_thick
      endif  	
      if (keyword_set(lcfs)) then plots,[lcfs_list(ci),lcfs_list(ci)],nefluc_range,linestyle=2,/clip
    endfor
  endif
  
  if (figure_mask(4) ne 0) then begin
    if (not keyword_set(nocalibrated)) then begin
      plot,z_list(0,*),fluc_rel_list(0,*),xrange=zrange,xtitle='Z [cm]',xstyle=1,$
            ytitle=' ',yrange=nefluc_rel_range,ystyle=1,$
            position=pos5,/noerase,thick=linethick,xthick=axisthick,ythick=axisthick,$
            charsize=charsize,charthick=axisthick,$
            title='Rel. n!De!N fluctuation',/nodata 
      for ci=0,nprof-1 do begin
    ;    ind=where((z_list(ci,*) ge zrange(0)) and (z0_list(ci,*) le zrange(1)))
         ind=where((z_list(ci,*) gt 0))
        if (ind(0) ge 0) then oplot,z_list(ci,ind),fluc_rel_list(ci,ind),color=col_list(ci),$
                              linestyle=ltype_list(ci),thick=linethick
        if (not keyword_set(noerror)) then begin
          w=!p.color
          if (keyword_set(color)) then begin
            !p.color=col_list(ci)
          endif  
          !p.thick=linethick  
          errplot,z_list(ci,ind),fluc_rel_l_list(ci,ind),fluc_rel_h_list(ci,ind)                      
          !p.color=w
          !p.thick=w_thick
        endif  	
        if (keyword_set(lcfs)) then plots,[lcfs_list(ci),lcfs_list(ci)],nefluc_rel_range,linestyle=2,/clip
      endfor
    endif  
  endif
endif else begin   ; If r/a scale **********************
  if (figure_mask(0) ne 0) then begin
    plot,r_a0_list(0,*),ne_list(0,*),xrange=r_over_a_range,xtitle='r/a',xstyle=1,$
          ytitle='n!De!N [10!U19!N m!U-3!N]',yrange=ne_range,ystyle=1,$
          position=pos1,/noerase,thick=linethick,xthick=axisthick,ythick=axisthick,$
          charsize=charsize,charthick=axisthick,symsize=0.7,$
          title='Electron density',/nodata
    for ci=0,nprof-1 do begin
    ;  ind=where((z0_list(ci,*) ge zrange(0)) and (z0_list(ci,*) le zrange(1)))
      ind=where((z0_list(ci,*) gt 0))
      if (ind(0) ge 0) then oplot,r_a0_list(ci,ind),ne_list(ci,ind),color=col_list(ci),$
                            linestyle=ltype_list(ci),thick=linethick
      if (keyword_set(lcfs)) then plots,[lcfs_list(ci),lcfs_list(ci)],ne_range,linestyle=2,/clip
    endfor
    if (keyword_set(lcfs)) then plots,[1,1],ne_range,linestyle=2,/clip
  endif
  
  if (figure_mask(1) ne 0) then begin
    plot,r_a0_list(0,*),ne_list(0,*),xrange=r_over_a_range,xtitle='r/a',xstyle=1,$
          ytitle='n!De!N [10!U19!N m!U-3!N]',yrange=ne_log_range,ystyle=1,ytype=1,$
          position=pos1a,/noerase,thick=linethick,xthick=axisthick,ythick=axisthick,$
          charsize=charsize,charthick=axisthick,symsize=0.7,$
          title='Electron density',/nodata
    for ci=0,nprof-1 do begin
    ;  ind=where((z0_list(ci,*) ge zrange(0)) and (z0_list(ci,*) le zrange(1)))
      ind=where((z0_list(ci,*) gt 0))
      if (ind(0) ge 0) then oplot,r_a0_list(ci,ind),ne_list(ci,ind),color=col_list(ci),$
                            linestyle=ltype_list(ci),thick=linethick
    endfor
    if (keyword_set(lcfs)) then plots,[1,1],ne_log_range,linestyle=2,/clip
  endif
  
  if (figure_mask(2) ne 0) then begin
    if (not keyword_set(noli2p)) then begin
      plot,li2p_r_a_list(0,*),li2p_list(0,*),xrange=r_over_a_range,xtitle='r/a',xstyle=1,$
          ytitle='[a. u.]',yrange=li2p_range,ystyle=1,$
          position=pos2,/noerase,thick=linethick*2,xthick=axisthick,ythick=axisthick,$
          charsize=charsize,charthick=axisthick,$
          title='Li!D2p!N profile',/nodata
      for ci=0,nprof-1 do begin
    ;    ind=where((li2p_z_list(ci,*) ge zrange(0)) and (z0_list(ci,*) le zrange(1)))
        ind=where((li2p_z_list(ci,*) gt 0))
        if (ind(0) ge 0) then oplot,li2p_r_a_list(ci,ind),li2p_list(ci,ind),color=col_list(ci),$
                              linestyle=ltype_list(ci),thick=linethick
      endfor
      if (keyword_set(lcfs)) then plots,[1,1],li2p_range,linestyle=2,/clip
    endif
  endif
  
  if (figure_mask(3) ne 0) then begin
    plot,r_a_list(0,*),fluc_list(0,*),xrange=r_over_a_range,xtitle='r/a',xstyle=1,$
          ytitle=ytit,yrange=nefluc_range,ystyle=1,$
          position=pos4,/noerase,thick=linethick,xthick=axisthick,ythick=axisthick,$
          charsize=charsize,charthick=axisthick,$
          title='n!De!N fluctuation amplitude',/nodata
    for ci=0,nprof-1 do begin
    ;  ind=where((z_list(ci,*) ge zrange(0)) and (z0_list(ci,*) le zrange(1)))
      ind=where((z_list(ci,*) gt 0))
      if (ind(0) ge 0) then oplot,r_a_list(ci,ind),fluc_list(ci,ind),color=col_list(ci),$
                            linestyle=ltype_list(ci),thick=linethick
      if (not keyword_set(noerror)) then begin
        w=!p.color
        if (keyword_set(color)) then begin
          !p.color=col_list(ci)
        endif
        w_thick=!p.thick
        !p.thick=linethick  
        errplot,r_a_list(ci,ind),fluc_l_list(ci,ind),fluc_h_list(ci,ind)                      
        !p.color=w
        !p.thick=w_thick
      endif  	
    endfor
    if (keyword_set(lcfs)) then plots,[1,1],nefluc_range,linestyle=2,/clip
  endif  
  
  if (figure_mask(4) ne 0) then begin
    if (not keyword_set(nocalibrated)) then begin
      plot,r_a_list(0,*),fluc_rel_list(0,*),xrange=r_over_a_range,xtitle='r/a',xstyle=1,$
            ytitle=' ',yrange=nefluc_rel_range,ystyle=1,$
            position=pos5,/noerase,thick=linethick,xthick=axisthick,ythick=axisthick,$
            charsize=charsize,charthick=axisthick,$
            title='Rel. n!De!N fluctuation',/nodata 
      for ci=0,nprof-1 do begin
    ;    ind=where((z_list(ci,*) ge zrange(0)) and (z0_list(ci,*) le zrange(1)))
         ind=where((z_list(ci,*) gt 0))
        if (ind(0) ge 0) then oplot,r_a_list(ci,ind),fluc_rel_list(ci,ind),color=col_list(ci),$
                              linestyle=ltype_list(ci),thick=linethick
        if (not keyword_set(noerror)) then begin
          w=!p.color
          w_thick=!p.thick
          if (keyword_set(color)) then begin
            !p.color=col_list(ci)
          endif  
          !p.thick=linethick  
          errplot,r_a_list(ci,ind),fluc_rel_l_list(ci,ind),fluc_rel_h_list(ci,ind)                      
          !p.color=w
          !p.thick=w_thick
        endif  	
      endfor
      if (keyword_set(lcfs)) then plots,[1,1],nefluc_rel_range,linestyle=2,/clip
    endif
  endif
endelse

if (not keyword_set(notxt)) then begin
  for ci=0,nprof-1 do begin
    y=txt_top-ci*txt_linedist
    plots,[txt_xstart,txt_xstart+0.05],[y,y],color=col_list(ci),linestyle=ltype_list(ci),/normal
    xyouts,txt_xstart+0.06,y,txt_lab(ci),/normal
  endfor        
endif

if (keyword_set(reffscale)) then begin
  plot_reffscale,shot,zrange=zrange,position=pos5-[0,0.08,0,0.08],reff_res=reffscale,$
    linethick=axisthick,charthick=charthick
  plot_reffscale,shot,zrange=zrange,position=pos2-[0,0.08,0,0.08],reff_res=reffscale,$
    linethick=axisthick,charthick=charthick
endif    

end      

