@pr_prof2
;goto,ee

sh=[82823,intspace(82811,82819)]
nsh=n_elements(sh)
rad=fltarr(nsh)
isat=fltarr(nsh)
vfl=fltarr(nsh)
vpl=fltarr(nsh)
lint=fltarr(nsh)
for i=0,nsh-1 do begin
readpatchpr,sh(i),str,data=data,file='BPP_FP_settings.csv'
rad(i)=str.bpprad

isat(i)=getpar(sh(i),'isat',tw=[.03,.04],data=data)
vfl(i)=getpar(sh(i),'vfloat',tw=[.03,.04],data=data)
vpl(i)=getpar(sh(i),'vplasma',tw=[.03,.04],data=data)
lint(i)=getpar(sh(i),'lint',tw=[.03,.04],data=data)

endfor
;plot,rad,vpl,psym=4,pos=posarr(/next),/noer,title='vpl'


;readpatcharr,st

mask = st.kh eq 0.83 and st.satsw eq 'sw' and st.date eq '13-MAR-2014' and st.shot ge 82080
ii=where(mask)
n2=n_elements(ii)
tesw=fltarr(n2)
tebp=fltarr(n2)
rad2=st(ii).rad
tw=[0.03,0.04]
for i=0,n2-1 do begin
   twm=tw
   if i eq 3 then twm-=0.01
   probe_charnew,st(ii(i)).shot,tavg=twm,varthres=1e9,filterbw=1e3/2,qty='tesw',/doplot,qavg=dum,qst=dum2  & tesw((i))=dum
;   if st(ii(i)).shot eq 82127 then stop
   probe_charnew,st(ii(i)).shot,tavg=twm,varthres=1e9,filterbw=1e3,qty='tebp',qavg=dum,qst=dum2 & tebp((i))=dum 
;   stop
endfor

mkfig,'~/prbp_pot.eps',xsize=13,ysize=13,font_size=10
!p.thick=3
;plot,rad,isat>0,psym=4,pos=posarr(1,4,0,cnx=0.1,cny=0.05),title='Saturation current',xtitle='R(m)',ytitle='(mA)'
;

;plot,rad,vfl,psym=4,pos=posarr(/next),/noer,title='Floating potential + (plasma potential_correction)',ytitle='V',xtitle='R(m)'
;oplot,rad,vfl+10. * 3.76,psym=4,col=2
;oplot,rad,vfl+10. * 2.54,psym=4,col=3
;legend,['Vfl','Vfl+3.76 *10eV','Vfl+2.54*10eV'],textcol=[1,2,3],box=0

idx=sort(rad)

efl=deriv2(rad(idx),vfl(idx),rr)
exbfl=efl/0.5 / 1e3

epl=deriv2(rad(idx),vpl(idx))
exbpl=epl/0.5 / 1e3


plot,rad(idx),vfl(idx),psym=-4,title='Potential',ytitle='V',xtitle='R(m)',symsize=2,pos=posarr(1,2,0,cny=0.1,cnx=0.1)
oplot,rad(idx),vpl(idx),col=2,psym=-4,symsize=2
legend,[textoidl('V_{floating}'),textoidl('V_{plasma}')],textcol=[1,2],box=0,charsize=2

plot,rr,exbfl,psym=-4,ytitle=textoidl('v_{ExB} (km/s)'),title=textoidl('v_{ExB}'),xtitle='R(m)',symsize=2,pos=posarr(/next),/noer
oplot,rr,exbpl,col=2,psym=-4,symsize=2


endfig,/gs,/jp

end
