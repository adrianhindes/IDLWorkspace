pro loadallnew,sh,nostop=nostop,tr=tr,db=db,only=only,maxt=maxt,nskip=nskip,gas=gas,msemds=msemds,calcskip=calcskip,showend=showend,copy_tdms=copy_tdms,donskip=donskip,noimg=noimg,imgdb=imgdb,subix=subix,redo=redo
noread=0

common cbshot, shotc,dbc,isconnected
shotc=sh
dbc='kstar'

if keyword_set(imgdb) then begin
common cbshot, shotc,dbc, isconnected
;   mdsdisconnect
   isconnected=0
   if n_elements(isconnected) ne 0 then if isconnected eq 1 then mdsdisconnect
   mdsopen,'mse_2014',sh
   imgs=mdsvalue('.pco_camera:i0_total')
   nimg=n_elements(imgs)
   help,imgs 
   goto,b
endif

;nbi=mdsvalue('\NB1_PB1')
;tnbi=mdsvalue('DIM_OF(\NB1_PB1)')

if keyword_set(msemds) then dum=getimgnew(sh,0,db=db,/getinfo,/nosubindex)
if keyword_set(only) then goto,afff



if n_elements(isconnected) ne 0 then if isconnected eq 1 then mdsdisconnect



home=gettstorepath()
name=db ne 'k' ? 'imgs'+db  : 'imgs'
fn=string(home,sh,name,format='(A,I0,"_",A,".hdf")')
dum=file_search(fn,count=cnt)
if cnt ne 0 and not keyword_set(redo) then begin
;    stop
    hdfrestoreext,fn,dum
    print,'restored from',fn
    imgs=dum.imgs
    nimg=n_elements(dum.imgs(*,0))

    readpatch,sh,str,db=db,nfr=nimg,/getflc
    info=str.pinfoflc

endif else begin
    readpatch,sh,str,db=db,nfr=nimg,/getflc
   img=getimgnew(sh,-1,info=info,/getinfo,str=str,/noload,nostop=nostop,db=db,noread=noread,copy_tdms=copy_tdms,/noxbin,/nosubindex)


   nimg=info.num_images
   if keyword_set(maxt) then nimg=(maxt-str.t0)/str.dt




   sz=[info.nx,info.ny]/str.xbin ;size(img,/dim)


    imgs=ulonarr(nimg,5+14)
    if noread eq 1 then goto,aff2
    default,subix,[0,nimg-1]
    for i=subix(0),subix(1) do begin
       print,'before getmgnew'
        img=getimgnew(sh,i,db=db,str=str,/noloadstr,copy_tdms=copy_tdms,/noxbin,/nosubindex)
        print,'after getimgnew'
        print,i,nimg
;        wait,0.3
        imgs(i,0)=total(img*1.0)/n_elements(img)
        imgs(i,1)=img(sz(0)*0.5,sz(1)*0.5)
        imgs(i,2)=img(sz(0)*0.5,sz(1)*0.5 + 2)
        imgs(i,3)=img(sz(0)*0.5,sz(1)*0.5 + 5)
        imgs(i,4)=img(sz(0)*0.5,sz(1)*0.5 + 10)
        imgs(i,5:*)=img(0:13,0);sz(1)-1)
    endfor


    rv={imgs:imgs}
    hdfsaveext,fn,rv
    print,'saved to',fn

    aff2:
endelse
b:
readpatch,sh,str2,db=db ; now populate the ivec part if skipped
str.ivec=str2.ivec
if db eq 'k' then    info=str.pinfoflc


if n_elements(info) ne 0 then if istag(info,'stat1') then stat1=info.stat1 else stat1=fltarr(nimg)


if keyword_set(donskip) then begin
   default,nskip,0
   str.nskip=nskip
   str.t0=str.t0proper+str.dt*str.nskip
endif
if keyword_set(calcskip) then str.t0=str.t0proper

;t=str.t0+findgen(nimg)*str.dt
nimg=nimg<n_elements(str.ivec)
t=str.t0+str.ivec(0:nimg-1)*str.dt

afff:
if sh ge 7000 and not keyword_set(gas) then begin
   shotc=sh
   dbc='kstar'

    nbi1=cgetdata('\NB11_I0')
    nbi2=cgetdata('\NB12_I0')
    nbi3=cgetdata('\NB13_I0')
;    ip=cgetdata('\PCRC03')
    ip=cgetdata('\RC01')
    eccd=cgetdata('\EC1_RFFWD1')
endif
if keyword_set(only) then return
bb:


if keyword_set(calcskip) then begin
ttt=str.t0+str.dt*findgen(nimg*2)
if db eq 'c' then iptb=interpol(-smooth(ip.v,10),ip.t,ttt) else iptb=interpol(smooth(nbi1.v+nbi2.v,3),nbi1.t,ttt)
dip=deriv(iptb)
dum=min(dip,imin1)
print,'time/index of ip off=',ttt(imin1),imin1
dsig=deriv(imgs(*,0))
dsig(0:3)=0.
dum=min(dsig,imin2)
if db eq 'c' then begin
;imin2=imin1-2
   ii=where(dsig/dum gt 0.2)
   imin2=ii(n_elements(ii)-1) ; take lst one

endif


nskip=imin1-imin2;-1
print,'time/index of light off=',ttt(imin2),imin2
print,'so nskip=',nskip
again:

loadallnew, sh,tr=ttt(imin1)+[-0.5,0.5],nskip=nskip,/nostop,db=db,/donskip
read,'how much to change nskip (0 returns)',dnskip
if dnskip eq 0 then begin
   writenskip,sh,nskip,db=db
   return
endif  else begin
   nskip=nskip+dnskip
   goto,again
endelse

endif


if keyword_set(showend) then begin
if db eq 'c' then    iptb=interpol(-smooth(ip.v,10),ip.t,t) else iptb=interpol(smooth(nbi1.v+nbi2.v,3),nbi1.t,t)
   dip=deriv(iptb)
   dum=min(dip,imin1)
   print,'time/index of ip off=',t(imin1),imin1
   tr=t(imin1)+[-0.5,0.5]
endif


plot,t+.01,imgs(*,0),xr=tr,psym=-4,title=sh
if size(imgs,/n_dim) gt 1 then begin
   plot,t,imgs(*,1),/noer,xr=tr
   for j=2,3 do oplot,t,imgs(*,j)
endif
if n_elements(nbi1) gt 0 then begin
    if n_elements(nbi1.t) gt 1 then begin
       plot,nbi1.t,nbi1.v,col=5,/noer,xr=!x.crange,xsty=1,yr=[-1,50],/nodata
       if max(nbi1.v) gt 10 then oplot,nbi1.t,nbi1.v,col=5
    endif
    if sh eq 11005 or sh eq 11006 then goto,b3
    if n_elements(nbi2.t) gt 1 then begin
       if max(nbi2.v) gt 10 then oplot,nbi2.t,nbi2.v,col=6
    endif
   b3:
    if n_elements(nbi3.t) gt 1 then begin
       if max(nbi3.v) gt 10 then oplot,nbi3.t,nbi3.v,col=7
    endif
if sh eq 11005 or sh eq 11006 then goto,b4
;    plot,nbi2.t,nbi2.v,col=6,/noer,xr=!x.crange,xsty=1
    plot,ip.t,-ip.v,col=7,/noer,xr=!x.crange,xsty=1
    if n_elements(eccd.v) gt 10 then plot,eccd.t,eccd.v,col=8,/noer,xr=!x.crange,xsty=1
b4:
endif
if strmid(str.cellno,0,4) eq 'msea' then begin
;stop
    defcirc

    if sh gt 8900 then begin
       plot,t,stat1(*,0),/noer,xr=!x.crange,xsty=1,col=9,psym=-8,yr=[-1,5],ysty=1 ;,/nodata
       if n_elements(info) gt 0 then if istag(info,'flc0') then if size(info.flc0.t,/type) ne 7 then oplot,info.flc0.t,info.flc0.v/10+0.5 + 0.1,col=9,linesty=1
    endif else begin
       plot,t,stat1(*,0),/noer,xr=!x.crange,xsty=1,col=9,psym=-8,yr=[-1,5],ysty=1 ;,/nodata
       if n_elements(info) gt 0 then if istag(info,'flc0') then if size(info.flc0.t,/type) ne 7 then oplot,info.flc0.t,info.flc0.v/10+0.5 + 0.1,col=9,linesty=1

       plot,t,stat1(*,1),/noer,xr=!x.crange,xsty=1,col=10,psym=-8,yr=[-1,5],ysty=1 ;,/nodata
       if n_elements(info) gt 0 then if istag(info,'flc1') then if size(info.flc1.t,/type) ne 7 then oplot,info.flc1.t,info.flc1.v/10+0.5 + 0.1,col=10,linesty=1

    endelse

endif


if not keyword_set(nostop) then stop
end

 

pro batch
;sh=intspace(7260,7305)
;sh=fix(intspace(9029,9409))
sh=fix(intspace(9410,9427))
nsh=n_elements(sh)
for i=0,nsh-1 do begin
   for j=0,1 do begin
    err=0
    catch,err
    if err ne 0 then begin
        continue
    endif
    loadallnew, sh(i),/nostop,db=j eq 0 ? 'k' : 'c' ;,/copy_tdms
    endfor
endfor
end
