pro f1,which,outr=outr,out2r=out2r,want=want,rout=rout,nostop=nostop,lvonly=lvonly,par=par,rxs=rxs,rys=rys,docalc=docalc,scal=scal
;tr=[1,8]
;tr=[1,7]

if strpos(want,'ece') ne -1 then norun=1
if strpos(want,'conv') ne -1 then norun=1

if which eq '9323' then begin
sh=9323 & freqshot=2. & tr2=[2,7]
ex=''
endif

if which eq '9323b' then begin
sh=9323 & freqshot=2. & tr2=[4,7]
ex='b'
endif

if which eq '9326' then begin
sh=9326 & freqshot=10. & tr2=[2,7]
ex=''
endif

if which eq '9327' then begin
sh=9327 & freqshot=10. & tr2=[4,6]
ex=''
endif



if which eq '9324' then begin
sh=9324 & freqshot=2. & tr2=[2,7]
ex=''
endif

;sh=9326 & freqshot=10. & tr2=[2,7]
;sh=9327 & freqshot=10. & tr2=[4,6]

if which eq '10997b' then begin
sh=10997 & freqshot=2.5 & tr2=[2.5,4.9];miyoung 2.7T, co, 2 beams
ex='b'

endif


if which eq '10997c' then begin
sh=10997 & freqshot=2.5 & tr2=[7.9,10.3];miyoung 2.7T, co, 2 beams
ex='c'
endif


if which eq '11004' then begin
ex=''
sh=11004 & freqshot=2 & tr2=[2,6];counter
endif

if which eq '11003' then begin
ex=''
sh=11003 & freqshot=2 & tr2=[2,6];co

endif


if which eq '11433a' then begin
ex='a';12ms delsy for ech
sh=11433 & freqshot=2.5 & tr2=[2.2,4.21];c
if keyword_set(norun) then tr2=[2.2,4.2]+12e-3;-0.2

endif


if which eq '11433b' then begin
ex='b'
sh=11433 & freqshot=2.5 & tr2=[4.205,6.215]
if keyword_set(norun) then tr2=[4.2,6.2]

endif


if which eq '11433c' then begin
ex='c'
sh=11433 & freqshot=2.5 & tr2=[6.185,8.195];co
if keyword_set(norun) then tr2=[6.2,8.2]

endif




if which eq '11434a' then begin
ex='a'
sh=11434 & freqshot=2.5 & tr2=[3.215, 5.225];co
if keyword_set(norun) then tr2=[3.2,5.2]+12e-3

endif

if which eq '11434b' then begin
ex='b'
sh=11434 & freqshot=2.5 & tr2=[3.215, 7.205];co
if keyword_set(norun) then tr2=[3.2,7.2]+12e-3
endif


if which eq '13366a' then begin
ex='a'
sh=13366 & freqshot=10. & tr2=[10.0,11.0]
par={sh:sh,freqshot:freqshot,tr:tr2}
endif
if which eq '13368a' then begin
ex='a'
sh=13368 & freqshot=10. & tr2=[10.0,11.0]
par={sh:sh,freqshot:freqshot,tr:tr2}
endif

if which eq '13491a' then begin
ex='a'
sh=13491 & freqshot=2.5 & tr2=[4.0, 5.6]
par={sh:sh,freqshot:freqshot,tr:tr2}
endif

if which eq '13491aa' then begin
ex='aa'
sh=13491 & freqshot=2.5 & tr2=[3.2, 4.4]
par={sh:sh,freqshot:freqshot,tr:tr2}
endif

if which eq '13491ab' then begin
ex='ab'
sh=13491 & freqshot=2.5 & tr2=[3.2, 4.0]
par={sh:sh,freqshot:freqshot,tr:tr2}
endif

if which eq '13491ac' then begin
ex='ac'
sh=13491 & freqshot=2.5 & tr2=[4.8,5.6]
par={sh:sh,freqshot:freqshot,tr:tr2}
endif

if which eq '13491b' then begin
ex='b'
sh=13491 & freqshot=2.5 & tr2=[5.6, 7.4]
par={sh:sh,freqshot:freqshot,tr:tr2}
endif
if which eq '13491bz' then begin
ex='bz'
sh=13491 & freqshot=2.5 & tr2=[5.6, 7.2]
par={sh:sh,freqshot:freqshot,tr:tr2}
endif


if which eq '13491bb' then begin
ex='bb'
sh=13491 & freqshot=2.5 & tr2=[5.6, 6.4]
par={sh:sh,freqshot:freqshot,tr:tr2}
endif


if which eq '13492a' then begin
ex='a'
sh=13492 & freqshot=10. & tr2=[.5,1]
par={sh:sh,freqshot:freqshot,tr:tr2}
endif

if which eq '13492a' then begin
ex='a'
sh=13492 & freqshot=10. & tr2=[.5,1]
par={sh:sh,freqshot:freqshot,tr:tr2}
endif


if which eq '13492b' then begin
ex='b'
sh=13492 & freqshot=10. & tr2=[.7,1]
par={sh:sh,freqshot:freqshot,tr:tr2}
endif

if which eq '13494a' then begin
ex='a'
sh=13494 & freqshot=2.5 & tr2=[.5,2.5]
par={sh:sh,freqshot:freqshot,tr:tr2}
endif


if strpos(want,'ece') ne -1  then begin
a1ece,sh,freqshot,tr2,ex,outr=outr,out2r=out2r,rout=rout,nostop=nostop,want=want
endif

if strpos(want,'conv') ne -1  then begin
a1conv,sh,freqshot,tr2,ex,outr=outr,out2r=out2r,rout=rout,nostop=nostop,want=want
endif



if keyword_set(norun) then return
if strpos(want,'tfixed') eq -1 then $
a1,sh,freqshot,tr2,ex,outr=outr,out2r=out2r,want=want,rout=rout,nostop=nostop,lvonly=lvonly,rxs=rxs,rys=rys,docalc=docalc,scal=scal $,
 else begin
   sh=11003
   newdemodflclt,sh,frameoftime(sh,3.45),/only2,demodtype=demodtype,cacheread=1,eps=eps1,angt=ang1,dop1=dop11,dop2=dop21,dop3=dop31,dopc=dopc1,inten=inten1,lin=lin1,pp=p,str=str,sd=sd

;      newdemodflclt,sh,arr(i),eps=eps1,angt=ang1,dop1=dop11,dop2=dop21,dop3=dop31,dopc=dopc1,inten=inten1,lin=lin1,pp=p,str=str,sd=sd,noload=i gt 0,vkz=vkz,ix=ix,iy=iy,only2=only2,cachewrite=cachewrite,cacheread=cacheread1, only1=keyword_set(resref),de
stop

endelse
;p=out2r
;dum=-[[cos(p*!dtor)],[sin(p*!dtor)]]
;pp=atan(dum(*,1),dum(*,0))
;out2r=pp

end
