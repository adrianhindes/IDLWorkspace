
function calcfit3,xpar,plot=plot,res1=res1,res2=res2;,par
common cbc, ncalls
if n_elements(ncalls) eq 0 then ncalls=0
ncalls=ncalls+1
if ncalls mod 10 eq 0 then begin
    print,ncalls
    plot=1
    print, xpar
endif
common cb2, img,cars,gap,nb,mat,thx,thy,iz,p,str,sd,thv,ilist0,isubx,isuby,iz2,lam


common cb2b, carsi
if ncalls eq 1 then begin
    carsi=interpolate(cars,isubx,isuby,indgen(n_elements(ilist0)),/grid)
    carsi=exp(complex(0,1)*atan2(carsi))
endif 
strtmp=str
applycal, strtmp,xpar



jj=[16,22];[28,21]

;for k=0,n_elements(jj)-1 do begin
;    j=jj(k)
;    i0=(where(ilist0 eq j))(0)
;    if ncalls eq 1 then begin
;        pht=atan2(cars(*,*,i0))
;        jumpimg,pht;;
;
;        ph=interpolate(pht,isubx,isuby,/grid)
;        ph -= ph(iz2(0),iz2(1))
;        sz=size(ph,/dim)
;        if k eq 0 then phja=fltarr(sz(0),sz(1),2)
;        phja(*,*,k)=ph
;;        stop
;    endif else begin
;        ph=phja(*,*,k)
;    endelse
;endfor





 genmat2, mat2=mat2,kza1=kza,sh=sh,iz=iz2,thx=thx(isubx),thy=thy(isuby),p=p,str=strtmp,kzaav=kzaav, indexlist=ilist0,/useindex,lam=lam


gencarriers2,sh=sh,th=[thx(iz(0)),thy(iz(1))],kx=kx,ky=ky,dkx=dkx,dky=dky,p=p,str=strtmp,toutlist=toutlist,/noload,/quiet,tkz=kz,nkz=nkz,vth=thv,vkz=kzv,lam=lam,indexlist=ilist0,/useindex,mat=mat,dmat=dmat


;stop
;pro gencarriers2,th=th,sh=sh,mat=a2,dmat=da2,tdkz=dkzlist,kx=kxlist,ky=kylist,kz=kzavlist,tkz=kzlist,nkz=nkz,dkx=dkx,dky=dky,quiet=quiet,p=p,str=str,noload=noload,toutlist=toutlist,vth=thv,indexlist=indexlist,vkzv=kzv,lam=lam,frac=frac,fudgethick=fudgethick




;for k=0,n_elements(jj)-1 do begin
;    j=jj(k)
;    i0=(where(ilist0 eq j))(0);;
;
;    kzref=(kzaav(i0,iz2(0),iz2(1)))
;    a2=reform(kzaav(i0,*,*)-kzref)*2*!pi
;    a1=phja(*,*,k)
;    dif=a2-a1
;    stop
;endfor

        


; svec=complexarr(nx,ny,4)
; delarr=fltarr(nx,ny)
nx2=n_elements(isubx)
ny2=n_elements(isuby)

cars2=complexarr(nx2,ny2,n_elements(ilist0))
for a=0,nx2-1 do for b=0,ny2-1 do begin
    svec=transpose([1,1,0,0])
    cars2(a,b,*)=mat2(*,*,a,b) ## svec
endfor
cars2=exp(complex(0,1)*atan2(cars2))
dcars=cars2-carsi


chisq=0.
for k=0,n_elements(jj)-1 do begin
    j=jj(k)
    i0=(where(ilist0 eq j))(0)
    dif=abs(dcars(*,*,i0))
    idx=where(finite(dif))
    chisq+=total(dif(idx)^2)
    if k eq 0 then res1=dif
    if k eq 1 then res2=dif
    if keyword_set(plot) then begin
        if k eq 0 then pos=posarr(3,2,0)
        imgplot,float(carsi(*,*,i0)),pos=pos,/cb,title='meas',noer=k ne 0 
        imgplot,float(cars2(*,*,i0)),pos=posarr(/next),/noer,/cb,title='theor'
        imgplot,dif,pos=posarr(/next),/noer,/cb,pal=-2,title='theor-meas'
        pos=posarr(/next)

    endif
;    stop
endfor
if keyword_set(plot) then print,'chisq=',chisq

return,chisq
end


;stop
; ;    la_svd,mat,w,u,v
;     la_svd,mat2(*,*,i,j),w,u,v
;     wi=1/w                      ;&  wi(2)=0.
;     imat=v ## diag_matrix(wi) ## conj(transpose(u))*20.
;     harm=transpose(reform(cars(i,j,*)))

;     tmp=kza(*,*,i,j)
;     inz=where(tmp ne 0)
;     mkz=median(tmp(inz))

;     iharm=imat ## harm
;     kappa=1.0
;     del1=atan2(iharm(1)) /2/!pi / mkz / kappa
;     del2=atan2(iharm(2)) /2/!pi / mkz / kappa

; ;    delw=(del1*abs(iharm(1)) + del2 * abs(iharm(2))) / (abs(iharm(1))+abs(iharm(2)))
;     delw=del1

;     delarr(i,j)=delw
    
;     pcor2=abs(kzaav(*,i,j))*delw*kappa*(1)
;     harm=harm * exp(-2*!pi*complex(0,1)*pcor2)
; ;    stop

;     s=imat ## harm


;     svec(i,j,*)=s
; endfor


;if keyword_set(plot) then print,'chisq=',chisq
;chisq=0
;return,chisq
;end
