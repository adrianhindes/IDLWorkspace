pro skentraw4, matrtot, rcoeffrtot,testt=testt,acoefft=acoeffttot,dchi=dchi,watch=watch,$
                   sets=sets,sigmar=sigmartot,matr0=matr0tot,rcoeffr0=rcoeffr0tot,chisq=chisq
timeout=120.
t0=systime(1)
drangemax=1e6
fvallast=1e40
default,testt,0.02
default,dchi,0.
caim=n_elements(rcoeffrtot)


sz=size(matrtot,/dim)
tmatrtot=fltarr(sz(1),sz(0),sz(2))
for i=0,sets.nf/2-1 do tmatrtot(*,*,i)=transpose(matrtot(*,*,i))
na=n_elements(matrtot(*,0,0))
nm=n_elements(matrtot(0,*,0))

common fblock2, matr_s, tmatr_s,rcoeff_s

store=fltarr(10000,2)
cdone=0 
convg=0
entlast=0.
i=0L
itchisq=0L
while convg eq 0 do begin
    ent=0. & chisq=0.
    etot=fltarr(na,4,sets.nf/2)
    cmutot=fltarr(4*sets.nf/2)
    smutot=fltarr(4*sets.nf/2)
    gmunubl=fltarr(4,4,sets.nf/2)
    mmunubl=fltarr(4,4,sets.nf/2)
    for f=0,sets.nf/2-1 do begin
        matr_s = matrtot(*,*,f) & rcoeff_s = rcoeffrtot(*,f) & tmatr_s=tmatrtot(*,*,f)
        acoefft=acoeffttot(*,f)
        dfunc,acoefft,grads=grads,gradc=gradc,$
              ent=ent1,chisq=chisq1
        chisq=chisq+chisq1
        ent=ent+ent1

        e1=grads*(acoefft)^2
        e1=e1/sqrt(total(e1^2/acoefft^2))
        
        e2=gradc*(acoefft)^2
        e2=e2/sqrt(total(e2^2/acoefft^2))
        
        e3= (2*matr_s # (tmatr_s # e1))*acoefft^2   
        
        e4= (2*matr_s # (tmatr_s # e2))*acoefft^2   
        
;    e5 = e3 - e4
;    e5 = e5 /sqrt(total(e5^2))
        
        e3=e3/sqrt(total(e3^2/acoefft^2))
        e4=e4/sqrt(total(e4^2/acoefft^2))
        e = [[e1],[e2],[e3],[e4]]
        ns=4
;    e = [[e1],[e2],[e5]]
;    ns=3
        smu = grads # e
        cmu = gradc # e
        gmunu = fltarr(ns,ns)
        mmunu = fltarr(ns,ns)
        gmunu2 = fltarr(ns,ns)
        mmunu2 = fltarr(ns,ns)
        for al=0,ns-1 do for be=0,ns-1 do begin
            gmunu(al,be) = total(e(*,al) * e(*,be)/acoefft^2)
            compcb = tmatr_s # e(*,be)
            compca = tmatr_s # e(*,al)
            compc = 2*total(compcb*compca)
            mmunu(al,be) = compc
        endfor
        etot(*,*,f)=e
        cmutot(f*4:f*4+3)=cmu
        smutot(f*4:f*4+3)=smu
        gmunubl(*,*,f)=gmunu
        mmunubl(*,*,f)=mmunu
    endfor
    gmunutot=blint(gmunubl)
    mmunutot=blint(mmunubl)


    ; rename variables
    gmunu=gmunutot
    mmunu=mmunutot
    smu=smutot
    cmu=cmutot
        
        
    svdc,gmunu,w,u,dum
;    w=svdcomp(gmunu,u=u); & u=transpose(u)
    wi=1/w
    idx=where(w lt max(w)/1e6)
    if idx(0) ne -1 then begin
;        print, 'warning protecting against bad svs',w/max(w)
        wi(idx)=0.
;        w(idx)=0.
    endif

    mmunupp = diag(sqrt(wi)) # transpose(u) # mmunu # u # diag(sqrt(wi))
;    z=svdcomp(mmunupp,u=v); & v=transpose(v)
    svdc,mmunuppp,z,v,dum

    smuppp = smu # u # diag(sqrt(wi)) # v
    cmuppp = cmu # u # diag(sqrt(wi)) # v

    zi=1/z
    idxz=where(z lt max(z)/1e6)
    if idxz(0) ne -1 then zi(idxz)=0.
    cmin = chisq - 0.5 * total(zi * cmuppp^2)
    caimt = max([0.66*cmin+0.34*chisq, caim])
    common alfunb, smupppb,cmupppb, zb, idxb,chisqb, caimtb,penb
    smupppb=smuppp & cmupppb=cmuppp & zb=z & idxb=idx & chisqb=chisq&caimtb=caimt

    xg=max(z);norm(transpose(cmuppp))/norm(transpose(smuppp))
    pen=0.
    l2thres=1.0;0.3
    l2=1e11
    pmax=1e15
    pmin=0.
    ahigh=0.9e15
    adiff=0.001

    starr=fltarr(10000,9)
    iparr=fltarr(10000)
    ipi=0
    it=0
    dopr=0
ret1:
    amin=0.
    amax=1e15
    alnew = 0.;1.e2;amin
ret2:
    penb=pen
    dummy=alfun(alnew,xppp=xppp,cpen=cpen,cee=c)
    l2 = total(xppp *xppp)/(sets.nf/2)
;    print,it,alnew,l2,l2thres,pen
;    if (it mod 100) eq 0 then stop
;    if it ge 50 then dopr=1
;    if it ge 50 then stop
    it=it+1

    if cpen gt chisq then begin
        ; chop alpha down
       if dopr eq 1 then print,'alpha down cp>c0'
        amax=alnew
        alnew=(amax+amin)/2.
        goto, achopfinishq
    endif
    if (c lt caimt) or (l2 gt l2thres) then begin
        ; chop alpha up
        if dopr eq 1 then print, 'alpha up c<caimt, l2>l2thres'
        amin=alnew
        alnew=(amax+amin)/2.
        goto,achopfinishq
    endif
    xppps=xppp
    ; chop alpha down
    if dopr eq 1 then print, 'alpha down default'
    amax=alnew
    alnew=(amax+amin)/2.
    achopfinishq:
    ; alpha chop finished if alpha=ahigh or (amax-amin)/(amax+amin) lt adiff
    achopfinish=0
    if (alnew ge ahigh) or ( (amax-amin)/(amax+amin) lt adiff ) then achopfinish=1
    if dopr eq 1 then print, 'achopfinishq', (amax-amin)/(amax+amin), alnew
    if achopfinish eq 0 then goto,ret2
    ; achop successful?
    asuccess=0
    if (amax-amin)/(amax+amin) lt adiff then asuccess=1
    if l2 lt l2thres then asuccess=1
    if asuccess eq 0 then begin
       if dopr eq 1 then print, 'a chop fail p increase',pen
        ; increase p
        iparr(ipi)=it
        ipi=ipi+1
        pmin=pen
        pen=(pmax+pmin)/2.
        goto, ret1
    endif
    if dopr eq 1 then print, 'a chop success',alnew
    pchopfinish = 0
    if (pmax-pmin)/(pmax+pmin) lt adiff then pchopfinish=1
    if ((pen eq 0) or (pchopfinish eq 1)) ne 1 then begin
        iparr(ipi)=it
        ipi=ipi+1
        ;p chop success
        if dopr eq 1 then print,'pchopsuccess p decrease',pen
        pmax=pen
        pen=(pmax+pmin)/2.
        goto,ret1
    endif

    xppp=transpose(xppp)
    snew = ent + total(smuppp * xppp) - 0.5*total(xppp*xppp)
    cnew = chisq + total(cmuppp * xppp) + 0.5 * total(z * xppp^2)
    x = u # diag(sqrt(wi)) # v # xppp

    diff = acoeffttot & diff(*,*)=0.
    for ii=0,sets.nf/2-1 do for jj=0,3 do diff(*,ii)=diff(*,ii)+x(4*ii+jj)*etot(*,jj,ii)
    acoeffttot = acoeffttot + diff
    for ii=0,sets.nf/2-1 do begin
        lm=(max(acoeffttot(*,ii))/drangemax)
        idxlm=where(acoeffttot(*,ii) lt lm)
        if idxlm(0) ne -1 then print, 'warning applying threshold',it
        acoeffttot(*,ii)=acoeffttot(*,ii)>lm
    endfor

    store(i,0)=chisq
    store(i,1)=ent

;    testv=grads/sqrt(total(grads^2)) - gradc/sqrt(total(gradc^2))
;    test=(total(testv^2))*0.5
    test=1.
    print,'chisq,ent,l2,test,caim,it',chisq,ent,l2,test,caim,it

    if (test lt testt) and ((chisq-caim)/(chisq+caim) lt 0.01)  then convg=1
    if it ge 9999 then convg=1
    i=i+1
    if (watch gt 0) then if ((i mod watch) eq 0 ) and (i gt 0) then begin
        !p.multi=[0,5,4]
        for ii=0,sets.nf/2-1 do begin
            contourn2,alog10(reform(acoeffttot(*,ii),sets.nx,sets.ny)),sets.kx,sets.ky,/nice
;            plot,rcoeffr0tot(*,ii)
;            dum=acoeffttot(*,ii)
;            dum1=transpose(matr0tot(*,*,ii))
;            oplot,dum1 # dum,col=2
        endfor
        !p.multi=0
    endif



endwhile

print, 'total num of iter = ',i
;return, reform(acoefft,sets.nx,sets.ny)



end

