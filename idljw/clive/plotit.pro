pro plotit, d,x,y,t,par=par

if istag(par,'AUX') and (par.type eq 't' or par.type eq 'tx' or par.type eq 'ty') then begin
    npl=2
endif else npl=1

dotrans=0
d2d=0
if par.type eq 't' then begin
    ia=value_locate3(x,par.xw.vsel)*[1,1]
    ib=value_locate3(y,par.yw.vsel)*[1,1]
    ic=value_locate3(t,par.tw.vr)
    ax=t(ic(0):ic(1))
    xr=par.tw.vr
endif

if par.type eq 'x' then begin
    ia=value_locate3(x,par.xw.vr)
    ib=value_locate3(y,par.yw.vsel)*[1,1]
    ic=value_locate3(t,par.tw.vsel)*[1,1]
    ax=x(ia(0):ia(1))
    xr=par.xw.vr
endif

if par.type eq 'y' then begin
    ia=value_locate3(x,par.xw.vsel)*[1,1]
    ib=value_locate3(y,par.yw.vr)
    ic=value_locate3(t,par.tw.vsel)*[1,1]
    ax=y(ib(0):ib(1))
    xr=par.yw.vr
endif


if par.type eq 'xy' then begin
    ia=value_locate3(x,par.xw.vr)
    ib=value_locate3(y,par.yw.vr)
    ic=value_locate3(t,par.tw.vsel)*[1,1]
    ax=x(ia(0):ia(1))
    ay=y(ib(0):ib(1))
    xr=par.xw.vr
    yr=par.yw.vr
    d2d=1
endif

if par.type eq 'tx' then begin
    ia=value_locate3(x,par.xw.vr)
    ib=value_locate3(y,par.yw.vsel)*[1,1]
    ic=value_locate3(t,par.tw.vr)
    ax=t(ic(0):ic(1))
    ay=x(ia(0):ia(1))
    xr=par.tw.vr
    yr=par.xw.vr
    d2d=1
    dotrans=1
endif

if par.type eq 'ty' then begin
    ia=value_locate3(x,par.xw.vsel)*[1,1]
    ib=value_locate3(y,par.yw.vr)
    ic=value_locate3(t,par.tw.vr)
    ax=t(ic(0):ic(1))
    ay=y(ib(0):ib(1))
    xr=par.tw.vr
    yr=par.yw.vr
    d2d=1
    dotrans=1
endif


; if par.type eq 'r' then begin
;     ia=value_locate3(lam,par.lam1)*[1,1]
;     ib=value_locate3(r,par.rr)
;     ic=value_locate3(t,par.t1)*[1,1]
;     x=r(ib(0):ib(1))
;     xr=par.rr
; endif
; if par.type eq 'lam' then begin
;     ia=value_locate3(lam,par.lamr)
;     ib=value_locate3(r,par.r1)*[1,1]
;     ic=value_locate3(t,par.t1)*[1,1]
;     x=lam(ia(0):ia(1))
;     xr=par.lamr
; endif
; if par.type eq 'tr' then begin
;     ia=value_locate3(lam,par.lam1)*[1,1]
;     ib=value_locate3(r,par.rr)
;     ic=value_locate3(t,par.tr)
;     tp=1
;     d2d=1
;     x=t(ic(0):ic(1))
;     y=r(ib(0):ib(1))
;     xr=par.tr
;     yr=par.rr
; endif
; if par.type eq 'tlam' then begin
;     ia=value_locate3(lam,par.lamr)
;     ib=value_locate3(r,par.r1)*[1,1]
;     ic=value_locate3(t,par.tr)
;     tp=1
;     d2d=1
;     x=t(ic(0):ic(1))
;     y=lam(ia(0):ia(1))
;     xr=par.tr
;     yr=par.lamr
; endif
; if par.type eq 'lamr' then begin
;     ia=value_locate3(lam,par.lamr)
;     ib=value_locate3(r,par.rr)
;     ic=value_locate3(t,par.t1)*[1,1]
;     tp=0
;     d2d=1
;     x=lam(ia(0):ia(1))
;     y=r(ib(0):ib(1))
;     xr=par.lamr
;     yr=par.rr
; endif

pos=posarr(1,npl,0)
dp=d(ia(0):ia(1),ib(0):ib(1),ic(0):ic(1),*)
if dotrans eq 1 then dp=transpose(reform(dp))

if par.zropt eq 'var' then begin
    idx=where(finite(dp))
    zr=minmax(dp(idx))
endif else zr=par.zr

if d2d eq 0 then begin
    plot,ax,dp,yr=zr,ysty=1,xsty=1,xr=xr,pos=pos
endif
if d2d eq 1 then begin
    imgplot, dp,ax,ay,xr=xr,yr=yr,zr=zr,ysty=1,xsty=1,/cb,pos=pos
endif

if npl gt 1 then begin
;    if par.zropt eq 'var' then begin
        idx=where((par.aux.t ge xr(0)) and (par.aux.t le xr(1)))
        zr=minmax(par.aux.v(idx))
 ;   endif else zr=par.zraux
    plot,par.aux.t,par.aux.v,xr=xr,xsty=1,yr=zr,ysty=1,pos=posarr(/next),/noer
end

end
