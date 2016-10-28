@pr_prof2
nsh=3
shot1=86722+findgen(4);4;edge
;shot1=[86658,86651,86644,86636,86621,86584,86629]+2
x=[0,1,2,3]
tesw=fltarr(nsh)
tebp=tesw
vpl=tesw
telr=tesw
isat=tesw
twm=[.04,.05]
jj=0
   for i=0,nsh-1 do begin
      aa=99
      probe_charnew,shot1(i),tavg=twm,varthres=1e9,filterbw=1e3,qty='tesw',qavg=dum,qst=dum2,doplot=jj eq aa  & tesw(i)=dum & if jj eq aa then stop
      probe_charnew,shot1(i),tavg=twm,varthres=1e9,filterbw=1e3,qty='tebp',qavg=dum,qst=dum2  & tebp(i)=dum
      probe_charnew,shot1(i),tavg=twm,varthres=1e9,filterbw=1e3,qty='isatsw',qavg=dum,qst=dum2  & isat(i)=dum

      gethelrnew,shot1(1),dum & telr(i)=dum
     

      vpl(i)= getpar(shot1(i), 'vplasma', tw=twm)
   endfor


plot,x,tesw,title='tesw',psym=-5,pos=posarr(1,3,0),yr=[-0,20]
oplot,x,tebp,psym=-4,col=2
oplot,x,telr,psym=-6,col=3
plot,x,isat,title='isat',psym=-5,pos=posarr(/next),/noer
plot,x,vpl,title='vpl',pos=posarr(/next),/noer,psym=-4
!p.multi=0
end
