@~/idl/clive/probe_charnew
@~/idl/clive/readpatcharr

function getpar, sh, par, tw=tw,y=y,st=st
mdsopen,'h1data',sh
if par eq 'lint' then begin
;   y=mdsvalue2('\H1DATA::TOP.ELECTR_DENS.NE_HET:NE_CENTRE',/nozero)
   demodsw,sh,10,yy,tt & y={v:yy,t:tt}
endif
if par eq 'lint2' then begin
;   y=mdsvalue2('\H1DATA::TOP.ELECTR_DENS.NE_HET:NE_9',/nozero)
   demodsw,sh,2,yy,tt & y={v:yy,t:tt}
endif

if par eq 'isat' then begin
   readpatchpr,sh,str
   nd='\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_'+string(str.isatdig,format='(I0)')
   y=mdsvalue2(nd,/nozero) & y.v*=1/str.isatrm / str.ampgain4
   print,str.ampgain4

endif
if par eq 'vfloat' then begin
   readpatchpr,sh,str
   nd='\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_'+string(str.vfldig,format='(I0)')
   y=mdsvalue2(nd,/nozero) & y.v*=str.vflgain/str.ampgain3;250/5;

endif

if par eq 'vplasma' then begin
   readpatchpr,sh,str,file='BPP_FP_settings.csv',data=data
   nd='\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_'+string(str.vpldig,format='(I0)')
   y=mdsvalue2(nd,/nozero) & y.v*=str.vpldr/str.vplgain;ampgain3;250/5;

endif


mdsclose

idx=where(y.t ge tw(0) and y.t le tw(1))
val=mean(y.v(idx))
st=stdev(y.v(idx))
return,val
end

tw=[0.03,0.04];-0.01

 
;readpatcharr,st
goto,ee2
 goto,start

ii=where($ 
1 $;(st.kh eq 0.83 or st.kh eq 0.9 or st.kh eq 0.75 or st.kh eq 0.74) 
and st.satsw eq 'sat' and st.good eq 'a' and st.rad eq 1.24)
;ii=ii(3:*)
;st.date eq '13-MAR-2014' and st.shot ge 82080

ii=ii(sort(st(ii).kh))
print,st(ii).shot
print,st(ii).kh

n=n_elements(ii)
pos=posarr(2,1,0)

for i=0,n-1 do begin
   dum=getpar(st(ii(i)).shot,'vfloat',y=y,tw=[0,1])
   if i eq 0 then yy=fltarr(n_elements(y.v),n)
   yy(*,i)=y.v
endfor

plotm,y.t,yy,pos=pos

ix=where(y.t ge 0.03 and y.t le 0.04)
s=yy(ix,*)*0
for i=0,n-1 do s(*,i)=smooth(abs(fft(yy(ix,i)))^2,20)
f=fft_t_to_f(y.t(ix))
plotm,f,alog10(s),pos=posarr(/next),/noer,xr=[10,100e3];,yr=[-13,-7];,/xlog
print,st(ii).kh
legend,string(st(ii).kh,format='(G0)'),textcol=findgen(n_elements(ii))+1,/bottom,box=0



retall
start:


kha=[0.9,0.83,0.8,0.76,.75,0.74,0.73,0.72,0.71,0.7]
nk=n_elements(kha)
nn=n_elements(st)
mask=bytarr(nn)
for aa=0,nk-1 do begin
mask1 = st.kh eq kha(aa) and st.satsw eq 'sat'  and st.good eq 'a'; and st.date eq '13-MAR-2014'and st.shot ge 82080

mask=mask or mask1
endfor
ii=where(mask)

n=n_elements(ii)
;if n eq 0 then continue
isat=fltarr(nn)
isatst=isat
lint=fltarr(nn)
lint2=fltarr(nn)
vfloat=fltarr(nn)
vpl=fltarr(nn)
for i=0,n-1 do begin
   isat(ii(i))=getpar(st(ii(i)).shot,'isat',tw=tw,st=dum) & isatst(ii(i))=dum
   vfloat(ii(i))=getpar(st(ii(i)).shot,'vfloat',tw=tw,st=dum) 
   vpl(ii(i))=getpar(st(ii(i)).shot,'vplasma',tw=tw,st=dum) 
   lint(ii(i))=getpar(st(ii(i)).shot,'lint',tw=tw)
   lint2(ii(i))=getpar(st(ii(i)).shot,'lint2',tw=tw)
endfor


bb:
mask=bytarr(nn)
for aa=0,nk-1 do begin
mask1 = st.kh eq kha(aa) and st.satsw eq 'sw' and st.date eq '13-MAR-2014' and st.shot ge 82080
mask=mask or mask1
endfor
ii=where(mask)

n=n_elements(ii)
;if n eq 0 then continue
isatsw=fltarr(nn)
lintsw=fltarr(nn)
lintsw2=fltarr(nn)
tesw=fltarr(nn)
tebp=fltarr(nn)
vfloatsw=fltarr(nn)

for i=0,n-1 do begin
   probe_charnew,st(ii(i)).shot,tavg=tw,varthres=1e9,filterbw=1e3,qty='tesw',/doplot,qavg=dum,qst=dum2  & tesw(ii(i))=dum
;   if st(ii(i)).shot eq 82127 then stop
   probe_charnew,st(ii(i)).shot,tavg=tw,varthres=1e9,filterbw=1e3,qty='tebp',qavg=dum,qst=dum2 & tebp(ii(i))=dum 

   probe_charnew,st(ii(i)).shot,tavg=tw,varthres=1e9,filterbw=1e3,qty='isatsw',qavg=dum,qst=dum2 & isatsw(ii(i))=dum 

 probe_charnew,st(ii(i)).shot,tavg=tw,varthres=1e9,filterbw=1e3,qty='vfloatsw',qavg=dum,qst=dum2 & vfloatsw(ii(i))=dum 

   lintsw(ii(i))=getpar(st(ii(i)).shot,'lint',tw=tw)
   lintsw2(ii(i))=getpar(st(ii(i)).shot,'lint2',tw=tw)
endfor



ee:
erase
pos=posarr(6,nk,0)
for aa=0,nk-1 do begin
mask1 = st.kh eq kha(aa) and st.satsw eq 'sat' and st.date eq '13-MAR-2014' and st.shot ge 82080
ii=where(mask1)

mask2 = st.kh eq kha(aa) and st.satsw eq 'sw' and st.date eq '13-MAR-2014' and st.shot ge 82080
jj=where(mask2)

rad=st(ii).rad
rad2=st(jj).rad
xr=[1.2,1.36]
if n_elements(rad) le 1 then continue
plot,rad,isat(ii),psym=4,pos=pos,/noer,xr=xr,xsty=1,title=kha(aa) & pos=posarr(/next)
oplot,rad2,isatsw(jj),psym=5,col=2

plot,rad,isatst(ii),psym=4,pos=pos,/noer,xr=xr,xsty=1,title=kha(aa) & pos=posarr(/next)

plot,rad2,tesw(jj),psym=5,col=1,pos=pos,/noer,xr=xr,xsty=1,title=kha(aa),/nodata & pos=posarr(/next)
oplot,rad2,tesw(jj),psym=5,col=2
oplot,rad2,tebp(jj),col=2,psym=6

plot,rad,vfloat(ii),psym=4,col=1,pos=pos,/noer,xr=xr,xsty=1,title=kha(aa),yr=minmax([vfloat(ii),vpl(ii)]) & pos=posarr(/next)
oplot,rad,vpl(ii),psym=5,col=2
;oplot,rad2,vfloatsw(jj),psym=5,col=2


plot,rad,lint(ii),psym=4,pos=pos,/noer,xr=xr,xsty=1,title=kha(aa),col=1 & pos=posarr(/next)
oplot,rad2,lintsw(jj),psym=5,col=2
plot,rad,lint2(ii),psym=4,pos=pos,/noer,xr=xr,xsty=1,title=kha(aa),col=1 & pos=posarr(/next)
oplot,rad2,lintsw2(jj),psym=5,col=2
endfor

retall

ee2:
isa=fltarr(nk)
;for i=0,nk-1 do begin
mask1 = st.rad eq 1.33 and st.satsw eq 'sat' and st.date eq '13-MAR-2014' and st.shot ge 82080
ii=where(mask1)

kh=st(ii).kh
idx=sort(kh)

plot,kh(idx),isat(ii(idx))
plot,kh(idx),isatst(ii(idx)),col=2,/noer

end

