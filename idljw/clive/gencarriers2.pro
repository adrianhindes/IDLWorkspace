
pro gencarriers2,th=th,sh=sh,mat=a2,dmat=da2,tdkz=dkzlist,kx=kxlist,ky=kylist,kz=kzavlist,tkz=kzlist,nkz=nkz,dkx=dkx,dky=dky,quiet=quiet,p=p,str=str,noload=noload,toutlist=toutlist,vth=thv,indexlist=indexlist,vkzv=kzv,lam=lam,frac=frac,fudgethick=fudgethick,useindex=useindex,slist=slist,stat=stat,nstates=nstates,kappa=kappa,db=db

default,lam,656.1e-9 
if not keyword_set(noload) then readpatch,sh,p,db=db
if not keyword_set(noload) then readcell,p.cellno,str

if not keyword_set(quiet) then print,p.cellno

tn=tag_names(str)
i0=value_locate(tn,'WP1')
nstates=1
max_crystal=6;5
for i=0,max_crystal do begin
    if str.(i0+i).type eq 'flc' then nstates=nstates*2
endfor

if nstates eq 4 then stat=transpose([[0,0,1,1],[0,1,0,1]])
if nstates eq 2 then stat=transpose([[0,1],[0,0]])

;th=[3,3.]*!dtor
;th=[3.,0.]*!dtor
;th=[0.,0.]
for state=0,nstates-1 do begin

    szv=size(thv,/dim)
    if n_elements(thv) ne 0 then opdv=fltarr(szv(0),szv(1),max_crystal)
    cnt=0
    for i=0,max_crystal do begin
        tmp=str.(i0+i)
        tmp.angle+=str.mountangle - p.camangle
        if tmp.type eq 'wp' then begin
            par={crystal:tmp.material,thickness:keyword_set(fudgethick) ? fudgethick : tmp.thicknessmm*1e-3,facetilt:tmp.facetilt*!dtor,lambda:lam,delta0:tmp.angle*!dtor}
            opd=opd(th(0),th(1),par=par,delta0=par.delta0,k0=k,kappa=kappat)/2/!pi & k/=!radeg ;& if not keyword_set(dbef) then opd = opd * (1-del*kappat)

                if n_elements(thv) ne 0 then opdv(*,*,cnt)=opd(thv(*,*,0),thv(*,*,1),par=par,delta0=par.delta0)/2/!pi


            cnt=cnt+1
;            part=par & part.lambda=part.lambda*(1+del)
;            opdt=opd(th(0),th(1),par=part,delta0=par.delta0)/2/!pi
;            if i eq 0 then opd=0.25

            if not keyword_set(quiet) then print,'thicknessmm=',tmp.thicknessmm,'facetilt:',tmp.facetilt,'opd=',opd,'k=',k,'angle=',par.delta0*!radeg,'kappathis=',kappat

            if opd[0] gt 100 then kappa=kappat

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
            cntmax=cnt-1

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

if ttmp*!radeg gt 1.000 then sgn*=-1
;plot,kx(idx),ky(idx),psym=4
dum=where(sgn[idx] ge 0) & idx=idx(dum)

;oplot,kx(idx),ky(idx),psym=4,col=2

kmax=100
dmax=10000
scal=kx/kmax * 100. + ky/kmax * 10. + sout*1000;+ kz/dmax
uq=uniq(scal(idx),sort(scal(idx)))
idxo=idx
idx=idx(uq)

if keyword_set(useindex) then idx=indexlist

nidx=n_elements(idx)
tmax=30
kzlist=fltarr(nidx,tmax)
t3=complexarr(4,nidx,tmax)
da2=complexarr(4,nidx)
a2=da2
nkz=fltarr(nidx)
kxlist=fltarr(nidx)
kylist=kxlist
kzavlist=kxlist
kzrnglist=kxlist
slist=kxlist
if not keyword_set(useindex) then indexlist=intarr(nidx)

dkzlist=kzlist
for i=0,nidx-1 do begin
    tmp=where(scal(idxo) eq scal(idx(i)))
    nf=n_elements(tmp)
    kzlist(i,0:nf-1) = kz(idxo(tmp))

    kzavlist(i)=mean(kz(idxo(tmp)))
;    print,kzavlist(i)

    dkzlist(i,0:nf-1)= kz(idxo(tmp)) - kzavlist(i)
    if not keyword_set(useindex) then indexlist(i)=idxo(tmp(0))
    kzrnglist(i)=max(kz(idxo(tmp))) - min(kz(idxo(tmp)))
    kxlist(i)=kx(idx(i))
    kylist(i)=ky(idx(i))
    slist(i)=sout(idx(i))
    nkz(i)=nf
    for j=0,nf-1 do t3(*,i,j)=tout(0,*,idxo(tmp(j)))
    for beta=0,3 do for j=0,nf-1 do da2(beta,i) += t3(beta,i,j)*exp(2*!pi*complex(0,1)*(dkzlist(i,j)))

    for beta=0,3 do for j=0,nf-1 do a2(beta,i) += t3(beta,i,j)*exp(2*!pi*complex(0,1)*abs(kzlist(i,j)))

endfor

;a2=a2 ## rotmat(p.camangle*!dtor)
;da2=da2 ## rotmat(p.camangle*!dtor)

getdxdy,kxlist,kylist,dkx,dky,rot=(str.mountangle - p.camangle)*!dtor,frac=frac

if n_elements(thv) ne 0 then begin
    kzv=fltarr(szv(0),szv(1),nidx)
    for i=0,nidx-1 do begin
;    rr=[2,0,1];

        if strmid(p.cellno,0,4) eq 'msea' and p.cellno ne 'msea2013' then begin
            kzv(*,*,i) = opdv(*,*,1) * ( (kzavlist(i) eq 0) ? 0 : 1)
        endif else if p.cellno eq 'msea2013' then begin
            kzv(*,*,i) = (opdv(*,*,1)+opdv(*,*,2)) * ( (kzavlist(i) eq 0) ? 0 : 1)
        endif else begin
            rr=[0,1,-1]
;            cntmax=2 ; 3
            for cnt=0,cntmax do begin
                mult=rr[idx(i)/3^(cntmax-cnt) mod 3]
                if strmid(str.wp1.id,0,3) eq 'qwp'then if cnt eq 0 then mult=0 ; for front wp make zero
                if strmid(str.(cnt+2).id,0,3) eq 'hwp' then mult=0 ; hwp no contribute
                print, 'i=',i,'cnt=',cnt,'mult=',mult,'id=',str.(cnt+2).id
                kzv(*,*,i)+=mult * opdv(*,*,cnt)
;            if i eq 3 and cnt eq 3 then stop
            endfor
        endelse
;        stop
     endfor
    if p.cellno eq 'msestrue21ttas' then begin
       kzv(*,*,3) = -(opdv(*,*,0) - opdv(*,*,3)) + opdv(*,*,1) + opdv(*,*,4)
    endif
endif

end
