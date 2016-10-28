
function calcfit,xpar,plot=plot,res1=res1,res2=res2;,par
common cbc, ncalls
if n_elements(ncalls) eq 0 then ncalls=0
ncalls=ncalls+1
if ncalls mod 10 eq 0 then begin
    print,ncalls
    plot=1
    print, xpar
endif
common cb2, img,cars,gap,nb,mat,thx,thy,iz,p,str,sd,thv,ilist0,isubx,isuby,iz2,lam


strtmp=str
applycal, strtmp,xpar
;gencarriers,sh=sh,th=[thx(iz(0)),thy(iz(1))],kx=kx,ky=ky,dkx=dkx,dky=dky,p=p,str=strtmp,toutlist=toutlist,/noload,/quiet,tkz=kz,nkz=nkz,mat=mat,vth=thv,vkz=kzv,lam=lam,indexlist=ilist
gencarriers2,sh=sh,th=[thx(iz(0)),thy(iz(1))],kx=kx,ky=ky,dkx=dkx,dky=dky,p=p,str=strtmp,toutlist=toutlist,/noload,/quiet,tkz=kz,nkz=nkz,mat=mat,vth=thv,vkz=kzv,lam=lam,indexlist=ilist0,dmat=dmat,/useindex
ilist=ilist0
dcar=(dmat) ## transpose([1,0,1,0])
dph=reform(atan2(dcar))
;stop
for i=0,3 do kzv(*,*,i)+=dph(i)/2/!pi ; phase corrected for s1 etc.
;for i=2,3 do begin
;    if i eq 2 then continue
jj=[16,22];[28,21]
common cmr, phja

chisq=0.
for k=0,n_elements(jj)-1 do begin
    j=jj(k)
    i0=(where(ilist0 eq j))(0)

    i=(where(ilist eq j))(0)

;i=(where(ilist eq 28))(0)
    if ncalls eq 1 then begin
        pht=atan2(cars(*,*,i0))
        jumpimg,pht

        ph=interpolate(pht,isubx,isuby,/grid)
        sz=size(ph,/dim)
        if k eq 0 then phja=fltarr(sz(0),sz(1),2)
        phja(*,*,k)=ph
;        stop
    endif else begin
        ph=phja(*,*,k)
    endelse

    
    a1=ph/2/!pi
    a1o=a1(iz2(0),iz2(1))
    a1 -= a1o

    a2=kzv(*,*,i)
    a2o=(kzv(iz2(0),iz2(1),i))
    a2 -= a2o

    dif=a2-a1
    idx=where(finite(dif))
    csqa=total(dif(idx)^2)
    chisq+=csqa

    difc = exp(complex(0,1)* a2o*2*!pi) - exp(complex(0,1)*a1o*2*!pi)
    difcc=abs(difc)*n_elements(idx)

    chisq+=difcc
    if k eq 0 then res1=dif
    if k eq 1 then res2=dif
    if keyword_set(plot) then begin
        if k eq 0 then pos=posarr(3,2,0)
        imgplot,a1,pos=pos,/cb,title='meas',noer=k ne 0 
        imgplot,a2,pos=posarr(/next),/noer,/cb,title='theor'
        imgplot,dif,pos=posarr(/next),/noer,/cb,pal=-2,title='theor-meas'
        print,k,csqa,difcc, a2o mod 1, (a1o+100) mod 1
        pos=posarr(/next)

    endif
;    stop
endfor
if keyword_set(plot) then print,'chisq=',chisq

return,chisq
end
