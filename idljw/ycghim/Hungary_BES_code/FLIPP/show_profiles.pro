pro show_profiles,file,shot=shot,zrange=zrange,title=title,nolegend=nolegend,$
    nopara=nopara,lcfs=lcfs_in,errorproc=errorproc,thick=thick,$
    charsize=charsize,noerror=noerror,nolock=nolock,axisthick=axisthick,linethick=linethick,$
    data_source=data_source,chan_prefix=chan_prefix,chan_postfix=chan_postfix,cut_length=cut_length,tres=tres


; Plots light profiles and fluctuation profiles from pre-calculated data stored in a zzt file
; Either the name of a zzt file has to be given (file) or parameters of the calculation which are used for
; selecting a suitable zzt file.


default,data_source,fix(local_default('data_source'))
default,title,''

if (!d.name eq 'X') or (strupcase(!d.name) eq 'WIN') then begin
  default,pos,[0.07,0.15,0.7,0.9] ; whole plot area
  default,pos1,[0.07,0.7,0.27,0.9]  ; total and li2p
  default,pos2,[0.35,0.7,0.55,0.9]    ; background
  default,pos4,[0.07,0.4,0.27,0.6]  ; fluct. amp
  default,pos5,[0.07,0.1,0.27,0.3]  ; rel. fluct. amp
  default,pos6,[0.35,0.4,0.55,0.6]    ; background fluct
  default,pos7,[0.35,0.1,0.55,0.3]    ; rel background fluct
  default,pos8,[0.58,0.75,0.7,0.9]    ; Li2p/backgr
  default,pos9,[0.58,0.45,0.7,0.6]    ; Li2p/backgr fluct
endif else begin
  default,pos,[0,0.15,0.7,0.9] ; whole plot area
  default,pos1,[0,0.7,0.2,0.9]  ; total and li2p
  default,pos2,[0.3,0.7,0.5,0.9]    ; background
  default,pos4,[0,0.4,0.2,0.6]  ; fluct. amp
  default,pos5,[0,0.1,0.2,0.3]  ; rel. fluct. amp
  default,pos6,[0.3,0.4,0.5,0.6]    ; background fluct
  default,pos7,[0.3,0.1,0.5,0.3]    ; rel background fluct
  default,pos8,[0.53,0.75,0.7,0.9]    ; Li2p/backgr
  default,pos9,[0.53,0.45,0.7,0.6]    ; Li2p/backgr fluct
endelse

default,thick,1
default,linethick,thick
default,axisthick,thick

if (!d.name eq 'X') then begin
  default,charsize,1
endif else begin
  if(!d.name eq 'PS') then default,charsize,0.8 else default,charsize,0.8
endelse

load_zztcorr,shot,k,ks,z,t,file=file,profile=profile,backgr_profile,$
             para_txt=para_txt,backtimefile=backtimefile,backgr_profile=backgr_profile,$
             channels=channels,tres=tres,trange=trange,chan_prefix=chan_prefix,chan_postfix=chan_postfix,$
             cut_length=cut_length,data_source=data_source,nolock=nolock
if ((size(k))(0) eq 0) then begin
  txt='Cannot open data file!'
  if (keyword_set(errorproc)) then begin
    call_procedure,errorproc,txt,/forward
  endif else begin
    print,txt
  endelse
  return
endif

nz=(size(z))(1)
t0time=where(t eq 0)
flucprof=fltarr(nz)
for i=0,nz-1 do flucprof(i)=sign_sqrt(k(i,i,t0time))
flucp_l=fltarr(nz)
for i=0,nz-1 do flucp_l(i)=sign_sqrt(k(i,i,t0time)-ks(i,i,t0time))
flucp_h=fltarr(nz)
for i=0,nz-1 do flucp_h(i)=sign_sqrt(k(i,i,t0time)+ks(i,i,t0time))

default,zrange,[min(z)-(max(z)-min(z))*0.05,max(z)+(max(z)-min(z))*0.05]

if (keyword_set(lcfs_in)) then begin
  if (lcfs_in gt 30) then lcfs=get_lcfs(lcfs_in) else lcfs=lcfs_in
endif

erase
if (not keyword_set(nolegend)) then time_legend,'show_profiles.pro'
if (not keyword_set(nopara)) then begin
  plots,[pos(2)+0.01,pos(2)+0.01],[0.1,0.9],thick=3,/normal
  xyouts,pos(2)+0.02,0.85,para_txt,/normal
endif

if (keyword_set(profile)) then begin
  if (keyword_set(backgr_profile)) then begin
    tit='Mean and beam light'
  endif else begin
    tit='Mean light'
  endelse
  plotsymbol,0
  plot,z,profile,xrange=zrange,xtitle='Z [cm]',xstyle=1,$
        ytitle='[V]',yrange=[0,max(profile)*1.05],ystyle=1,$
        position=pos1,/noerase,thick=linethick,xthick=axisthick,ythick=axisthick,$
        charsize=charsize,charthick=axisthick,psym=-8,symsize=0.7,$
        title=tit
  if (keyword_set(lcfs)) then plots,[lcfs,lcfs],[!y.crange(0),(!y.crange(1)-!y.crange(0))/2+!y.crange(0)],$
    linestyle=2,/clip
  if (keyword_set(backgr_profile)) then begin
    li2p=profile-backgr_profile
    oplot,z,li2p,thick=linethick
    plot,z,backgr_profile,xrange=zrange,xtitle='Z [cm]',xstyle=1,$
        ytitle='[V]',yrange=[0,max(backgr_profile)*1.05],ystyle=1,$
        position=pos2,/noerase,thick=linethick,xthick=axisthick,ythick=axisthick,$
        charsize=charsize,charthick=axisthick,$
        title='Background light + offset'
    if (keyword_set(lcfs)) then plots,[lcfs,lcfs],[!y.crange(0),(!y.crange(1)-!y.crange(0))/2+!y.crange(0)],$
        linestyle=2,/clip

    p=li2p
    p(*)=30
    ind=where(backgr_profile gt 0)
    p(ind)=li2p(ind)/backgr_profile(ind)
    yr=[0,max(p)<20]
    yr(1)=yr(1)*1.05
    plot,z,p,xrange=zrange,xtitle='Z [cm]',xstyle=1,$
        ytitle=' ',yrange=yr,ystyle=1,$
        position=pos8,/noerase,thick=linethick,xthick=axisthick,ythick=axisthick,$
        charsize=charsize*0.8,charthick=axisthick,$
        title='Li!D2p!N/(backgr.+offs.)'
    if (keyword_set(lcfs)) then plots,[lcfs,lcfs],[!y.crange(0),(!y.crange(1)-!y.crange(0))/2+!y.crange(0)],$
        linestyle=2,/clip

  endif
endif

plotsymbol,0
yr=[0,max(flucp_h)*1.05]
plot,z,flucprof,xrange=zrange,xtitle='Z [cm]',xstyle=1,$
      ytitle='[V]',yrange=yr,ystyle=1,$
      position=pos4,/noerase,thick=linethick,xthick=axisthick,ythick=axisthick,$
      charsize=charsize,charthick=axisthick,$
      title='Fluctuation amplitude'
if (not keyword_set(noerror)) then errplot,z,flucp_l,flucp_h
if (keyword_set(lcfs)) then plots,[lcfs,lcfs],[!y.crange(0),(!y.crange(1)-!y.crange(0))/2+!y.crange(0)],$
  linestyle=2,/clip


if (keyword_set(profile)) then begin
  ind1=where(profile gt 0)
  rfluc1=flucprof(ind1)/profile(ind1)
  rfluc1_l=flucp_l(ind1)/profile(ind1)
  rfluc1_h=flucp_h(ind1)/profile(ind1)
  yr=[0,max(rfluc1_h)]
  if (keyword_set(li2p)) then begin
    ind=where(li2p gt 0)
    rfluc=flucprof(ind)/li2p(ind)
    rfluc_l=flucp_l(ind)/li2p(ind)
    rfluc_h=flucp_h(ind)/li2p(ind)
    yr=[0,max([rfluc_h,rfluc1_h])]
  endif
  yr(1) = yr(1) < 1
  yr(1)=yr(1)*1.05
  plotsymbol,0
  plot,z(ind1),rfluc1,xrange=zrange,xtitle='Z [cm]',xstyle=1,$
        ytitle='Rel. amplitude ',yrange=yr,ystyle=1,$
        position=pos5,/noerase,thick=linethick,xthick=axisthick,ythick=axisthick,$
        charsize=charsize,charthick=axisthick,psym=-8,symsize=0.7,$
        title='Relative fluctuation'
  if (not keyword_set(noerror)) then errplot,z,rfluc1_l,rfluc1_h
  if (keyword_set(rfluc)) then begin
    oplot,z(ind),rfluc,thick=linethick
    if (not keyword_set(noerror)) then errplot,z,rfluc_l,rfluc_h
  endif
  if (keyword_set(lcfs)) then plots,[lcfs,lcfs],[!y.crange(0),(!y.crange(1)-!y.crange(0))/2+!y.crange(0)],$
    linestyle=2,/clip
endif

if (backtimefile ne '') then begin
  load_zztcorr,shot,k,ks,z,t,timefile=backtimefile,$
             para_txt=para_txt,tres=tres,$
             cut_length=cut_length,data_source=data_source,nolock=nolock
  if ((size(k))(0) ne 0) then begin
    if (not keyword_set(nopara)) then begin
      para_txt='Background time:!C!C'+para_txt
      xyouts,pos(2)+0.02,0.45,para_txt,/normal
    endif

    nz=(size(z))(1)
    t0time=where(t eq 0)
    bflucprof=fltarr(nz)
    bflucp_l=fltarr(nz)
    bflucp_h=fltarr(nz)
    for i=0,nz-1 do bflucprof(i)=sign_sqrt(k(i,i,t0time))
    for i=0,nz-1 do bflucp_l(i)=sign_sqrt(k(i,i,t0time)-ks(i,i,t0time))
    for i=0,nz-1 do bflucp_h(i)=sign_sqrt(k(i,i,t0time)+ks(i,i,t0time))
     plot,z,bflucprof,xrange=zrange,xtitle='Z [cm]',xstyle=1,$
      ytitle='[V]',yrange=[0,max(bflucp_h)*1.05],ystyle=1,$
      position=pos6,/noerase,thick=linethick,xthick=axisthick,ythick=axisthick,$
      charsize=charsize,charthick=axisthick,$
      title='Background fluctuation'
    if (not keyword_set(noerror)) then errplot,z,bflucp_l,bflucp_h
    if (keyword_set(lcfs)) then plots,[lcfs,lcfs],[!y.crange(0),(!y.crange(1)-!y.crange(0))/2+!y.crange(0)],$
      linestyle=2,/clip

    ind1=where(backgr_profile gt 0)
    rfluc1=bflucprof(ind1)/backgr_profile(ind1)
    rfluc1_l=bflucp_l(ind1)/backgr_profile(ind1)
    rfluc1_h=bflucp_h(ind1)/backgr_profile(ind1)
    yr=[0,max(rfluc1_h)]
    if (yr(1) gt 1) then yr(1)=1
    yr(1)=yr(1)*1.05
    plot,z(ind1),rfluc1,xrange=zrange,xtitle='Z [cm]',xstyle=1,$
      ytitle='Rel. amplitude ',yrange=yr,ystyle=1,$
      position=pos7,/noerase,thick=linethick,xthick=axisthick,ythick=axisthick,$
      charsize=charsize,charthick=axisthick,$
      title='Relative backgr. fluctuation'
    if (not keyword_set(noerror)) then errplot,z,rfluc1_l,rfluc1_h

    ind=where(bflucprof gt 0)
    rr=flucprof
    rr(*)=30
    rr(ind)=flucprof(ind)/bflucprof(ind)
    yr=[0,max(rr)<20]
    yr(1)=yr(1)*1.05
    plot,z,rr,xrange=zrange,xtitle='Z [cm]',xstyle=1,$
        ytitle='',yrange=yr,ystyle=1,$
        position=pos9,/noerase,thick=linethick,xthick=axisthick,ythick=axisthick,$
        charsize=charsize*0.8,charthick=axisthick,$
        title='Total/backgr. fluct.'
    if (keyword_set(lcfs)) then plots,[lcfs,lcfs],[!y.crange(0),(!y.crange(1)-!y.crange(0))/2+!y.crange(0)],$
        linestyle=2,/clip



  endif
endif



end
