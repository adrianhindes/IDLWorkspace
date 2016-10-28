d1=getsp(1)
d1s=smooth(d1,10)
plot,d1,/yno
oplot,d1s,col=2
dum=max(d1s,i1)
plots,i1,dum,psym=4,col=2


l1=541.73

;stop
d2=getsp(2)
d2s=smooth(d2,10)
plot,d2,/yno
oplot,d2s,col=2
dum=max(d2s,i2)
plots,i2,dum,psym=4,col=2

l2=524.8

;stop
d4=getsp(4)
d4s=smooth(d4,10)
plot,d4,/yno
oplot,d4s,col=2
dum=max(d4s,i4)
plots,i4,dum,psym=4,col=2

l4=532.02

;stop
ii=[i1,i2,i4]
ll=[l1,l2,l4]
plot,ii,ll,/yno,psym=4
a=linfit(ii,ll,yfit=llfit)
oplot,ii,llfit,col=2

slope=-a(1)
lamtrue=530.

offset = lamtrue -slope * i4

a2=[offset,slope]

n=n_elements(d1)

l=findgen(n) * a2(1) + a2(0)

for rr=1,1 do begin
pos=posarr(2,2,0)

t=[ [0.7,1.1],$
    [1.5,2.8] ] * 1e-3

t=rotate(t,rr)

;dtl=(getsp(11)-getsp(13))/(getsp(12)-getsp(13))
xr=530+[-2,2]*4
dtl=(getsp(29)-getsp(31))/(getsp(30)-getsp(31))
plot,l,dtl,yr=[0,1],xr=xr,title='tl',pos=pos
par={thickness:t[0,0]*2, crystal:'bbo',facetilt:0,lambda:l*1e-9}
nwav=opd(0,0,par=par)/2/!pi
oplot,l,sin(2*!pi*nwav)*0.2+0.5,col=2

dtr=(getsp(32)-getsp(34))/(getsp(33)-getsp(34))
plot,l,dtr,title='tr',pos=posarr(/next),/noer,xr=xr
;tl,tr,br,bl: 0.7,1.1,2.8,1.5*2 bbo
par={thickness:t[1,0]*2, crystal:'bbo',facetilt:0,lambda:l*1e-9}
nwav=opd(0,0,par=par)/2/!pi
oplot,l,-sin(2*!pi*nwav)*0.25+0.5,col=2



dbl=(getsp(26)-getsp(28))/(getsp(27)-getsp(28))
plot,l,dbl,yr=[0,1],xr=xr,title='bl',pos=posarr(/next),/noer
par={thickness:t[0,1]*2, crystal:'bbo',facetilt:0,lambda:l*1e-9}
nwav=opd(0,0,par=par)/2/!pi
oplot,l,-sin(2*!pi*nwav)*0.1+0.45,col=2


dbr=(getsp(23)-getsp(28))/(getsp(27)-getsp(28))
plot,l,dbr,yr=[0,1],xr=xr,title='br',pos=posarr(/next),/noer
par={thickness:t[1,1]*2, crystal:'bbo',facetilt:0,lambda:l*1e-9}
nwav=opd(0,0,par=par)/2/!pi
oplot,l,-sin(2*!pi*nwav)*0.2+0.6,col=2

print,rr
print,t/1e-3
dum=''
;read,'',dum
endfor





end
