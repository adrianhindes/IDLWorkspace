@pr_prof2




path=getenv('HOME')+'/idl/clive/settings/'&file='log_frank_runf7.csv'

readtextc,path+file,data0,nskip=2
shot=float(data0[2,1:*])
powerlev=float(data0[1,1:*])
resistor=float(data0[3,1:*])
pr_pos=float(data0[0,1:*])

n=n_elements(shot)
tebp=fltarr(n)
tesw=tebp
isat=tebp
vpl=isat

nsh=n & idx=indgen(n)
twant=[.04,.05]
for i=0,nsh-1 do begin
mdsopen,'anal',shot(idx(i))
y=mdsvalue2('tebp')
isub=where( (y.t ge twant(0)) and (y.t le twant(1)) )
tebp(idx(i))=mean(y.v(isub))
;stop
y=mdsvalue2('te_sw_f')
isub=where( (y.t ge twant(0)) and (y.t le twant(1)) )
tesw(idx(i))=mean(y.v(isub))

y=mdsvalue2('isatsw')
isub=where( (y.t ge twant(0)) and (y.t le twant(1)) )
isat(idx(i))=mean(y.v(isub))

y=mdsvalue2('vpl')
isub=where( (y.t ge twant(0)) and (y.t le twant(1)) )
vpl(idx(i))=mean(y.v(isub))


mdsclose
endfor



realr=pr_pos + 1112

parr=[23.8,17.4,11.2,8.2,5.3,3.6,2.5]
np=n_elements(parr)


mkfig,'~/pscan_results.eps',xsize=26,ysize=20,font_size=12
!p.thick=3
erase

for iplot=0,2 do begin


pos=posarr(2,2,iplot)

for i=0,np-1 do begin
p0=parr(i)
idx=where(abs(powerlev - p0) le 0.2 )
nsh=n_elements(idx)

if iplot eq 0 then begin
   qty=tesw & title='Te (swept)/eV'                     ;isat;tesw;tesw;isat;tesw
   yr=[0,20]
;dum=temporary(yr)
endif
if iplot eq 1 then begin
   qty=isat & title='isat/A'
   if n_elements(yr) ne 0 then dum=temporary(yr)
endif
if iplot eq 2 then begin
   qty=vpl & title='vplasma/V'
;   if n_elements(yr) ne 0 then dum=temporary(yr)
   yr=[-20,60]
endif

if i eq 0 then plot,realr(idx),qty(idx),psym=-4,yr=yr,pos=pos,title=title,xtitle='R (mm)',/noer else $
   oplot,realr(idx),qty(idx),psym=-4,col=i+1
endfor
endfor
plot,[1,1],[1,1],/nodata,xsty=4,ysty=4,pos=posarr(2,2,3),/noer,title='power levels (kW)'
legend,string(2*parr),col=findgen(np)+1,psym=replicate(-4,np),linesty=replicate(0,np),box=0

endfig,/gs,/jp
;oplot,realr(idx),tesw(idx),psym=-5,col=2

;stop
;plot,realr(idx),isat(idx),psym=-4

;,title='tesw',psym=-5,pos=posarr(1,3,0),yr=[-0,20]
;oplot,x,tebp,psym=-4,col=2
;oplot,x,telr,psym=-6,col=3
;plot,x,isat,title='isat',psym=-5,pos=posarr(/next),/noer
;plot,x,vpl,title='vpl',pos=posarr(/next),/noer,psym=-4
;!p.multi=0
end
