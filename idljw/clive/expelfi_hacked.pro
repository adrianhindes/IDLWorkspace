@fidacalcnew
@transpeq
@mytri
@ncufstruct


pro deleteres,zi,rp,zp,zeta,en,eqstr,freqw=freqw,frac=frac,mask=mask

;    pos=transpose([rp,0,zp])
;    pos=[1.
;    rag=getrag(pos,eqstr)
    rag=0.5 & eqstr={rax:0.95*100, aminor:0.5*100}
    rp=eqstr.rax + rag * eqstr.aminor
    qu=2;getq(pos,eqstr)

    nzeta=21
    zeta1=(linspace(-1,1,nzeta+2))(1:nzeta)
    nen=21
    en1=linspace(0,60e3,nen)
    zeta=zeta1
    en=en1
;    zeta=zeta1 # replicate(1,nen)
;    en = replicate(1,nzeta) # en1

;    epsilon = abs(rp-eqstr.rax)/eqstr.rax  
    epsilon=rag * eqstr.aminor / eqstr.rax
    lambda = (1-zeta^2) * rp / eqstr.rax
;    print,rp,eqstr.rax
;    stop
    kpar = (1-lambda * (1-epsilon))/2/epsilon/lambda
    np=100
    ratpas = 2 * elliptic_int2(1/kpar,1,np=np) /!pi/sqrt(1-lambda*(1-epsilon))

    rattrap = 4 * elliptic_int2(kpar,1,np=np) /!pi/sqrt(2*epsilon*lambda)

    rat=lambda & rat(*)=0. 
    idxpas=where(kpar gt 1)
    idxtrap=where(kpar lt 1)
    if idxpas(0) ne -1 then rat(idxpas)=ratpas(idxpas)
    if idxtrap(0) ne -1 then rat(idxtrap)=rattrap(idxtrap);
;    rat=rattrap ; only intreested in these ones!
    vel = sqrt(2*1.6e-19*en/2./1.67e-27)
    rpinmetres=rp/100. ; remember!
    taupar = 2*!pi* qu * rpinmetres / vel
    tau = taupar # rat
    freq=1/tau

;    frot =  vtor1/2/!pi/rpinmetres
    freqw = 60e3  ; - 1 *frot
    contourn2,freq,en,zeta,/cb,offx=1.,pos=posarr(1,1,0,cnx=0.2,cny=0.1),xtitle='energy/ev',ytitle='vpar/v',ztitle='toroidal precession frequency'

;    b9=0.5
;    dens9=5e19
;    mu0=4*!pi*1e-7
;    valf = b9 / sqrt(mu0 * dens9 * 1.67e-27*2)
;    taualf=2*!pi*rpinmetres*qu / valf
;    taualf = 1./16000. ; from exp

 ;    contour,freq/freqw,en,zeta,xtit='En/eV',ytit='vpar/v',lev=[.9,1.1],/noer,title=rp

    vw=freqw * rat * 2*!pi*qu/rpinmetres
    enw1=0.5*2*1.67e-27*vw^2/1.6e-19 * frac(0)^2
    enw2=0.5*2*1.67e-27*vw^2/1.6e-19 * frac(1)^2
    nzeta=n_elements(zeta)
    nen=n_elements(en)
    en2=en # replicate(1,nzeta)
    zeta2=replicate(1,nen) # zeta
    enw12 = replicate(1,nen) # enw1 
    enw22 = replicate(1,nen) # enw2
    if mask eq -1 then idx=where(en2 ge enw12 and en2 le enw22)
    if mask eq 1 then idx=where(en2 lt enw12 or en2 gt enw22)
    if idx(0) ne -1 then zi(idx)=0.
    

;    stop

;    for i=0,nzeta-1 do begin
;        idx=where(en ge enw1(i) and en le enw2(i))
;        if idx(0) ne -1 then zi(idx,i)=0. ;print,i,n_elements(idx) else print,i,0
;    endfor

    stop
;    contourn2,zi,en,zeta,xtit='En/eV',ytit='vpar/v',title=string(rp,zp)
    oplot,enw1,zeta,thick=2
    oplot,enw2,zeta,thick=2
;stop
end


;goto,e
pro expelfi, sh=sh,tw=tw,run=run,fid=fid,freqw=freqw,frac=frac,mask=mask,suffout=suffout, enrng=enrng,zetarng=zetarng,doshow=show,bulk=bulk

default,freqw,60e3                    ; - 1 *frot
default,frac,[.9,1.1]
default,mask,1
default,zetarng,[-1,1.]
;sh=23311 & tw=0.16 & run='V01' & fid='3'


fil=trmakefil(sh=sh,run=run)
filfi=trmakefilfi(sh=sh,run=run,fid=fid)
filfiout=trmakefilfi(sh=sh,run=run,fid=fid,suffout=suffout)

;fil='/fuslwv/scratch/cmichael/mc3_tmp/'+ssh+'/'+run+'/'+ssh+run+'.CDF'
;filfi='/fuslwv/scratch/cmichael/mc3_tmp/'+ssh+'/'+run+'/'+ssh+run+'_fi_'+fid+'.cdf'

;filfiout='/fuslwv/scratch/cmichael/mc3_tmp/'+ssh+'/'+run+'/'+ssh+run+'_fi_'+fid+'_'+suffout+'.cdf'

ncopen,filfi
ncadd,'*',f,/init,/noattr
if sh ne 25036 then tw=f.time
nclist,'*'
ncopen,fil
;nclist,'*'
;stop
ncadd,'TIME',time,/init
iw=value_locate(time.(0),tw)
transpeq,iw,eqstr
ncadd,'X',db
xtransp=db.x(*,iw)

ncadd,'TI',db
tiprof=db.ti(*,iw)

ncadd,'NE',db
neprof=db.nene(*,iw)*1e6 ; to m-3

ncadd,'VTORX_NC',db
vtorprof=db.vtorx_nc(*,iw)/100. ; to m/s
vtorprof=interpol([100e3,0],[0,1],xtransp)

e:

np=n_elements(f.r2d)

zeta=f.a_d_nbi
en=f.e_d_nbi

dzeta=zeta(1)-zeta(0)
den=en(1)-en(0)
;fdens=totaldim(f.f_d_nbi,[1,2])*dzeta*den
;contourn2,fdens,f.r2d,f.z2d,/irr,/cb

;f_d_nbi=f.f_d_nbi
for i=0,np-1 do begin
;  
    rp=f.r2d(i)
    zp=f.z2d(i)
    if keyword_set(bulk) then begin
        pos=transpose([rp,0,zp])
        rag=getrag(pos,eqstr)
        ni1=interpol(neprof,xtransp,rag)
        ti1=interpol(tiprof,xtransp,rag)
        vtor1=interpol(vtorprof,xtransp,rag)
        zih=gyrogauss(en,zeta,ni1,ti1,vtor1)/1e6*2
        zi=f.f_d_nbi(*,*,i)+zih
    endif else $
      zi=f.f_d_nbi(*,*,i)

    
    if not keyword_set(enrng) then $
      deleteres,zi,rp,zp,zeta,en,eqstr,freq=freqw,frac=frac,mask=mask $
    else begin
        nzeta=n_elements(zeta)
        nen=n_elements(en)
        en2=en # replicate(1,nzeta)
        zeta2=replicate(1,nen) # zeta

        if mask eq -1 then idx=where(en2 ge enrng(0) and en2 le enrng(1) and zeta2 ge zetarng(0) and zeta2 le zetarng(1))
        if mask eq 1 then idx=where( en2 lt enrng(0) or en2 gt enrng(1) or zeta2 lt zetarng(0) or zeta2 gt zetarng(1))
        zi(idx)=0.
    endelse
    f.f_d_nbi(*,*,i)=zi
    if keyword_set(show) then if max(zi)-min(zi) ne 0 then contourn2,zi,en,zeta,xtit='En/eV',ytit='vpar/v',title=string(rp,zp)

print,i,np
endfor

ncdfwrite,filfiout,filfi,'F_D_NBI',f.f_d_nbi
;fdens2=totaldim(f.f_d_nbi,[1,2])*dzeta*den
;!p.multi=[0,1,2]
;contourn2,fdens,f.r2d,f.z2d,/irr,/cb
;contourn2,fdens2,f.r2d,f.z2d,/irr,/cb
;!p.multi=0

end


pro test1
sh=23311 & tw=0.16 & run='V01' & fid='3'
freq=60e3 & frac=[.9,1.1] & mask=1 & suffout='r60f0911' & show=1
expelfi, sh=sh,tw=tw,run=run,fid=fid,freqw=freqw,frac=frac,mask=mask,suffout=suffout, enrng=enrng,zetarng=zetarng,doshow=show
end

pro test1b
sh=23311 & tw=0.16 & run='V01' & fid='3'
freq=60e3 & frac=[.7,1.3] & mask=1 & suffout='r60f0713' & show=1
expelfi, sh=sh,tw=tw,run=run,fid=fid,freqw=freqw,frac=frac,mask=mask,suffout=suffout, enrng=enrng,zetarng=zetarng,doshow=show
end

pro test1c
sh=23311 & tw=0.16 & run='V01' & fid='3'
freq=60e3 & frac=[.5,1.5] & mask=1 & suffout='r60f0515' & show=1
expelfi, sh=sh,tw=tw,run=run,fid=fid,freqw=freqw,frac=frac,mask=mask,suffout=suffout, enrng=enrng,zetarng=zetarng,doshow=show
end

pro test1c_b
sh=23311 & tw=0.16 & run='V01' & fid='3'
freq=60e3 & frac=[.5,1.5] & mask=1 & suffout='r60f0515bk' & show=1
expelfi, sh=sh,tw=tw,run=run,fid=fid,freqw=freqw,frac=frac,mask=mask,suffout=suffout, enrng=enrng,zetarng=zetarng,doshow=show,/bulk
end


pro test2
;sh=23311 & tw=0.16 & run='V01' & fid='3'
sh=25036 & tw=0.18 & run='V04' & fid='1'
;enrng=[10e3,20e3] & mask=1 & suffout='e1020' & show=1
enrng=[50e3,70e3] & mask=1 & suffout='e5070' & show=1
expelfi, sh=sh,tw=tw,run=run,fid=fid,enrng=enrng,mask=mask,suffout=suffout,doshow=show;,/bulk
end



deleteres
end
