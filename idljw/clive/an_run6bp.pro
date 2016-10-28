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


readpatcharr,st

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

mkfig,'~/prbp_fig.eps',xsize=13,ysize=21,font_size=9
!p.thick=3
plot,rad,isat>0,psym=4,pos=posarr(1,4,0,cnx=0.1,cny=0.05),title='isat',xtitle='R(m)'
;

plot,rad,vfl,psym=4,pos=posarr(/next),/noer,title='Floating potential + (plasma potential_correction)',ytitle='V',xtitle='R(m)'
oplot,rad,vfl+10. * 3.76,psym=4,col=2
oplot,rad,vfl+10. * 2.54,psym=4,col=3
legend,['Vfl','Vfl+3.76 *10eV','Vfl+2.54*10eV'],textcol=[1,2,3],box=0


plot,rad,vfl,psym=4,pos=posarr(/next),/noer,title='jana',ytitle='V',xtitle='R(m)'
oplot,rad,vpl,col=2,psym=4

plot,rad2,tesw,psym=4,pos=posarr(/next),/noer,title='Electron temp',xsty=1,xr=!x.crange,xtitle='R(m)',ytitle='Te(eV)'
;oplot,rad2,tebp,psym=5,col=2

plot,rad,lint,psym=4,pos=posarr(/next),/noer,title='central line av density',ytitle='phase/rad',xtitle='R(m)'
endfig,/gs,/jp

end
