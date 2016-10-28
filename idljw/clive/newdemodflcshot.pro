pro newdemodflcshot,sh,trng,res=res,cacheread=cacheread,cachewrite=cachewrite,only2=only2,tout=tout,nskip=nskip,nsm=nsm,rresref=resref,lut=lut,demodtype=demodtype,noid2=noid2,sg=sg,tskip=tskip
default,sg,1 ; sign to trigger the edge detection

readpatch,sh,str,/getflc
irng=fix( (trng-str.t0)/str.dt )

default,nskip,1

default,tskip,0
arr=intspace(irng(0),irng(1)-tskip)
n=n_elements(arr)

ifr=fix(arr)
if n_elements(resref) eq 0 then begin
;   stat1=[[((ifr - str.flc0t0) mod str.flc0per) / (str.flc0mark eq 0 $
;                   ? str.flc0per/2 : str.flc0mark)]]
   stat1=str.pinfoflc.stat1(arr,0)
   if str.flc0per ne 2 then begin
      idx=where(sg*stat1(0:n-2) lt sg*stat1(1:n-1))
      arr=arr(idx)              ; find diferent ones
      print,'chosen only',n_elements(idx),'out of ',n
      n=n_elements(idx)
   endif else begin
      print,'modulation period 2, so using high and low'
   endelse

endif

arr=arr(indgen(n/nskip)*nskip) 
n=n_elements(arr)
t=str.t0+str.dt*arr
tout=t




;stop

if keyword_set(resref) then begin
   if nsm eq 1 then begin
      dopcs=resref.dopc
   endif
   if nsm gt 1 and nsm ne 9999 then begin
      dopcs=smooth(resref.dopc,[1,1,nsm],/edge_truncate) 
   endif
   if nsm eq 9999 then begin
      ;average
      dopcstot=totaldim(resref.dopc,[0,0,1]) / n_elements(resref.t)
      dopcs = resref.dopc
      for i=0,n_elements(resref.t)-1 do dopcs(*,*,i)=dopcstot
      print,'replaced average'
   endif
   sz=size(dopcs,/dim)
   itime=interpol(findgen(n_elements(resref.t)),resref.t,t)
   dopc=interpolate(dopcs,indgen(sz(0)),indgen(sz(1)),itime,/grid)

endif




for i=0,n-1  do begin
    if keyword_set(resref) then dopc1=dopc(*,*,i)

    if i eq 0 then begin
;       if n_elements(cachewrite) ne 0 then if cachewrite eq 1 then
;       cacheread1=0
       cacheread1=0
    endif else cacheread1=cacheread

    


if not keyword_set(lut) then     newdemodflc,sh,arr(i),eps=eps1,angt=ang1,dop1=dop11,dop2=dop21,dop3=dop31,dopc=dopc1,inten=inten1,lin=lin1,pp=p,str=str,sd=sd,noload=i gt 0,vkz=vkz,ix=ix,iy=iy,only2=only2,cachewrite=cachewrite,cacheread=cacheread1, only1=keyword_set(resref),demodtype=demodtype,noid2=noid2,db=db $
   else $
      newdemodflclt,sh,arr(i),eps=eps1,angt=ang1,dop1=dop11,dop2=dop21,dop3=dop31,dopc=dopc1,inten=inten1,lin=lin1,pp=p,str=str,sd=sd,noload=i gt 0,vkz=vkz,ix=ix,iy=iy,only2=only2,cachewrite=cachewrite,cacheread=cacheread1, only1=keyword_set(resref),demodtype=demodtype,noid2=noid2,db=db
;stop
    if i eq 0 then begin
        sz=size(eps1,/dim)
        eps=fltarr(sz(0),sz(1),n)
        ang=eps
        dop1=eps
        dop2=eps
        dop3=eps
        if not keyword_set(resref)  then dopc=eps
        lin=eps
        inten=eps
    endif
    eps(*,*,i)=eps1
    ang(*,*,i)=ang1
    dop1(*,*,i)=dop11
    dop2(*,*,i)=dop21
    dop3(*,*,i)=dop31
    if not keyword_set(resref)  then dopc(*,*,i)=dopc1
    lin(*,*,i)=lin1
    inten(*,*,i)=inten1
    print,'_____'
    print,' done time ',i,' out of ',n_elements(arr)
    print,'________'

endfor

nix=n_elements(ix)
niy=n_elements(iy)
nix2=nix / 10
niy2=niy / 2
ixs=findgen(nix2) * nix/nix2
iys=findgen(niy2) * niy/niy2
ixss=ix(ixs)
iyss=iy(iys)


getptsnew,rarr=r2,zarr=z2,str=p,ix=ixss,iy=iyss,pts=pts,rxs=rxst,rys=ryst,/calca

r1=interpol(-r2(*,niy2/2),ixss,ix)
z1=interpol(z2(nix2/2,*),iyss,iy)
rxs=fltarr(nix,3)
rys=rxs
for i=0,2 do rxs(*,i)=interpol(rxst(*,niy2/2,i),ixss,ix)
for i=0,2 do rys(*,i)=interpol(ryst(*,niy2/2,i),ixss,ix)


res={t:t,eps:eps,ang:ang,dop1:dop1,dop2:dop2,dop3:dop3,dopc:dopc,lin:lin,inten:inten,r1:r1,z1:z1,rxs:rxs,rys:rys}
end

pro auto

newdemodflcshot,10688,[1,1.3],/cachewrite,only2=1,res=res
stop

end

pro auto2

newdemodflcshot,10688,[1,1.7],/cacheread,/cachewrite,only2=1,res=res
stop

end
