pro update_corr_list,shot,rec=rec,dens=dens,file=file,channels=channels,trange=trange,tres=tres,$
    cut_length=cut_length,timefile=timefile,autocorr_cut=autocorr_cut,nofix1=nofix1,nofix2=nofix2,$
    matrix=matrix,data_source=data_source,delete=delete,list=list,rename_from=rename_from,$
    experiment=experiment
		
;*********************************************************************************
; update_corr_list.pro                  S. Zoletnik 9.9.97
;*********************************************************************************
; Updates the correlation file list zzt/<shot>_lst.sav by adding one more
; correlation file described by the input parameters. If there was previously
; no list file than creates one. In this case the parameters supported are not used.
; /delete: deletes the named file from the list otherwise adds
; rename_from: file name which is renamed to <file>
;*********************************************************************************

default,experiment,''
                
if (not keyword_set(shot)) then shot=long(file)
if (keyword_set(experiment)) then basefile = experiment else basefile=i2str(shot,digits=5)
if (not keyword_set(list)) then begin
  openr,unit,'zzt/'+basefile+'_lst.sav',error=error,/get_lun
  if (error ne 0) then begin 
    make_corr_list,shot,list,experiment=experiment
    return 
  endif else begin
    close,unit
    free_lun,unit
    restore,'zzt/'+basefile+'_lst.sav'
  endelse
endif

if (((where(strlowcase(tag_names(list)) eq 'nofix1'))(0) lt 0) or $
    ((where(strlowcase(tag_names(list)) eq 'nofix2'))(0) lt 0)) then begin
  n=n_elements(list)
  l={filename: 'x',$
     shot: 33333.0,$
     channel_mask: fltarr(28),$
     timefile: 'x',$
     tres: 1.0,$
     trange: [-1.0, 1.0],$
     cut_length: 5.0,$
     data_source: 0,$
     autocorr_cut: 1.0,$
     matrix: 'x',$
     density_flag: 0,$
     nofix1: 0,$
     nofix2: 0}
  l=replicate(l,n)
  for i=0,n-1 do begin
    l.filename=list.filename
    l.shot=list.shot
    l.channel_mask=list.channel_mask
    l.timefile=list.timefile
    l.tres=list.tres
    l.trange=list.trange
    l.cut_length=list.cut_length
    l.data_source=list.data_source
    l.autocorr_cut=list.autocorr_cut
    l.matrix=list.matrix
    l.density_flag=list.density_flag
    l.nofix1=0
    l.nofix2=0
  endfor      
  list=l
endif

if ((where(strlowcase(tag_names(list)) eq 'simdens_flag'))(0) lt 0) then begin
  n=n_elements(list)
  l={filename: 'x',$
     shot: 33333.0,$
     channel_mask: fltarr(28),$
     timefile: 'x',$
     tres: 1.0,$
     trange: [-1.0, 1.0],$
     cut_length: 5.0,$
     data_source: 0,$
     autocorr_cut: 1.0,$
     matrix: 'x',$
     density_flag: 0,$
     nofix1: 0,$
     nofix2: 0,$
     simdens_flag: 0}
  l=replicate(l,n)
  for i=0,n-1 do begin
    l.filename=list.filename
    l.shot=list.shot
    l.channel_mask=list.channel_mask
    l.timefile=list.timefile
    l.tres=list.tres
    l.trange=list.trange
    l.cut_length=list.cut_length
    l.data_source=list.data_source
    l.autocorr_cut=list.autocorr_cut
    l.matrix=list.matrix
    l.density_flag=list.density_flag
    l.nofix1=list.nofix1
    l.nofix2=list.nofix2
    l.simdens_flag=0
  endfor      
  list=l
endif
													 
if ((where(strlowcase(tag_names(list)) eq 'experiment'))(0) lt 0) then begin
  n=n_elements(list)
  l={filename: 'x',$
     shot: 33333.0,$
     channel_mask: fltarr(28),$
     timefile: 'x',$
     tres: 1.0,$
     trange: [-1.0, 1.0],$
     cut_length: 5.0,$
     data_source: 0,$
     autocorr_cut: 1.0,$
     matrix: 'x',$
     density_flag: 0,$
     nofix1: 0,$
     nofix2: 0,$
     simdens_flag: 0,$
     experiment: '   '}
  l=replicate(l,n)
  for i=0,n-1 do begin
    l.filename=list.filename
    l.shot=list.shot
    l.channel_mask=list.channel_mask
    l.timefile=list.timefile
    l.tres=list.tres
    l.trange=list.trange
    l.cut_length=list.cut_length
    l.data_source=list.data_source
    l.autocorr_cut=list.autocorr_cut
    l.matrix=list.matrix
    l.density_flag=list.density_flag
    l.nofix1=list.nofix1
    l.nofix2=list.nofix2
    l.simdens_flag=0
		l.experiment=''
  endfor      
  list=l
endif

if (keyword_set(delete)) then begin
 ind=where(list.filename ne file)
 if (ind(0) lt 0) then begin
   spawn,'rm zzt/'+basefile+'_lst.sav'
 endif  
 list=list(ind)
 save,list,file='zzt/'+basefile+'_lst.sav'
 return
endif    

if (keyword_set(rename_from)) then begin
  ind=where(list.filename eq rename_from)
  if (ind(0) lt 0) then begin
    print,'update_corr_list: Cannot find correlation file in list to rename.'
    return
  endif
  ind1=where(list.filename ne file)
  list(ind).filename=file
  list=list(ind1)
  save,list,file='zzt/'+basefile+'_lst.sav'
  return
endif  
    
list=[list,list(0)]
n=(size(list))(1)-1
list(n).filename=file
list(n).shot=shot
list(n).channel_mask(*)=0
list(n).channel_mask(channels-1)=1
list(n).timefile=timefile
list(n).tres=tres
list(n).trange=trange
list(n).cut_length=cut_length
list(n).data_source=data_source
list(n).experiment=experiment
if (keyword_set(rec)) then begin
  list(n).density_flag=1           
  list(n).autocorr_cut=autocorr_cut
  list(n).matrix=matrix
  list(n).nofix1=nofix1
  list(n).nofix2=nofix2
endif else begin  
  list(n).density_flag=0
  list(n).autocorr_cut=-1
  list(n).matrix=''
  list(n).nofix1=0
  list(n).nofix2=0
endelse
if (keyword_set(dens)) then begin
  list(n).simdens_flag=1
endif else begin
  list(n).simdens_flag=0
endelse
  
    
save,list,file='zzt/'+basefile+'_lst.sav'

end
    

