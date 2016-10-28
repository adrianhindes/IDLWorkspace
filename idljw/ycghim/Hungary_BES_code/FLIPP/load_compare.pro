pro load_compare,filelist,txtlist,get_lcfs=lcfs,errorproc=errorproc,nolock=nolock,$
   from_file=from_file,z0_list=z0_list,z_list=z_list,ne_list=ne_list,$
   li2p_list=li2p_list,li2p_z_list=li2p_z_list,fluc_list=fluc_list,fluc_l_list=fluc_l_list,$
   fluc_h_list=fluc_h_list,fluc_rel_list=fluc_rel_list,fluc_rel_l_list=fluc_rel_l_list,$
   fluc_rel_h_list=fluc_rel_h_list,lcfs_list=lcfs_list,txt_lab=txt_lab,nocalibrated=nocalibrated,$
   timefile_list=timefile_list,shot_list=shot_list

; ******** load_compare.pro *************************** S. Zoletnik 22.6.1998 ****************
; Loads several data files for comparison.
;
; filelist: string array containing the reconstructed density crosscorrelation files to process
; txtlist: optional string array with texts for marking the curves of the files
; from_file: an optional filename from which the filelist and txtlist arrays are read:
;                <1st file-name>  [<1st text>]
;                <2nd file-name>  [<1nd text>]
;                  ...
; /lcfs: get LCFS values
; OUTPUT:
;    xxx_list: output lists
;     z0_list: z values for density profile
;     z_list: z values for fluctuation data
;     li2p_z_list: z values for Li2p light profile
;    nocalibrated: set if at least one of the profile is not absolutely calibrated
; *******************************************************************************************

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

nprof=n_elements(filelist)

z0_list=fltarr(nprof,200)
z_list=fltarr(nprof,50)
ne_list=fltarr(nprof,200)
li2p_list=fltarr(nprof,200)
li2p_z_list=fltarr(nprof,50)
fluc_list=fltarr(nprof,50)
fluc_l_list=fltarr(nprof,50)
fluc_h_list=fltarr(nprof,50)
fluc_rel_list=fltarr(nprof,50)
fluc_rel_l_list=fltarr(nprof,50)
fluc_rel_h_list=fltarr(nprof,50)
lcfs_list=fltarr(nprof)
txt_lab=strarr(nprof)
timefile_list=strarr(nprof)
shot_list=lonarr(nprof)

for ci=0,nprof-1 do begin

  file=filelist(ci)
  if (n_elements(txtlist) ge ci+1) then begin
    if (txtlist(ci) ne '') then txt_lab(ci)=txtlist(ci) else txt_lab(ci)=file
  endif else begin
    txt_lab(ci)=file
  endelse  

  channels=0
  load_zztcorr,shot,k,ks,z,t,file=file,profile=profile,backgr_profile,timefile=timefile,$
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
  
  if (keyword_set(lcfs)) then begin
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
  timefile_list(ci) = timefile
  shot_list(ci)=shot
endfor
   
end      


