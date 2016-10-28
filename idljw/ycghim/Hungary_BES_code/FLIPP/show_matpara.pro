pro show_matpara,matrix,errorproc=erroproc,lcfs=lcfs_in,nolegend=nolegend,zrange=zr,$
  title=title,nopara=nopara,matpath=matpath,color=color
                                           
;***************************************************************
; show_matpara.pro                   S. Zoletnik  7.9.1997
;***************************************************************
; Plots all parameters of the given correlation reconstruction
; M matrix. 
; matrix: file name of a matrix file (written  by calcm_corr.pro) 
;         in subdirectory matrix/
; errorproc: name of the error procedure for printing error messages
;            in a widget
; lcfs:  position of the last closed flux surface if >10 else get lcfs
; matpath: matrix file path (def: matrix/)
;*******************************************************************

default,matpath,'matrix/'

if (keyword_set(color)) then begin
  setfigcol
  linestyles=[0,0]
  colors=[1,2]
endif else begin 
  linestyles=[1,2]
  colors=[!p.color,!p.color]
endelse


openr,unit,matpath+matrix,error=error,/get_lun
if (error ne 0) then begin
  txt='Cannot open matrix file '+matpath+matrix+' !'
  if (keyword_set(errorproc)) then begin
    call_procedure,errorproc,txt,/forward
  endif else begin
    print,txt
  endelse
  return
endif  
close,unit
free_lun,unit

SHOT=0
T=0
MULTI=0
ZEFF=0
M=0
Z_VECT=0
N0=0
Z0=0
P0=0
P0R=0
TE=0
LIZ=0
LINE=0
LIZ_2P=0
LI2P=0
LIZ_TE=0
LITE=0
TIMEFILE_MX=0
BACKTIMEFILE_MX=0
TEMPFILE=0
CAL=0
CHANNELS_MX=0
SMOOTH=0
PROBE_AMP=0
restore,matpath+matrix
default,timefile,''
default,timefile_mx,timefile
default,backtimefile,''
default,backtimefile_mx,backtimefile
default,tempfile,''
beam_coordinates,shot,rr,zz,xrr
default,channels,0
default,channels_mx,channels

if (keyword_set(lcfs_in)) then begin
  if (lcfs_in lt 10) then begin
    w=get_lcfs(shot)
    if (w eq 0) then begin
      txt='Cannot get LCFS value for shot '+i2str(shot)
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,txt,/forward
      endif else begin
        print,txt
      endelse
    endif else begin
      lcfs=w
    endelse  
  endif else begin
    lcfs=lcfs_in
  endelse    
endif      


if (keyword_set(timefile_mx) and keyword_set(backtimefile_mx)) then begin
  txt='Density calculation parameters:!C'+$
      '  shot:'+i2str(shot)+'!C'+$
      '  timefile:'+timefile_mx+'!C'+$
      '  background timefile:'+backtimefile_mx+'!C'+$
      '  temperature file:'+tempfile+'!C'+$
      '  smooth factor:'+i2str(smooth)+'!C'+$
      '  channels:!C            '
  nn=0
  l=n_elements(channels_mx)
  for i=0,l-1 do begin
    txt=txt+i2str(channels_mx(i))
    if (i ne (l-1)) then begin
      txt=txt+','
      nn=nn+1
      if (nn ge 8) then begin
        txt=txt+'!C           '
        nn=0
      endif
    endif
  endfor
endif else begin

  txt='Density calculation parameters:!C'+$
      '  Data from Li-database!C'+$
      '  shot:'+i2str(shot)+'!C'+$
      '  time:'+string(t,format='(F5.3)')+'s'
  if (keyword_set(smooth)) then txt=txt+'!C  smooth factor:'+i2str(smooth)
endelse 

if (not keyword_set(liz)) then oldfile=1 else oldfile=0
default,liz,z0
default,line,n0
default,liz_2p,z0
default,li2p,p0
default,liz_te,z0
default,lite,te

erase
if (not keyword_set(nolegend)) then time_legend,'show_matpara.pro'
default,zr,[10,30]
plot,liz_2p,li2p,xrange=zr,xstyle=1,xtitle='Z [cm]',ytitle='Li2p light',$
title='Li2p light distribution',/noerase,pos=[0.1,0.6,0.4,0.9],ystyle=1,$
yrange=[0,max(li2p)*1.05]
if (keyword_set(lcfs)) then plots,[lcfs,lcfs],[!y.crange(0),(!y.crange(1)+!y.crange(0))/2],linestyle=2

if (not oldfile) then begin
  if (keyword_set(p0)) then begin
    oplot,xrr,p0,linestyle=linestyles(0),color=colors(0)
  endif
  
  if (keyword_set(p0r)) then begin  
    z1=min(liz)+2
    z2=max(liz)
    ind=where((xrr ge z1) and (xrr le z2))
    p0r_scale=p0r*total(p0(ind))/total(p0r(ind))
    oplot,xrr,p0r_scale,linestyle=linestyles(1),color=colors(1)
  endif
  top=0.9
  xstart=0.41
  ld=0.03
  plots,[xstart,xstart+0.04],[top,top],/normal
  xyouts,xstart+0.05,top,'Li!D2p!N',/normal
  top=top-ld
  if (keyword_set(p0)) then begin
    plots,[xstart,xstart+0.04],[top,top],linestyle=linestyles(0),color=colors(0),/normal
    xyouts,xstart+0.05,top,'p0',/normal,color=colors(0)
    top=top-ld
  endif  
  if (keyword_set(p0r)) then begin
    plots,[xstart,xstart+0.04],[top,top],linestyle=linestyles(1),color=colors(1),/normal
    xyouts,xstart+0.05,top,'p0r',/normal,color=colors(1)
  endif
endif
plot,liz_te,lite,xrange=zr,xstyle=1,xtitle='Z [cm]',ytitle='T!De!N [eV]',$
title='T!De!N distribution along Li-beam',/noerase,pos=[0.1,0.1,0.4,0.4],$
ystyle=1,yrange=[0,max(lite)*1.05]
if (keyword_set(lcfs)) then plots,[lcfs,lcfs],[!y.crange(0),(!y.crange(1)+!y.crange(0))/2],linestyle=2

yr=[0,max(line/1e13)*1.1]
plot,liz,line/1e13,xrange=zr,xstyle=1,xtitle='Z [cm]',ytitle='n!De!N [10!U19!Nm!U-3!N]',$
title='n!De!N distribution along Li-beam',/noerase,pos=[0.6,0.6,0.9,0.9],$
ystyle=1,yrange=yr
if (keyword_set(lcfs)) then plots,[lcfs,lcfs],[!y.crange(0),(!y.crange(1)+!y.crange(0))/2],linestyle=2
oplot,z_vect,replicate(yr(1)/1.1*1.05,(size(z_vect))(1)),psym=1

if (not oldfile) then begin
  oplot,z0,n0/1e13,linestyle=linestyles(1),color=colors(0)
  top=0.9
  xstart=0.91
  ld=0.03
  plots,[xstart,xstart+0.04],[top,top],/normal
  xyouts,xstart+0.05,top,'n!De!N',/normal
  top=top-ld
  plots,[xstart,xstart+0.04],[top,top],linestyle=linestyles(1),color=colors(0),/normal
  xyouts,xstart+0.05,top,'n0',/normal,color=colors(0)
endif




if (not keyword_set(nopara)) then begin
  if (keyword_set(title)) then txt=title+'!C!C'+txt
  xyouts,0.5,0.5,/normal,txt
                       
  ptxt='Matrix calculation parameters for matrix '+matrix+'!C'+$
  '  z_vect:!C'
  n=(size(z_vect))(1)
  for i=0,fix((n-1)/8) do begin
    i1=i*8
    i2=i1+7
    if (i2 gt n-1) then i2=n-1
    ptxt=ptxt+'    '
    for j=i1,i2 do ptxt=ptxt+string(z_vect(j),format='(F5.2)')+' '
    ptxt=ptxt+'!C'
  endfor
  if (tempfile ne '') then ptxt=ptxt+'  temperature file: '+tempfile+'!C'
  ptxt=ptxt+'  Z!Deff!N: '+string(zeff,format='(F3.1)')+'!C'
  if (multi ne 1) then begin
      txt=txt+'  n!De!N profile multiplied by '+string(multi,format='(F4.2)')+'!C'
  endif
  
  xyouts,0.5,0.25,/normal,ptxt
endif


end
