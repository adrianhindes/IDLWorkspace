pro show_densprof,file,zrange=zrange,title=title,nolegend=nolegend,$
    nopara=nopara,lcfs=lcfs_in,errorproc=errorproc,linethick=linethick,$
    axisthick=axisthick,charsize=charsize,noerror=noerror,nolock=nolock,$
    reffscale=reffscale

; Plots density  profiles and density fluctuation profiles 

; reffsacle: plots Reff scale under Z scale id reffscale not 0. 
;             reffscale is the tick separation if Reff units

default,title,''

default,pos,[0.07,0.15,0.7,0.9] ; whole plot area
default,pos1,[0.07,0.55,0.32,0.85]  ; density profile
default,pos2,[0.07,0.15,0.32,0.45]    ; li2p and simulated li2p
default,pos4,[0.43,0.55,0.68,0.85]  ; dens fluct. amp
default,pos5,[0.43,0.15,0.68,0.45]  ; rel dens. fluct

default,linethick,1
default,axisthick,1
if (!d.name eq 'X') then default,charsize,1 else default,charsize,0.6

load_zztcorr,shot,k,ks,z,t,file=file,profile=profile,backgr_profile,$
             para_txt=para_txt,backtimefile=backtimefile,backgr_profile=backgr_profile,$
             channels=channels,tres=tres,trange=trange,/rec,matrix=matrix,$
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


default,zrange,[min(z0)-0.5,max(z0)+0.5]

if (keyword_set(lcfs_in)) then begin
  if (lcfs_in gt 30) then lcfs=get_lcfs(lcfs_in) else lcfs=lcfs_in
endif      

erase
if (not keyword_set(nolegend)) then time_legend,'show_densprof.pro'
if (not keyword_set(nopara)) then begin
  plots,[pos(2)+0.01,pos(2)+0.01],[0.1,0.9],thick=3,/normal
  xyouts,pos(2)+0.02,0.85,para_txt,/normal
endif
    
plot,z0,n0,xrange=zrange,xtitle='Z [cm]',xstyle=1,$
      ytitle='n!De!N/10!U19!N [m!U-3!N]',yrange=[0,max(n0)*1.05],ystyle=1,$
      position=pos1,/noerase,thick=linethick,xthick=axisthick,ythick=axisthick,$
      charsize=charsize,charthick=axisthick,symsize=0.7,$
      title='Electron density'
if (keyword_set(lcfs)) then plots,[lcfs,lcfs],[!y.crange(0),(!y.crange(1)-!y.crange(0))/2+!y.crange(0)],$
  linestyle=2,/clip

default,profile,0

if (keyword_set(backgr_profile) and (keyword_set(profile)) and (max(profile) gt 0) and keyword_set(p0)) then begin
  li2p=profile-backgr_profile
  ind=where(li2p gt max(li2p)/10)
  p00=p0(channels-1)
;  c=total(p00(ind)/li2p(ind))/n_elements(ind)
  loadxrr,xrr
  xrr0=xrr(channels-1)
  yr=[0,1.05*max([li2p,p0/c])]
  plot,xrr0,li2p,xrange=zrange,xtitle='Z [cm]',xstyle=1,$
      ytitle='[V]',yrange=yr,ystyle=1,$
      position=pos2,/noerase,thick=linethick*2,xthick=axisthick,ythick=axisthick,$
      charsize=charsize,charthick=axisthick,$
      title='Measured and simulated Li!D2p!N'
  oplot,xrr,p0/c,linestyle=0,thick=linethick
  if (keyword_set(lcfs)) then plots,[lcfs,lcfs],[!y.crange(0),(!y.crange(1)-!y.crange(0))/2+!y.crange(0)],$
      linestyle=2,/clip
endif

nz=(size(z))(1)
t0time=where(t eq 0)
flucprof=fltarr(nz)
for i=0,nz-1 do flucprof(i)=sign_sqrt(k(i,i,t0time))
flucp_l=fltarr(nz)
for i=0,nz-1 do flucp_l(i)=sign_sqrt(k(i,i,t0time)-ks(i,i,t0time))
flucp_h=fltarr(nz)
for i=0,nz-1 do flucp_h(i)=sign_sqrt(k(i,i,t0time)+ks(i,i,t0time))

if (c ne 0) then begin
;  flucprof=flucprof*c
;  flucp_l=flucp_l*c
;  flucp_h=flucp_h*c
  ytit='n!De!N fluct. amp. /10!U19!N [m!U-3!N]'
endif else begin  
  ytit='n!De!N fluct. amp. [a.u.]'
endelse
ind1=where((z ge zrange(0)) and (z le zrange(1)))
yr=[0,1.05*max(flucp_h(ind1))]
plot,z,flucprof,xrange=zrange,xtitle='Z [cm]',xstyle=1,$
      ytitle=ytit,yrange=yr,ystyle=1,$
      position=pos4,/noerase,thick=linethick,xthick=axisthick,ythick=axisthick,$
      charsize=charsize,charthick=axisthick,$
      title='n!De!N fluctuation amplitude'
if (not keyword_set(noerror)) then errplot,z,flucp_l,flucp_h
if (keyword_set(lcfs)) then plots,[lcfs,lcfs],[!y.crange(0),(!y.crange(1)-!y.crange(0))/2+!y.crange(0)],$
      linestyle=2,/clip
    
if (keyword_set(c)) then begin
  ind=where(n0 gt 0)
  rel=flucprof
  rel(*)=0
  rel_l=rel
  rel_h=rel
  rel(ind)=flucprof(ind)/n0(ind)
  rel_h(ind)=flucp_h(ind)/n0(ind)
  rel_l(ind)=flucp_l(ind)/n0(ind)
  ind1=where((z ge zrange(0)) and (z le zrange(1)))
  yr=[0,max(rel_h(ind1))]
  yr(1)=yr(1)<1
  yr(1)=yr(1)*1.05
  plot,z,rel,xrange=zrange,xtitle='Z [cm]',xstyle=1,$
        ytitle=' ',yrange=yr,ystyle=1,$
        position=pos5,/noerase,thick=linethick,xthick=axisthick,ythick=axisthick,$
        charsize=charsize,charthick=axisthick,$
        title='Rel. n!De!N fluctuation'
  if (not keyword_set(noerror)) then errplot,z,rel_l,rel_h
  if (keyword_set(lcfs)) then plots,[lcfs,lcfs],[!y.crange(0),(!y.crange(1)-!y.crange(0))/2+!y.crange(0)],$
        linestyle=2,/clip
endif

if (keyword_set(reffscale)) then begin
  plot_reffscale,shot,zrange=zrange,position=pos5-[0,0.08,0,0.08],reff_res=reffscale,$
    linethick=axisthick,charthick=charthick
  plot_reffscale,shot,zrange=zrange,position=pos2-[0,0.08,0,0.08],reff_res=reffscale,$
    linethick=axisthick,charthick=charthick
endif    
end







