pro loadcxrdat,sh=sh,ton=ton,toff=toff,t2off=t2off,type=type,img=img,subtype=subtype,timeoff=timeoff,timeper=timeper

lam=529.1e-9
db='c'

;Contrast (zeta) correction - using calibration file
if type eq 'cal' then begin
   db='c'
   imgdark=getimgnew(sh,0,db='calbg')*1.
   imglight=getimgnew(sh,0,db='cal')*1.
endif else if type eq 'whiteandcal' then begin
   db='k2'
;Contrast (zeta) correction - using calibration file
;sh='cxrstest4_tuni_white_cxrsfilter'
   shb=sh+'_black'

;; shc='cxrstest4_tuni_lasertr'
;; shcb=shc+'_black'

   imglight=getimgnew(sh,0,db=db)*1.0
   imgdark=getimgnew(shb,0,db=db)*1.0
endif else begin
   imglight=getimgnew(sh,twant=ton,db=db  )*1.0
   imgdark=getimgnew(sh,twant=t2off,db=db)*1.0
endelse

img=imglight-imgdark
if type eq 'cal' or type eq 'whiteandcal' then begin
   img0=img&sz=size(img,/dim)
   for i=0,sz(1)-1 do img(*,i)=median(img0(*,i),5)
   return
endif




img0=img&sz=size(img,/dim)
for i=0,sz(1)-1 do img(*,i)=median(img0(*,i),5)
idx=where(img gt 2000 or img lt 0)
if idx(0) ne -1 then img(idx)=0.

if keyword_set(tsub) then begin
   imglight=img
   loadcxrdat,sh=sh,ton=toff,toff=t2off,type=type,img=imgdarktmp
   default,timeoff, 10e-3
;default,timeper,str.dt
   if sh eq 9229 then default, timeper, 8e-3
   if sh eq 9240 then default, timeper, 29e-3
   toff_frac=(timeoff/timeper)<1
   imgdark = (imglight * (1-toff_frac) - imgdarktmp * 1) / toff_frac * (-1) ; sign error
;loadcxrdat,sh=sh,ton=ton,toff=toff,img=img,type='data'
   imgdiff=(imglight-imgdarktmp)/toff_frac
   if subtype eq 'diff' then img=imgdiff
   if subtype eq 'dark' then img=imgdark
endif

end
