pro skentraw, matr, rcoeffr,testt=testt,acoefft=acoefft,dchi=dchi,watch=watch,$
                   sets=sets,sigmar=sigmar,matr0=matr0,rcoeffr0=rcoeffr0,chisq=chisq
timeout=120.
t0=systime(1)
drangemax=1e6
fvallast=1e40
default,testt,0.02
default,dchi,0.
caim=n_elements(rcoeffr)


tmatr=transpose(matr)
na=n_elements(matr(*,0))
nm=n_elements(matr(0,*))

if n_elements(acoefft) eq 0 then begin
    acoefft=fltarr(na)
    acoefft(*)=1.
endif
common fblock2, matr_s, tmatr_s,rcoeff_s
matr_s = matr & rcoeff_s = rcoeffr & tmatr_s=tmatr

store=fltarr(10000,2)
cdone=0 
convg=0
entlast=0.
i=0L
itchisq=0L
while convg eq 0 do begin
    dfunc,acoefft,grads=grads,gradc=gradc,$
               ent=ent,chisq=chisq
    fval=chisq
    
    if (chisq le caim*1.001) then if (itchisq eq 0) then begin
        print,'now reached chisq around caim',chisq,caim
        itchisq=i
    endif

    if systime(1)-t0 gt timeout then begin
        print, 'timeout exiting'
        convg=1
    endif

    if i gt 12 then begin
        deval=(store(i-10:i-1,1)-store(i-11:i-2,1))
        devalmn=mean(deval)
    endif else devalmn=1e9

;    if (ent le entlast) and (i ge itchisq+100) and (itchisq ne 0) then begin
    if (devalmn lt 0.) and (i ge itchisq+100) and (itchisq ne 0) then begin        print, 'ent < entlast so terminating',i,itchisq,ent,entlast
        convg=1
    endif

    if i gt 12 then begin
        dfval=abs(store(i-10:i-1,0)-store(i-11:i-2,0))
        dfvalmn=mean(dfval)
    endif else dfvalmn=1e9

;    if (abs(fval-fvallast) lt dchi) and (cdone eq 0) then begin
    if (dfvalmn lt dchi) and (cdone eq 0) then begin
        caim=chisq
        print, 'redrirected caim to ',chisq
        cdone=1
    endif

    fvallast=fval
    entlast=ent
    e1=grads*(acoefft)^2
    e1=e1/sqrt(total(e1^2/acoefft^2))

    e2=gradc*(acoefft)^2
    e2=e2/sqrt(total(e2^2/acoefft^2))

    e3= (2*matr # (tmatr # e1))*acoefft^2   

    e4= (2*matr # (tmatr # e2))*acoefft^2   

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
        compcb = tmatr # e(*,be)
        compca = tmatr # e(*,al)
        compc = 2*total(compcb*compca)
        mmunu(al,be) = compc
    endfor
;    w=svdcomp(gmunu,u=u); & u=transpose(u)
    svdc,gmunu,w,u,dum
    wi=1/w
    idx=where(w lt max(w)/1e6)
    if idx(0) ne -1 then begin
;        print, 'warning protecting against bad svs',w/max(w)
        wi(idx)=0.
;        w(idx)=0.
    endif

    mmunupp = diag_matrix(sqrt(wi)) # transpose(u) # mmunu # u # diag_matrix(sqrt(wi))
;    z=svdcomp(mmunupp,u=v); & v=transpose(v)
    svdc,mmunupp,z,v,dum

    smuppp = smu # u # diag_matrix(sqrt(wi)) # v
    cmuppp = cmu # u # diag_matrix(sqrt(wi)) # v

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
    l2 = total(xppp *xppp)
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
    x = u # diag_matrix(sqrt(wi)) # v # xppp

    diff = e # x
    acoefft = acoefft + diff
    lm=(max(acoefft)/drangemax)
    idxlm=where(acoefft lt lm)
    if idxlm(0) ne -1 then print, 'warning applying threshold',it
    acoefft=acoefft>lm


    store(i,0)=chisq
    store(i,1)=ent

    testv=grads/sqrt(total(grads^2)) - gradc/sqrt(total(gradc^2))
    test=(total(testv^2))*0.5
    print,'chisq,ent,l2,test,caim',chisq,ent,l2,test,caim

    if (test lt testt) and ((chisq-caim)/(chisq+caim) lt 0.01)  then convg=1
    if it ge 9999 then convg=1
    i=i+1
    if (watch gt 0) then if ((i mod watch) eq 0 ) and (i gt 0) then begin
        !p.multi=[0,2,2]
        contourn2,alog10(reform(acoefft,sets.nx,sets.ny)),sets.kx,sets.ky,/nice
        plot,rcoeffr0
        oplot,transpose(matr0) # acoefft,col=2
        plot,rcoeffr0-transpose(matr0) # acoefft
        oplot,sigmar,col=2
        oplot,-sigmar,col=2
        !p.multi=0
    endif

endwhile

print, 'total num of iter = ',i
;return, acoefft;reform(acoefft,sets.nx,sets.ny)



end

