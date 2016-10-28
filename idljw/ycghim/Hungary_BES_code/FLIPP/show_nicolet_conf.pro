pro show_nicolet_conf,shot,shotrange=shotrange,shotlist=shotlist,$
    nolegend=nolegend,data_source=data_source

default,shot,0
default,data_source,0

if ((data_source ne 0) and (data_source ne 5)) then begin
  print,'show_nicolet_conf works only for data_source 0 or 5!'
  return
endif  

if (not keyword_set(shotlist)) then begin
  if (keyword_set(shotrange)) then begin
    shotlist=findgen(shotrange(1)-shotrange(0)+1)+shotrange(0)
  endif else begin
    shotlist=[shot]
  endelse
endif

n=n_elements(shotlist)
sigtbl=strarr(n,28)
extsamp_tbl=fltarr(n)
for i=0,n-1 do begin
  r=meas_config(shotlist(i),channel_list=ch,signal_list=sig,/silent,$
                ext_fsample=ext_fsample,data_source=data_source)
  sigtbl(i,*)='       '
  sigtbl(i,ch-1)=sig
  default,ext_fsample,0
  extsamp_tbl(i)=ext_fsample
endfor

font=!p.font
if (!d.name eq 'X') then begin
  charsize=0.8
  !p.font=-1  
  lmarg=0.003
endif else begin
  charsize=0.5
  !p.font=-1  
  lmarg=0.001
endelse  
bmarg=0.007
sign=(size(sigtbl))(2)
xstart=0
ytop=0.95
ld=0.025
sigw=0.89/sign
shotw=0.04
extw=0.06
headh=0.03
xend=xstart+shotw+sigw*sign+extw
pagelen=35
np=fix(n/pagelen)+1
for ip=0,np-1 do begin
  i1=ip*pagelen
  i2=(ip+1)*pagelen-1
  if (i2 gt n-1) then i2=n-1
  erase
  if (not keyword_set(nolegend)) then time_legend,'show_nicolet_conf.pro'
  get_rawsignal,data_names=syst_names
  xyouts,0.1,ytop+0.01,'Channel setup for '+syst_names(data_source)
  ybott=ytop-headh-ld*(i2-i1+1)
  plots,[xstart,xend,xend,xstart,xstart],[ytop,ytop,ybott,ybott,ytop],/normal
  xyouts,xstart+lmarg,ytop-headh+bmarg,'Shot',/normal,charsize=charsize
  for isig=0,sign-1 do begin
    if (isig lt 16) then nic='1/' else nic='2/'
    xyouts,xstart+shotw+isig*sigw+lmarg,ytop-headh+bmarg,nic+i2str((isig mod 16)+1),$
          /normal,charsize=charsize
    plots,[xstart+shotw+isig*sigw,xstart+shotw+isig*sigw],[ytop,ybott],/normal
  endfor  
  plots,[xstart+shotw+sign*sigw,xstart+shotw+sign*sigw],[ytop,ybott],/normal
  xyouts,xstart+lmarg+shotw+sign*sigw,ytop-headh+bmarg,'Ext. samp.',/normal,$
        charsize=charsize
  for i=i1,i2 do begin
    yh=ytop-headh-(i-i1)*ld
    yl=ytop-headh-(i-i1+1)*ld
    plots,[xstart,xend],[yh,yh],/normal
    xyouts,xstart+lmarg,yl+bmarg,i2str(shotlist(i)),/normal,charsize=charsize
    for isig=0,sign-1 do begin
      xyouts,xstart+shotw+isig*sigw+lmarg,ytop-headh-(i-i1+1)*ld+bmarg,sigtbl(i,isig),$
          /normal,charsize=charsize
    endfor
    if (extsamp_tbl(i) ne 0) then begin
      ss=(1./extsamp_tbl(i))/1e-6
      xyouts,xstart+lmarg+shotw+sign*sigw,ytop-headh-(i-i1+1)*ld+bmarg,$
         string(ss,format='(F6.3)')+'!7l!Xs',/normal,charsize=charsize
    endif     
  endfor
  if ((ip ne np-1) and (!d.name eq 'X')) then begin
    if (not ask('Continue?')) then return
  endif  
endfor
font=font
end   
