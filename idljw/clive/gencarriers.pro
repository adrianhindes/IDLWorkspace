
pro gencarriers,th=th,sh=sh,mat=mat,kx=kxlist,ky=kylist,kz=kzavlist,tkz=kzlist,nkz=nkz,$
dkx=dkx,dky=dky,quiet=quiet,p=p,str=str,noload=noload,toutlist=toutlist,vth=thv,indexlist=indexlist,vkzv=kzv,lam=lam,frac=frac,useindex=useindex,stat=stat,slist=slist,db=db

;default,lam,656.1e-9
if not keyword_set(noload) then readpatch,sh,p,db=db
if not keyword_set(noload) then readcell,p.cellno,str

if not keyword_set(quiet) then print,p.cellno

tn=tag_names(str)
i0=value_locate(tn,'WP1')
nstates=1
for i=0,4 do begin
    if str.(i0+i).type eq 'flc' then nstates=nstates*2
endfor

stat=transpose([[0,0,1,1],[0,1,0,1]])

;th=[3,3.]*!dtor
;th=[3.,0.]*!dtor
;th=[0.,0.]
for state=0,nstates-1 do begin

    szv=size(thv,/dim)
    if n_elements(thv) ne 0 then opdv=fltarr(szv(0),szv(1),5)
    cnt=0
    for i=0,4 do begin
        tmp=str.(i0+i)
        tmp.angle+=str.mountangle - p.camangle
        if tmp.type eq 'wp' then begin
            par={crystal:tmp.material,thickness:tmp.thicknessmm*1e-3,facetilt:tmp.facetilt*!dtor,lambda:lam,delta0:tmp.angle*!dtor}
            opd=opd(th(0),th(1),par=par,delta0=par.delta0,k0=k,kappa=kappat)/2/!pi & k/=!radeg ;& if not keyword_set(dbef) then opd = opd * (1-del*kappat)

                if n_elements(thv) ne 0 then opdv(*,*,cnt)=opd(thv(*,*,0),thv(*,*,1),par=par,delta0=par.delta0)/2/!pi


            cnt=cnt+1
;            part=par & part.lambda=part.lambda*(1+del)
;            opdt=opd(th(0),th(1),par=part,delta0=par.delta0)/2/!pi
;            if i eq 0 then opd=0.25

            if not keyword_set(quiet) then print,'thicknessmm=',tmp.thicknessmm,'facetilt:',tmp.facetilt,'opd=',opd,'k=',k,'angle=',par.delta0*!radeg

            if opd gt 100 then kappa=kappat

;            if not keyword_set(quiet) then print,opd/opdt, 1+kappat*del


        endif
        if tmp.type eq 'flc' then begin
            opd=tmp.delaydeg/360
            s=stat(tmp.sourceid,state)*2. - 1.
            par={delta0:(tmp.angle + s * tmp.switchangle/2)*!dtor}
            k=0.
            if not keyword_set(quiet) then print,'flc ','angle',par.delta0*!radeg,'retardance',tmp.delaydeg
        endif
        if tmp.type eq 'flc' or tmp.type eq 'wp' then begin
            tens=fourwp(par.delta0,opd,k,kvecxy=kvec)
            if n_elements(touts) eq 0 then begin
                touts=tens
                kouts=kvec
            endif else begin
                touts=tcontract(touts,tens)
                kouts=kouter(kouts,kvec)
            endelse
        endif
        if tmp.type eq 'pol' then begin
            mp=matpol(tmp.angle*!dtor)
            if not keyword_set(quiet) then print,'polariser at ',tmp.angle
            touts=leftmult(touts,mp)
            goto,out1
        endif
    endfor

    out1:

    souts=fltarr(n_elements(kouts(0,*))) + state
    if state eq 0 then begin
        tout=touts
        kout=kouts
        sout=souts
    endif else begin
        tout=[[[tout]],[[touts]]]
        kout=[[kout],[kouts]]
        sout=[sout,souts]
    endelse
    dum=temporary(touts)
endfor

tout0=tout(0,0,*)
tout1=tout(0,1,*)
tout2=tout(0,2,*)
tout3=tout(0,3,*)
toutc=abs(tout1)+abs(tout2)+abs(tout3)+abs(tout0)
kx=kout(0,*)
ky=kout(1,*)
kz=kout(2,*)

;tout=exp(complex(0,1) * 2*!pi*kz) * tout


idx=where(abs(toutc) gt 1d-5)
idxog=idx
;dum=where(kz(idx) ge 0) & idx=idx(dum)
ttmp=(str.mountangle - p.camangle)*!dtor + 1*!dtor
vec=[cos(ttmp),sin(ttmp)]
sgn=kx*vec(0)+ky*vec(1)

;plot,kx(idx),ky(idx),psym=4

dum=where(sgn(idx) ge 0) & idx=idx(dum)

;oplot,kx(idx),ky(idx),psym=4,col=2
;stop

kmax=100
dmax=10000
scal=kx/kmax * 100. + ky/kmax * 10. + sout*1000;+ kz/dmax
uq=uniq(scal(idx),sort(scal(idx)))


idxo=idx
idx=idx(uq)

if keyword_set(useindex) then idx=indexlist

nidx=n_elements(idx)
tmax=30;10
kzlist=fltarr(nidx,tmax)
toutlist=complexarr(4,4,nidx,tmax)
toutlistw=toutlist
toutsum=complexarr(4,4,nidx)
nkz=fltarr(nidx)
kxlist=fltarr(nidx)
kylist=kxlist
kzavlist=kxlist
kzrnglist=kxlist
slist=kxlist
if not keyword_set(useindex) then indexlist=intarr(nidx)
if n_elements(thv) ne 0 then begin
    kzv=fltarr(szv(0),szv(1),nidx)
    for i=0,nidx-1 do begin
;    rr=[2,0,1];
        rr=[0,1,-1]
        for cnt=0,3 do begin
            mult=rr[idx(i)/3^(3-cnt) mod 3]


            if cnt eq 0 then mult=0 ; for front wp make zero
;            print, 'i=',i,'cnt=',cnt,'mult=',mult
            kzv(*,*,i)+=mult * opdv(*,*,cnt)
;            if i eq 3 and cnt eq 3 then stop
        endfor
    endfor
;stop
endif

for i=0,nidx-1 do begin
    tmp=where(scal(idxo) eq scal(idx(i)))
    nf=n_elements(tmp)
    kzlist(i,0:nf-1) = kz(idxo(tmp))
    if not keyword_set(useindex) then indexlist(i)=idxo(tmp(0))
    kzavlist(i)=mean(kz(idxo(tmp)))
    kzrnglist(i)=max(kz(idxo(tmp))) - min(kz(idxo(tmp)))
    kxlist(i)=kx(idx(i))
    kylist(i)=ky(idx(i))
    slist(i)=sout(idx(i))
;    if not keyword_set(dbef) then fc = (1-del*kappa) else
   fc=1.
    for j=0,nf-1 do toutlist(*,*,i,j)=tout(*,*,idxo(tmp(j)))
    for j=0,nf-1 do toutlistw(*,*,i,j)=exp(2*!pi*complex(0,1)*abs(fc*kz(idxo(tmp(j)))))
    nkz(i)=nf
endfor
toutlistm=toutlist*toutlistw
for i=0,nidx-1 do begin
    for j=0,nkz(i)-1 do toutsum(*,*,i)+=toutlistm(*,*,i,j)
endfor
;delta lambda correction
;

;pcor=abs(kzavlist)*del*kappa*(-1)
;if not keyword_set(dbef) then for i=0,nidx-1 do toutsum(*,*,i)*=exp(pcor)


mat=reform(toutsum(0,*,*))

;stop
mat=mat ## rotmat(-p.camangle*!dtor)
;stop
getdxdy,kxlist,kylist,dkx,dky,rot=(str.mountangle - p.camangle)*!dtor,frac=frac
;stop
end
