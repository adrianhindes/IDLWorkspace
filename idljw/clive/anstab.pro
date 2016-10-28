sharr=(read_ascii('~/idl/clive/shan.txt')).(0)
nsh=n_elements(sharr)

trng=[.55,.95]

ph=fltarr(nsh,16)
vg=ph
i0=0
restore,file='~/ph.sav'&i0=i
for i=i0,nsh-1 do begin
;   loadallnew,sharr(i),tr=[-0.2,1.2],db='k',maxt=1.2
   sh=sharr(i)
   newdemodflcshot,sh,trng,res=res,cacheread=1,cachewrite=1,/only2
   dum=cgetdata('\NB11_VG1',shot=sh,db='kstar')
   if n_elements(dum.v) gt 1 then  vg(i,0:n_elements(res.t)-1)=interpol(dum.v,dum.t,res.t) else vg(i,*)=!values.f_nan

   sz=size(res.dopc,/dim)
;   plot,res.dopc(sz(0)/2,sz(1)/2,*)
   ph(i,0:n_elements(res.t)-1)=res.dopc(sz(0)/2,sz(1)/2,*)
   save,i,ph,vg,file='~/ph.sav'
;   plot,(reform(transpose(ph),16*nsh))(0:16*(i+1)-1),pos=posarr(2,1,0),title=sh
;   oplot,(reform(transpose(ph),16*nsh))(0:16*(i+1)-1)+180
;   plot,(reform(transpose(vg),16*nsh))(0:16*(i+1)-1),pos=posarr(/next),/noer,col=2,/yno

   idx=where(finite(vg(0:i-1,14)) and (vg(0:i-1,14) ne 0))
   plot,sharr(idx),ph(idx,14),pos=posarr(1,1,0),title=sh,psym=4
   oplot,sharr(idx),ph(idx,14)+180,psym=4
   plot,sharr(idx),vg(idx,14),pos=posarr(/curr),/noer,col=2,/yno,psym=4

endfor

  idx=where(finite(vg(0:i-1,5)) and (vg(0:i-1,5) gt 2))

mkfig,'~/phan2.eps',xsize=24,ysize=12,font_size=10

a=sharr(idx)
;a=findgen(n_elements(idx))
   plot,a,ph(idx,5),pos=posarr(1,1,0,cnx=.1,cny=.1),title='',psym=4,xtitle='sh#',ysty=8,ytitle='phase/deg',yr=[-50,100]
   oplot,a,ph(idx,5)+180,psym=4
   plot,a,vg(idx,5),pos=posarr(/curr),/noer,col=2,/yno,psym=4,ysty=4,xsty=4
   axis,!x.crange(1),!y.crange(0),col=2,yaxis=1,ytitle='voltage/kV'

endfig,/gs,/jp
mkfig,'~/phan.eps',xsize=12,ysize=12,font_size=10
plot,vg(idx,5),ph(idx,5),psym=4,xtitle='voltage',ytitle='phase'
oplot,vg(idx,5),ph(idx,5)+180,psym=4
endfig,/gs,/jp
;sh=11170
;newdemodflcshot,sh,trng,res=res,cacheread=0,cachewrite=1,/only2

end
;11428.0      11429.0      11433.0      11434.0      11455.0      11456.0
;      11457.0      11458.0      11508.0      11509.0      11510.0      11511.0
;      11512.0      11513.0      11515.0      11516.0      11518.0      11520.0


