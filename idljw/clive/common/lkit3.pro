pro getdat, runnum, lam, d, kc,qty=qty
if runnum eq 0 then txt='' else txt=string(runnum,format='("_",I0)')
fil='~/my_idl/stark/runs/clive/output/data/hires_calc_filtered'+txt+'.xdr'
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
    lam=lambda(tpnonzero)
    d=tpfrac(tpnonzero)
default,qty,'int'
if qty eq 'int' then d=tpint(tpnonzero) else $
  d=alpha(tpnonzero,k)*!radeg

end

tab=[0,1,2,3,4,5,6]
fc=[0,1,5,10,2,3,4]
idx=sort(fc)
fc=fc(idx)
tab=tab(idx)
ns=n_elements(tab)
l0=[31.45,38.45,42.8]
qty='alpha'
mkfig,'~/figs/hires_ripple_scan_'+qty+'_filt.eps',xsize=12,ysize=9,font_size=10

for k=0,2 do begin
    for i=0,ns-1 do begin
        getdat,tab(i),lam,d,k,qty=qty
;        if i eq 0 then     plot,lam,d else oplot,lam,d,col=i+1
        if i eq 0 then d2=fltarr(ns,n_elements(lam))
        if i eq 0 then lam0=lam
        d2(i,*)=interpol(d,lam,lam0)
    endfor
    defcirc,/fill
    if qty eq 'alpha' then d3=abs(d2-d2(0,value_locate(lam0,l0(k))))
    if qty eq 'int' then begin
        if k eq 0 then $
          plot,fc,d2(*,value_locate(lam0,l0(k))),xtitle='% p-p beam voltage ripple  [tri. wave]',ytitle=textoidl('polarized intensity @ \lambda=central \sigma'),psym=-8,title='Investigation of effect of beam ripple',yr=[0,0.8e5],ysty=1 $ ;,yr=[0,.6]
        else $
          oplot,fc,d2(*,value_locate(lam0,l0(k))),col=k+1,psym=-8
    endif 
    if qty eq 'alpha' then begin
        if k eq 0 then plot,fc,d3(*,value_locate(lam0,l0(k))),xtitle='% p-p beam voltage ripple  [tri. wave]',ytitle=textoidl('Change in Polarized angle @ \lambda=central \sigma (deg)'),psym=-8,title='Investigation of effect of beam ripple',yr=[0,.4] $
        else $
      oplot,fc,d3(*,value_locate(lam0,l0(k))),col=k+1,psym=-8
    endif
endfor
legend,['ch#1','ch#17','ch#29'],col=[1,2,3],textcol=[1,2,3],linesty=[0,0,0],/right
endfig,/gs,/jp


;mkfig,'~/figs/ripple_scan_contour.eps',xsize=12,ysize=9,font_size=10
;contourn2,d2,fc,lam0,xtitle='percent peak-peak modulation of triangle wave',ytitle='wavelength shift (A)',xsty=1,ysty=1,title='polarization fraction',/cb,/noni
;endfig,/gs,/jp
end

