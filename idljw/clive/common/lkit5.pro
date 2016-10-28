pro getdat, runnum, lam, d, kc,filt=filt,qty=qty,extr=extr
if runnum eq 0 then txt='' else txt=string(runnum,format='("_",I0)')
default,extr,''
if filt eq 1 then filttxt='_filtered' else filttxt=''
fil='~/idl/mdb/stark/runs/clive/output/data/hires_calc'+extr+filttxt+txt+'.xdr'
restore,file=fil,/verb

;if runnum le 1 and kc eq 1 then k=2 else 
k=kc

nlambda = n_elements(lambda)

    tnonzero  = where(tspec[*,k] gt  0.0,count)
    tpnonzero = where(tpspec[*,k] gt 0.0)

    tpfrac = fltarr(nlambda)
    tpfrac[tpnonzero] = tpspec[tpnonzero,k]/tspec[tpnonzero,k]
    tpint=fltarr(nlambda)
    tpint[tpnonzero] = tpspec[tpnonzero,k]/sqrt(tspec[tpnonzero,k])

;    plot,lambda(tpnonzero),tpfrac(tpnonzero)
;    oplot,lambda(tpnonzero),tpint(tpnonzero)/max(tpint(tpnonzero)),col=2
;    stop
    lam=lambda(tpnonzero)
    d=tpfrac(tpnonzero)
default,qty,'int'
if qty eq 'int' then d=tpint(tpnonzero) else $
  d=alpha(tpnonzero,k)*!radeg
;plot,lam,d,title=runnum
;stop
end

tab=[0,1,2,3,4,5,6]
fc=[0,1,5,10,2,3,4]
idx=sort(fc)
fc=fc(idx)
tab=tab(idx)
ns=n_elements(tab)
l0=[31.45,38.45,42.8]
qty='alpha'
filt=0
if filt eq 1 then filttxt='_filt' else filttxt='_nofilt'
mkfig,'~/figs/hires_ripple_scan_lamdep'+filttxt+'.eps',xsize=16,ysize=20,font_size=10

!p.multi=[0,3,4]
for tp=0,2 do begin
for k=0,2 do begin
    
    for i=0,ns-1 do begin
        extr=''
        if tp eq 1 and i gt 0 then extr='_sq'
        if tp eq 2 and i gt 0 then extr='_sin'
        tparr=['tri','sq','sin']
        getdat,tab(i),lam,d,k,qty=qty,filt=filt,extr=extr
;        if i eq 0 then     plot,lam,d else oplot,lam,d,col=i+1
        if i eq 0 then d2=fltarr(ns,n_elements(lam))
        if i eq 0 then lam0=lam
        d2(i,*)=interpol(d,lam,lam0)
        if i eq 0 then yc=d(value_locate(lam,l0(k)))
        chs=[1,17,29]
        thk=3
        if i eq 0 then plot, lam, d,$
        yr=yc+[-2,2],xr=l0(k)+[-.75,.75],xsty=1,ysty=1,$
                             title=tparr(tp)+' wave; channel #'+$
                             string(chs(k),format='(I0)'),$
                             xtitle='wavelength shift (A)',$
                             ytitle='pol. angle (deg)',thick=thk $
        else oplot, lam,d,col=i+1,thick=thk


    endfor
;    defcirc,/fill

endfor
endfor
plot,[1,1],[1,1],/nodata,xsty=4,ysty=4
        legend,string(fc,format='("ripple pp=",I0,"%")'),col=indgen(ns)+1,linesty=replicate(0,ns),textcolor=indgen(ns)+1

!p.multi=0

;mkfig,'~/figs/ripple_scan_contour.eps',xsize=12,ysize=9,font_size=10
;contourn2,d2,fc,lam0,xtitle='percent peak-peak modulation of triangle wave',ytitle='wavelength shift (A)',xsty=1,ysty=1,title='polarization fraction',/cb,/noni
endfig,/gs,/jp
end

