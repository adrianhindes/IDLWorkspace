pro getdat, runnum, lam, d, kc,base=base
if runnum eq 0 then txt='' else txt=string(runnum,format='("_",I0)')
default,base,'orig_calc'
if base eq 'orig_calc' then extr='a' else extr=''
fil='~/my_idl/stark/runs/clive/output/data/'+base+txt+extr+'.xdr'
restore,file=fil,/verb

;'if runnum le 1 and kc eq 1 then k=2 else k=kc
k=kc
nlambda = n_elements(lambda)

    tnonzero  = where(tspec[*,k] gt  0.0,count)
    tpnonzero = where(tpspec[*,k] gt 0.0)

    tpfrac = fltarr(nlambda)
    tpfrac[tpnonzero] = tpspec[tpnonzero,k]/tspec[tpnonzero,k]
    tpint=fltarr(nlambda)
    tpint[tpnonzero] = tpspec[tpnonzero,k]/sqrt(tspec[tpnonzero,k])
;!p.multi=[0,1,2]
;    plot,lambda(tpnonzero),tpfrac(tpnonzero)
;    plot,lambda(tpnonzero),tpint(tpnonzero);/max(tpint(tpnonzero)),col=2
;!p.multi=0
;stop
    lam=lambda(tpnonzero)
    d=tpfrac(tpnonzero)
;    d=tpint(tpnonzero)
    d=alpha(tpnonzero,k)*!radeg
end

tab=['orig_calc','hires_calc']
fc=[5,20]
idx=sort(fc)
fc=fc(idx)
tab=tab(idx)
ns=n_elements(tab)
;l0=[31.45,43.5]
l0=[31.45,38.45,42.8]
mkfig,'~/figs/iter_scan_alpha_nofilt.eps',xsize=12,ysize=9,font_size=10

for k=0,2 do begin
    for i=0,ns-1 do begin
        getdat,2,lam,d,k,base=tab(i)
;        if i eq 0 then     plot,lam,d else oplot,lam,d,col=i+1
        if i eq 0 then lam0=linspace(28,42,1000);lam
        if i eq 0 then d2=fltarr(ns,n_elements(lam0))
        d2(i,*)=interpol(d,lam,lam0)
    endfor
    defcirc,/fill
    d3=abs(d2-d2(0,value_locate(lam0,l0(k))))
;    if k eq 0 then plot,fc,d2(*,value_locate(lam0,l0(k))),xtitle='# samples of ripple waveform',ytitle=textoidl('polarized intensity @ \lambda=central \sigma'),psym=-8,title='convergence test' ,yr=[0e4,2e5] $ ;,yr=[0,.6]
    if k eq 0 then plot,fc,d3(*,value_locate(lam0,l0(k))),xtitle='#samples of ripple waveform',ytitle=textoidl('Change in Polarized angle @ \lambda=central \sigma (deg)'),psym=-8,title='Convergence test',yr=[0,10] $
    else $
      oplot,fc,d3(*,value_locate(lam0,l0(k))),col=k+1,psym=-8
endfor
legend,['ch#1','ch#17','ch#29'],col=[1,2,3],textcol=[1,2,3],linesty=[0,0,0],/right
endfig,/gs,/jp


;mkfig,'~/figs/ripple_scan_contour.eps',xsize=12,ysize=9,font_size=10
;contourn2,d2,fc,lam0,xtitle='percent peak-peak modulation of triangle wave',ytitle='wavelength shift (A)',xsty=1,ysty=1,title='polarization fraction',/cb,/noni
;endfig,/gs,/jp
end

