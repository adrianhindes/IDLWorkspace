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
qty='int'
filt=1
if filt eq 1 then filttxt='_filt' else filttxt='_nofilt'
mkfig,'~/figs/cmp_hires_ripple_scan_'+qty+filttxt+'.eps',xsize=12,ysize=9,font_size=10

for tp=0,4 do begin
for k=0,2 do begin
    
    for i=0,ns-1 do begin
        extr=''

        if tp eq 0 and i gt 0 then extr='_sin'
        if tp eq 1 and i gt 0 then extr='_spi'


;        if tp eq 1 and i gt 0 then extr='_sq'
;        if tp eq 2 and i gt 0 then extr='_sin'
;        if tp eq 3 and i gt 0 then extr='_spi'
;        if tp eq 4 and i gt 0 then extr='_hsi'

        getdat,tab(i),lam,d,k,qty=qty,filt=filt,extr=extr
;        if i eq 0 then     plot,lam,d else oplot,lam,d,col=i+1
        if i eq 0 then d2=fltarr(ns,n_elements(lam))
        if i eq 0 then lam0=lam
        d2(i,*)=interpol(d,lam,lam0)
    endfor
    defcirc,/fill
    if qty eq 'alpha' then d3=abs(d2-d2(0,value_locate(lam0,l0(k))))
    if filt eq 1 then yr1=[0,.8e5] else yr1=[0,2e5]
    thk=3
    if qty eq 'int' then begin
        psarr=[-8,-5,-6,-7,-4]
        if k eq 0 and tp eq 0 then $
          plot,fc,d2(*,value_locate(lam0,l0(k))),xtitle='% p-p beam voltage ripple  [tri. wave]',ytitle=textoidl('polarized intensity @ \lambda=central \sigma'),psym=psarr(tp),title='Investigation of effect of beam ripple',yr=yr1,ysty=1,thick=thk $
         else $
          oplot,fc,d2(*,value_locate(lam0,l0(k))),col=k+1,psym=psarr(tp),linesty=tp,thick=thk
    endif 
    if qty eq 'alpha' then begin
        mn=0.01
        if k eq 0 and tp eq 0 then plot,fc,d3(*,value_locate(lam0,l0(k)))>mn,xtitle='% p-p beam voltage ripple  [tri. wave]',ytitle=textoidl('Change in Polarized angle @ \lambda=central \sigma (deg)'),psym=psarr(tp),title='Investigation of effect of beam ripple',yr=[.01,100],thick=thk,/ylog,yticklen=1,ygridstyle=3 $
        else $
      oplot,fc,d3(*,value_locate(lam0,l0(k)))>mn,col=k+1,psym=psarr(tp),linesty=tp,thick=thk
    endif
endfor
endfor
legendarr,['ch#1','ch#17','ch#29'],['tri','sq','sin'],col=[1,2,3],linesty=[0,1,2],psym=psarr,right=qty eq 'int'
endfig,/gs,/jp


;mkfig,'~/figs/ripple_scan_contour.eps',xsize=12,ysize=9,font_size=10
;contourn2,d2,fc,lam0,xtitle='percent peak-peak modulation of triangle wave',ytitle='wavelength shift (A)',xsty=1,ysty=1,title='polarization fraction',/cb,/noni
;endfig,/gs,/jp
end

