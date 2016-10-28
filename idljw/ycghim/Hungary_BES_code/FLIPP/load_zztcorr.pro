pro load_zztcorr,sht,k,kscat,z,t,outfscale,outpower3,outpwscat3,outphase3,help=help,rec=rec,old=old,file=file,$
    omit=omit,channels=channels_in,trange=trange_in,tres=tres_in,$
    cut_length=cut_length_in,timefile=timefile_in,autocorr_cut=autocorr_cut_in,$
    matrix=matrix_in,z0=z0,n0=n0,p0=p0,li2p_rec=p0r,te=te,silent=silent,data_source=data_source_in,$
    para_txt=para_txt,profile=profile,calfac=calfac,backtimefile=backtimefile,$
    backgr_profile=backgr_profile,probe_amp=probe_amp,proct1=proct1,proct2=proct2,procn=procn,$
    abs_calfac=abs_calfac,nolock=nolock,nodata=nodata,noscale=noscale,nofix1=nofix1_in,nofix2=nofix2_in,$
    density=dens,experiment=experiment,twodimensional=twodim,errormess=errormess,$
    ztitle=ztitle,chan_prefix=chan_prefix,chan_postfix=chan_postfix,comment=comment

;******************* load_zztcorr.pro ****************** S. Zoletnik ********************
; Read space-space-time correlation function written by zztcorr.pro
; /rec: read reconstructed correlation
; If <file> is given then data will be read from that file, otherwise the correlation file
; which parameters first match the given parameters (shot,tres,trange....) will be read.
; For density correlation files the correlations will be scaled (if profile data are available)
; to to absolute units, where density is measured in 1x10^13 cm-3 units. If data are scaled
; then <abs_calfac> returns the calibration factor. (Factor to multiply profile with to get same scale
; as <li2p_rec>.)
;
; Can read 2D calculation results as well. (see zzptcorr.pro) but in this case the file argument
; has to be given.
;
; INPUT:
; file: read from this file
; omit: list of time values which will be erased
; channels: list of channels (1...28) for which crosscorrelation data is
;           to be loaded. If not specified than a list of channels is
;           returned for which crosscorrelation data is available
; /nodata: do not read correlation function just determine filename
; /twodim: read data from twodimensional measurement (needed only if file name is not set)
; OUTPUT:
; k,ks,z,t: the 3D correlation and its error
; z: spatial scale
; t: time lag scale
; outfscale: frequency scale
; outpower3: The 3D crosspower spectrum
; outpwscat3: The error of the crosspower
; outphase3: The 3D crossphase spectrum
; para_txt: a string including all parameters of the calculation (for plotting using xyouts)
; profile: light profile if found in data file
; calfac: calibration factors found in data file
; backtimefile: the name of the background time file or ''
; proct1, proct2, procn: time intervals of correlation calculation
; abs_calfac: For abs. calibrated density correlation data this is the cal. factor, othetwise 0
; /nolock: do not lock resource zzt/lock
; /noscale: do not scale density correlation to absolute units
; /density: read simulated density data
; ztitle: Title of Z axis
; errormess: error message or ''
;***************************************************************************************

default,nolock,1
default,backtimefile,''
errormess = ''

abs_calfac=0

if (not keyword_set(file) and not keyword_set(sht) and not keyword_set(experiment)) then help=1

if (keyword_set(help)) then begin
 print,'Usage: load_zztcorr,sht,k,ks,z,t[,/rec][file=...][omit=time list] [channels=..'
	print,'  Loads z-z-t cross-correlation function, its error and scales'
	print,'  Looks for files in zzt/'
	return
endif

if (defined(timefile_in)) then tfset=1 else tfset=0
if (defined(tres_in)) then tresset=1 else tresset=0
if (defined(trange_in)) then trangeset=1 else trangeset=0
if (defined(cut_length_in)) then clset=1 else clset=0
if (defined(data_source_in)) then dsset=1 else dsset=0
if (keyword_set(rec)) then begin
  if (defined(matrix_in)) then matset=1 else matset=0
  if (defined(autocorr_cut_in)) then autocutset=1 else autocutset=0
endif
if (defined(nofix1_in)) then nofix1_set=1 else nofix1_set=0
if (defined(nofix2_in)) then nofix2_set=1 else nofix2_set=0
if (defined(chan_prefix)) then chan_prefix_set = 1 else chan_prefix_set = 0
if (defined(chan_postfix)) then chan_postfix_set = 1 else chan_postfix_set = 0
if (not keyword_set(nolock)) then lock,'zzt/lock',60


if (not keyword_set(file)) then begin
  if (keyword_set(experiment)) then basefile=experiment else basefile=i2str(sht,digits=5)
  if (keyword_set(rec)) then begin
    fbase=basefile+'.zzt_ne_rec.sav'
  endif
  if (keyword_set(dens)) then begin
    fbase=basefile+'.zzt_ne_sim.sav'
  endif
	if (keyword_set(twodim)) then begin
	  file = basefile+'.zzpt.sav.0'
		openr,unit,dir_f_name('zzt',file),error=error,/get_lun
		if (error ne 0) then begin
    	k=0
			errormess = 'No correlation function found with the specified parameters.'
    	if (not keyword_set(silent)) then $
			  print,errormess,' 1'
      	if (not keyword_set(nolock)) then unlock,'zzt/lock'
    	return
  	endif
		close,unit & free_lun,unit
	endif else begin
  	default,fbase,basefile+'.zzt.sav'
  	openr,unit,dir_f_name('zzt',basefile+'_lst.sav'),error=error,/get_lun
  	if (error ne 0) then begin
  	  make_corr_list,sht,list,experiment=experiment
 		endif else begin
	    close,unit
	    free_lun,unit
	    restore,dir_f_name('zzt',basefile+'_lst.sav')
	    if ((where(strlowcase(tag_names(list)) eq 'simdens_flag'))(0) lt 0) then begin
	      spawn,'rm zzt/'+basefile+'_lst.sav'
	      make_corr_list,sht,list,experiment=experiment
	    endif
	  endelse
	  if (not keyword_set(list)) then begin
	    k=0
	    errormess = 'No correlation function found with the specified parameters.'
	    if (not keyword_set(silent)) then $
	      print,errormess,' 2'
	      if (not keyword_set(nolock)) then unlock,'zzt/lock'
	    return
	  endif
	  mask=intarr((size(list))(1))
	  mask(*)=1
	  if (keyword_set(rec)) then begin
	    ind=where(list.density_flag eq 0)
	  endif
	  if (keyword_set(dens)) then begin
	    ind=where(list.simdens_flag eq 0)
	  endif
	  if (not keyword_set(dens) and not keyword_set(rec)) then begin
	    ind=where((list.density_flag ne 0) or (list.simdens_flag ne 0))
	  endif
	  if (ind(0) ge 0) then mask(ind)=0
	  if (tfset) then begin
	    ind=where(list.timefile ne timefile_in)
	    if (ind(0) ge 0) then mask(ind)=0
	  endif
	  if (tresset) then begin
	    ind=where(list.tres ne tres_in)
	    if (ind(0) ge 0) then mask(ind)=0
	  endif
	  if (trangeset) then begin
	    ind=where((list.trange(0) gt trange_in(0)) or (list.trange(1) lt trange_in(1)))
	    if (ind(0) ge 0) then mask(ind)=0
	  endif
	  if (chan_prefix_set) then begin
	    ind=where(list.chan_prefix ne chan_prefix)
	    if (ind(0) ge 0) then mask(ind)=0
	  endif
	  if (chan_postfix_set) then begin
	    ind=where(list.chan_postfix ne chan_postfix)
	    if (ind(0) ge 0) then mask(ind)=0
	  endif
	  if (clset) then begin
	    ind=where(list.cut_length ne cut_length_in)
	    if (ind(0) ge 0) then mask(ind)=0
	  endif
	  if (dsset) then begin
	    ind=where(list.data_source ne data_source_in)
	    if (ind(0) ge 0) then mask(ind)=0
	  endif
	  if (keyword_set(rec)) then begin
	    if (matset) then begin
	      ind=where(list.matrix ne matrix_in)
	      if (ind(0) ge 0) then mask(ind)=0
	    endif
	    if (autocutset) then begin
	      ind=where(list.autocorr_cut ne autocorr_cut_in)
	      if (ind(0) ge 0) then mask(ind)=0
	    endif
	    if (nofix1_set) then begin
	      if ((where(strlowcase(tag_names(list)) eq 'nofix1'))(0) ge 0) then begin
	        ind=where(list.nofix1 ne nofix1_in)
	        if (ind(0) ge 0) then mask(ind)=0
	      endif else begin  ; no nofix1 tag
	        if (nofix1_in ne 0) then mask(*)=0
	      endelse
	    endif
	    if (nofix2_set) then begin
	      if ((where(strlowcase(tag_names(list)) eq 'nofix2'))(0) ge 0) then begin
	        ind=where(list.nofix2 ne nofix2_in)
	        if (ind(0) ge 0) then mask(ind)=0
	      endif else begin  ; no nofix2 tag
	        if (nofix2_in ne 0) then mask(*)=0
	      endelse
	    endif
	  endif
	  if (keyword_set(channels_in)) then begin
	    nch=(size(channels_in))(1)
	    index=where(total(list.channel_mask(channels_in-1),1) ne nch)
	    if (ind(0) ge 0) then mask(ind)=0
	  endif
	  ind=where(mask ne 0)
	  if (ind(0) lt 0) then begin
	    k=0
	    errormess = 'No correlation function found with the specified parameters.'
	    if (not keyword_set(silent)) then $
	      print,errormess,' 3'
	    if (not keyword_set(nolock)) then unlock,'zzt/lock'
	    return
	  endif
	  file=list(ind(0)).filename
	  if (keyword_set(nodata)) then begin
	    if (not keyword_set(nolock)) then unlock,'zzt/lock'
	    return
	  endif
	endelse
endif

notfound=1
i=0
while (notfound) do begin
  if (keyword_set(file)) then begin
    fn=file
  endif else begin
    fn=fbase+'.'+i2str(i)
  endelse
  openr,unit,dir_f_name('zzt',fn),error=error,/get_lun
  if (error ne 0) then begin
    k=0
    errormess = 'No correlation function found with the specified parameters.'
    if (not keyword_set(silent)) then $
      print,errormess,' 4'
    if (not keyword_set(nolock)) then unlock,'zzt/lock'
    return
  endif
  close,unit
  free_lun,unit
  store_freq=0
  restore,dir_f_name('zzt',fn)
       default,ztitle,'???'
	if (keyword_set(plot_r)) then begin
	  ; This is a 2D measurement
		k = total(korr_ref,3)/(size(korr_ref))[3]
		kscat = sqrt(total(korrs_ref^2,3)/(size(korrs_ref))[3])
		z = ref_beam
		t = t_vect_ref
		tres = tres_ref
		trange = trange_ref
		shot = exp[0].shot
		timefile = exp[0].timefile
		backtimefile = exp[0].backtimefile
		profile = total((lightprof_ref),1)/(size(lightprof_ref))[1]
		backgr_profile = total((lightprof_back),1)/(size(lightprof_ref))[1]
	  notfound=0
	  default,data_source,0
	  default,calfac,0
	  default,backtimefile,''
	  default,backgr_profile,0
	  if (keyword_set(rec)) then t=t_ne
	  default,timefile,'???'
	  default,tres,t(1)-t(0)
	  default,trange,[min(t),max(t)]
	  default,cut_length,-1
	  default,timefile_in,timefile
	  default,tres_in,tres
	  default,trange_in,trange
	  default,cut_length_in,cut_length
	  default,data_source_in,data_source
	  default,fitorder,2
	  default,baseline_function,'baseline_poly'
	  default,lowcut,0
	  if (keyword_set(rec)) then begin
	    default,matrix_in,matrix
	    default,autocorr_cut_in,autocorr_cut
	    default,nofix1,0
	    default,nofix1_in,nofix1
	    default,nofix2,0
	    default,nofix2_in,nofix2
	  endif else begin
	    nofix1=0
	    nofix2=0
	    nofix1_in=nofix1
	    nofix2_in=nofix2
	  endelse
	endif else begin
	  ; This is a 1D measurement
	  default,data_source,0
	  default,calfac,0
	  default,backtimefile,''
	  default,backgr_profile,0
	  if (keyword_set(rec)) then t=t_ne
	  default,timefile,'???'
		if (n_elements(t) le 1) then begin
			k = 0
			errormess = 'Correlation time lag vector has only one element!'
			if (not keyword_set(silent)) then print,errormess
			return
		endif
	  default,tres,t(1)-t(0)
	  default,trange,[min(t),max(t)]
	  default,cut_length,-1
	  default,timefile_in,timefile
	  default,tres_in,tres
	  default,trange_in,trange
	  default,cut_length_in,cut_length
	  default,data_source_in,data_source
	  default,fitorder,2
	  default,baseline_function,'baseline_poly'
	  default,lowcut,0
	  if (keyword_set(rec)) then begin
	    default,matrix_in,matrix
	    default,autocorr_cut_in,autocorr_cut
	    default,nofix1,0
	    default,nofix1_in,nofix1
	    default,nofix2,0
	    default,nofix2_in,nofix2
	  endif else begin
	    nofix1=0
	    nofix2=0
	    nofix1_in=nofix1
	    nofix2_in=nofix2
	  endelse

      default,comment,''
	  notfound=0
	  if (not keyword_set(file)) then begin
	    if (tfset and (timefile_in ne timefile)) then notfound=1
	    if (tresset and (tres_in ne tres)) then notfound=1
	    if (trangeset and ((trange_in(0) lt trange(0)) or (trange_in(1) gt trange(1)))) then notfound=1
	    if (clset and (cut_length_in ne cut_length)) then notfound=1
	    if (dsset and (data_source_in ne data_source)) then notfound=1
	    if (keyword_set(rec)) then begin
	      if (matset and (matrix_in ne matrix)) then notfound=1
	      if (autocutset and (autocorr_cut_in ne autocorr_cut)) then notfound=1
	      if (nofix1_set and (nofix1_in ne nofix1)) then notfound=1
	      if (nofix2_set and (nofix2_in ne nofix2)) then notfound=1
	    endif
	  endif
	endelse

  if (not notfound) then begin
    if (keyword_set(channels_in)) then begin
      chn=(size(channels_in))(1)
      for chi=0,chn-1 do begin
        ind=where(channels_in(chi) eq channels)
        if ((size(ind))(0) eq 0) then begin
         print,'There is no crosscorrelation data for channel '+i2str(channels_in(chi))
        endif else begin
          if (not defined(ind_zzt)) then begin
            ind_zzt=ind(0)
          endif else begin
            ind_zzt=[ind_zzt,ind(0)]
          endelse
        endelse
      endfor
      if ((size(ind_zzt))(1) ne chn) then begin
        if (keyword_set(file)) then begin
          k=0
          errormess = 'Crosscorrelation not found for some channels.'
					if (not keyword_set(silent)) then print,errormess
          if (not keyword_set(nolock)) then unlock,'zzt/lock'
          return
        endif else begin
          notfound=1
        endelse
      endif else begin
        k=k(ind_zzt,ind_zzt,*)
        kscat=kscat(ind_zzt,ind_zzt,*)
        z=z(ind_zzt)
        profile=profile(ind_zzt)
        backgr_profile=backgr_profile(ind_zzt)
      endelse
    endif else begin
      channels_in=channels
    endelse
  endif
  i=i+1
endwhile

if (keyword_set(experiment)) then begin
  if (not keyword_set(exp)) then begin
    exp=load_experiment(experiment,errormess=errormess)
    if (errormess ne '') then begin
			k = 0
			return
		endif
  endif
  sht = exp[0].shot
endif


if (keyword_set(rec)) then begin
	k=zzt_ne
	if (keyword_set(zzt_ne_scat)) then kscat=zzt_ne_scat else kscat=float(0)
	z=z_ne
	t=t_ne
  if (keyword_set(p0r) and keyword_set(profile) and keyword_set(backgr_profile)) then begin
    if ((max(profile) gt 0) and (max(backgr_profile) gt 0) and (max(p0r) gt 0)) then begin
      li2p=profile-backgr_profile
      ind=where(li2p gt max(li2p)/10)
      if (ind(0) ge 0) then begin
        p00=p0r(channels-1)
        abs_calfac=total(p00(ind)/li2p(ind))/n_elements(ind)
        if (not keyword_set(noscale)) then begin
          k=k*(abs_calfac^2)
          kscat=kscat*(abs_calfac^2)
        endif
      endif
    endif
  endif
endif

if (defined(omit)) then begin
  ind=findgen(n_elements(t))
	no=n_elements(omit)
	for i=0,no-1 do begin
	  ind=ind((where(t(ind) ne omit(i))))
	endfor
  if (n_elements(ind) ne n_elements(t)) then begin
	  t=t(ind)
		k=k(*,*,ind)
		kscat=kscat(*,*,ind)
	endif
endif

file=fn
timefile_in=timefile
cut_length_in=cut_length
tres_in=tres
trange_in=trange
data_source_in=data_source
if (not keyword_set(experiment)) then begin
  if (keyword_set(shot)) then sht=shot else sht=long(strmid(fn,0,5))
endif else begin
	default,shot,0
endelse
if (not keyword_set(channels_in)) then channels_in=channels
nofix1_in=nofix1
nofix2_in=nofix2
if (keyword_set(experiment)) then begin
  para_txt='experiment: '+experiment
endif else begin
  para_txt='shot: '+i2str(sht,digits=5)
endelse
if (keyword_set(rec)) then begin
  para_txt=para_txt+'!CDensity correlations'
endif
if (keyword_set(dens)) then begin
  para_txt=para_txt+'!CSimulated density correlations'
endif
if (not keyword_set(dens) and not keyword_set(rec)) then  begin
  para_txt=para_txt+'!CRaw signal correlations'
endif
default,timerange,0
if (n_elements(timerange) ge 2) then begin
  para_txt=para_txt+'!Ctimerange:!C  ('+string(timerange[0],format='(F5.3)')+$
                    '-'+string(timerange[1],format='(F5.3)')+')'
endif
if (timefile ne '') then begin
  para_txt=para_txt+'!Ctimefile: '+timefile+'!C         '
  openr,unit,dir_f_name('time',timefile),error=error,/get_lun
  if (error ne 0) then begin
    para_txt=para_txt+'(??? - ???)'
  endif else begin
    close,unit
    free_lun,unit
    w=loadncol('time/'+timefile,2,/silent)
    ind=where((w(*,0) ne 0) or (w(*,1) ne 0))
    if (ind(0) ge 0) then w=w(ind,*)
    para_txt=para_txt+'('+string(min(w),format='(F5.3)')+$
                      '-'+string(max(w),format='(F5.3)')+')'
  endelse
endif
if (backtimefile ne '') then begin
  para_txt=para_txt+'!Cbackgr. time: '+backtimefile+'!C         '
  openr,unit,dir_f_name('time',backtimefile),error=error,/get_lun
  if (error ne 0) then begin
    para_txt=para_txt+'(??? - ???)'
  endif else begin
    close,unit
    free_lun,unit
    w=loadncol('time/'+backtimefile,2,/silent)
    ind=where((w(*,0) ne 0) or (w(*,1) ne 0))
    if (ind(0) ge 0) then w=w(ind,*)
    para_txt=para_txt+'('+string(min(w),format='(F5.3)')+$
                      '-'+string(max(w),format='(F5.3)')+')'
  endelse
endif
para_txt=para_txt+'!Ctau resolution: '+string(tres,format='(F6.2)')+' microsec'
para_txt=para_txt+'!Ctau range: ['+i2str(trange(0))+','+i2str(trange(1))+'] microsec'
para_txt=para_txt+'!Cphoton noise cut length: '+i2str(cut_length)+' microsec'
para_txt=para_txt+'!Cfres='+string(fres,format='(E10.1)')
if defined(interval_n) then para_txt=para_txt+'!Cinterval_n='+i2str(interval_n)
para_txt=para_txt+'!Cbaseline_function: '+baseline_function
para_txt=para_txt+'!Cfitorder: '+i2str(fitorder)
para_txt=para_txt+'!Cchannels:'
nn=0
l=n_elements(channels_in)
for i=0,l-1 do begin
  para_txt=para_txt+i2str(channels_in(i))
  if (i ne (l-1)) then begin
    para_txt=para_txt+','
    nn=nn+1
    if (nn ge 8) then begin
      para_txt=para_txt+'!C         '
      nn=0
    endif
  endif
endfor
if (defined(chan_prefix)) then para_txt=para_txt+'!Cchan_prefix: '+chan_prefix
if (defined(chan_postfix)) then para_txt=para_txt+'!Cchan_postfix: '+chan_postfix
get_rawsignal,data_names=data_names
wt=data_names(data_source)
para_txt=para_txt+'!Cdata source: '+wt
if (keyword_set(rec)) then begin
  matrix_in=matrix
  autocorr_cut_in=autocorr_cut
  para_txt=para_txt+'!Crec. matrix: '+matrix
  para_txt=para_txt+'!Cautocorr. cut: '+i2str(autocorr_cut)
  if (autocorr_cut ge 0) then para_txt=para_txt+' microsec'
  if ((nofix1 ne 0) or (nofix2 ne 0)) then begin
    para_txt=para_txt+'!C'
    if (nofix1) then para_txt=para_txt+' /nofix1'
    if (nofix2) then para_txt=para_txt+' /nofix2'
  endif
endif
if (defined(comment)) then begin
  para_txt=para_txt+'!C!C'+comment
endif
para_txt=para_txt+'!C!Ccorr. file: '+fn

if (not keyword_set(nolock)) then unlock,'zzt/lock'

end

