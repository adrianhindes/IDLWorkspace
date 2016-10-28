@pseudoinvtomoc
function Power, a, p
return, a^p
end

function fourwp, r,d,k,kvecxyz=kvecxyz
Pi=!pi


mat0=$
[[$
Sqrt(2*Pi),$
0,$
0,$
0],$
[$
0,$
Sqrt(2*Pi)*Power(Cos(2*r),2),$
Sqrt(Pi/2.)*Sin(4*r),$
0],$
[$
0,$
Sqrt(Pi/2.)*Sin(4*r),$
Sqrt(2*Pi)*Power(Sin(2*r),2),$
0],$
[$
0,$
0,$
0,$
0]]
matp=[$
[$
0,$
0,$
0,$
0],$
[$
0,$
Sqrt(Pi/2.)*Power(Sin(2*r),2),$
-(Sqrt(Pi/2.)*Sin(4*r))/2.,$
Complex(0,1)*Sqrt(2*Pi)*Cos(r)*Sin(r)],$
[$
0,$
-(Sqrt(Pi/2.)*Sin(4*r))/2.,$
Sqrt(Pi/2.)*Power(Cos(2*r),2),$
Complex(0,-1)*Sqrt(Pi/2.)*Cos(2*r)],$
[$
0,$
Complex(0,-1)*Sqrt(2*Pi)*Cos(r)*Sin(r),$
Complex(0,1)*Sqrt(Pi/2.)*Cos(2*r),$
Sqrt(Pi/2.)]]

matn=conj(matp)


kvec=[0,1,-1]*k
kvecx=kvec * cos(r)
kvecy=kvec * sin(r)
kvecz=[0,1,-1]*d
kvecxyz=transpose([[kvecx],[kvecy],[kvecz]])
tens=complexarr(4,4,3)
tens(*,*,0)=mat0
tens(*,*,1)=matp
tens(*,*,2)=matn
return,tens
end


function tcontract,tens1,tens2
sz1=size(tens1,/dim) ; 4x4;n
sz2=size(tens2,/dim) ; 4x4;m .e.g. 3
n1=sz1(2)
n2=sz2(2)
n=n1*n2
szout=sz1 & szout(2)=n
tout=complexarr(szout)
for i=0,3 do for j=0,3 do for k1=0,n1-1 do for k2=0,n2-1 do begin
    tout(i,j,k1*n2 + k2)=total(tens1(i,*,k1)*tens2(*,j,k2))
endfor
return,tout
end

function kouter,kay1,kay2
sz1=size(kay1,/dim)
sz2=size(kay2,/dim)
n1=sz1(1)
n2=sz2(1)
n=n1*n2
szout=sz1 & szout(1)=n
kout=fltarr(szout)
for i=0,2 do for k1=0,n1-1 do for k2=0,n2-1 do begin
    kout(i,k1*n2+k2)=kay1(i,k1)+kay2(i,k2)
endfor

return,kout
end


function leftmult,tensmat,regmat
sz1=size(tensmat,/dim) 
sz2=size(regmat,/dim) 
nd2=n_elements(sz1)
n1=sz1(2)
szout=sz1
tensmult=tensmat*0

for i=0,3 do for j=0,3 do for k1=0,n1-1 do $
    tensmult(i,j,k1)=total(regmat(*,i) * tensmat(j,*,k1))

return,tensmult
end
function rightmultmatrix,tensmat,regmat
sz1=size(tensmat,/dim) 
sz2=size(regmat,/dim) 
nd2=n_elements(sz1)
n1=sz1(2)
szout=sz1
tensmult=tensmat*0

for i=0,3 do for j=0,3 do for k1=0,n1-1 do $
    tensmult(i,j,k1)=total(regmat(i,*) * tensmat(*,j,k1))

return,tensmult
end


function rightmult,tensmat,vec
sz1=size(tensmat,/dim) 
sz2=size(vec,/dim) 
n1=sz1(2)
szout=sz1
tensmult=complexarr([4,sz1(2)])

for i=0,3 do for k1=0,n1-1 do $
    tensmult(i,k1)=total(tensmat(i,*,k1) * vec)
return,tensmult
end

function matrot, r
mat=[$
[1.,0,0,0],$
[0,cos(2*r),sin(2*r),0],$
[0,-sin(2*r),cos(2*r),0],$
[0,0,0,1.]]
return,mat
end


function matpol, r
matpol=$
[[$
0.5,$
Cos(2*r)/2.,$
Sin(2*r)/2.,$
0],$
[$
Cos(2*r)/2.,$
Power(Cos(2*r),2)/2.,$
(Cos(2*r)*Sin(2*r))/2.,$
0],$
[$
Sin(2*r)/2.,$
(Cos(2*r)*Sin(2*r))/2.,$
Power(Sin(2*r),2)/2.,$
0],$
[$
0,$
0,$
0,$
0]]
return,matpol
end

pro test1
;test
tens0=fourwp(!pi/4,0.25,0.,kvecxy=kvec0)
tens1=fourwp(0,1000.,1,kvecxy=kvec1)
tens2=fourwp(!pi/4,707,0.707,kvecxy=kvec2)
tens3=fourwp(-!pi/4,707,0.707,kvecxy=kvec3)

tout=tcontract(tcontract(tcontract(tens0,tens1),tens2),tens3)

kout=kouter(kouter(kouter(kvec0,kvec1),kvec2),kvec3)
mp=matpol(0)
toutc=leftmult(tout,mp)

tout=rightmult(toutc,[1,1,0,0])
tout=reform(tout(0,*))


kx=kout(0,*)
ky=kout(1,*)
kz=kout(2,*)

fac=exp(complex(0,1) * 2*!pi*kz) 
tout=fac* tout

idx=where(abs(tout) gt 1d-5)
defcirc,/fill
plot,kx,ky,psym=4
plotss,kx,ky,abs(tout),scal=max(abs(tout))/4,psym=8,/nopl,col=2

;lotss,kx,ky,abs(toutc(0,1,*)*fac),psym=8,/nopl,col=2
;lotss,kx,ky,abs(toutc(0,2,*)*fac),psym=8,/nopl,col=3
;lotss,kx,ky,abs(toutc(0,3,*)*fac),psym=8,/nopl,col=4

;plot,kx(idx),ky(idx),psym=4,xr=[-3,3],yr=[-3,3],/iso,symsize=2
;oplot,kx,ky,psym=5,col=2


nterm=n_elements(idx)
for i=0,nterm-1 do print,kz(idx(i)),tout(idx(i)),kx(idx(i)),ky(idx(i))
;kx1=linspace(0,
stop
end



pro getdxdy, kx, ky,dx,dy
n=n_elements(kx)
dxa=fltarr(n,n)
dya=dxa
maxx=10000.
for i=0,n-1 do for j=0,n-1 do begin
    dxa(i,j)=abs(kx(i)-kx(j))
    dya(i,j)=abs(ky(i)-ky(j))
    if dxa(i,j) lt 1e-5 then dxa(i,j)=maxx
    if dya(i,j) lt 1e-5 then dya(i,j)=maxx
endfor
dx=min(dxa)
dy=min(dya)
end





pro test2,del,save=save,dbef=dbef,nocor=nocor
;del=0
;save=0
lam=656.1e-9 * (keyword_set(dbef) ? (1+del) : 1.)
readpatch,7345,p
readcell,p.cellno,str
print,p.cellno

tn=tag_names(str)
i0=value_locate(tn,'WP1')
nstates=1
for i=0,4 do begin
    if str.(i0+i).type eq 'flc' then nstates=nstates*2
endfor

stat=transpose([[0,0,1,1],[0,1,0,1]])

th=[3,3.]*!dtor
;th=[3.,0.]*!dtor
;th=[0.,0.]
for state=0,nstates-1 do begin
    for i=0,4 do begin
        tmp=str.(i0+i)
        tmp.angle+=str.mountangle - p.camangle
        if tmp.type eq 'wp' then begin
            par={crystal:tmp.material,thickness:tmp.thicknessmm*1e-3,facetilt:tmp.facetilt*!dtor,lambda:lam,delta0:tmp.angle*!dtor}
            opd=opd(th(0),th(1),par=par,delta0=par.delta0,k0=k,kappa=kappat)/2/!pi & k/=!radeg ;& if not keyword_set(dbef) then opd = opd * (1-del*kappat)
;            part=par & part.lambda=part.lambda*(1+del)
;            opdt=opd(th(0),th(1),par=part,delta0=par.delta0)/2/!pi
            if i eq 0 then opd=0.25

            print,'thicknessmm=',tmp.thicknessmm,'facetilt:',tmp.facetilt,'opd=',opd,'k=',k,'angle=',par.delta0*!radeg
            if opd gt 100 then kappa=kappat

;            print,opd/opdt, 1+kappat*del

        endif
        if tmp.type eq 'flc' then begin
            opd=tmp.delaydeg/360
            s=stat(tmp.sourceid,state)*2. - 1.
            par={delta0:(tmp.angle + s * tmp.switchangle/2)*!dtor}
            k=0.
            print,'flc ','angle',par.delta0*!radeg,'retardance',tmp.delaydeg
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
            print,'polariser at ',tmp.angle
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
dum=where(sgn(idx) ge 0) & idx=idx(dum)
kmax=100
dmax=10000
scal=kx/kmax * 100. + ky/kmax * 10. + sout*1000;+ kz/dmax
uq=uniq(scal(idx),sort(scal(idx)))
idxo=idx
idx=idx(uq)
nidx=n_elements(idx)
tmax=8
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
for i=0,nidx-1 do begin
    tmp=where(scal(idxo) eq scal(idx(i)))
    nf=n_elements(tmp)
    kzlist(i,0:nf-1) = kz(idxo(tmp))
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

pcor=abs(kzavlist)*del*kappa*(-1)
;if not keyword_set(dbef) then for i=0,nidx-1 do toutsum(*,*,i)*=exp(pcor)


matc=reform(toutsum(0,*,*))
;matc=matc(1:*,1:*)
mat=matc
;mat=matc2r(matc)
;mat=removecol(mat,3)
;mat=removecol(mat,1)


la_svd,mat,w,u,v,/double
print,'kxky'
print,kxlist
print,kylist
print,'kz'
print,kzlist(*,0:max(nkz)-1)
print,'mat'
print,mat
print,'w='
print,w

;mat=u ## diag_matrix(w) ## conj(transpose(v))
wi=1/w ;&  wi(2)=0.
imat=v ## diag_matrix(wi) ## conj(transpose(u))
;mat=float(mat)
;imat=float(imat)

;print, imat ## mat


svec=transpose([1,1,1,1])

harm=(mat ## svec)
;if product(th eq [0,0]) then
if keyword_set(save) then  save, harm,file='~/harm.sav',/verb
harm=(myrest2('~/harm.sav')).(0)

;if not keyword_set(dbef) then harm=harm * exp(-2*!pi*complex(0,1)*pcor)

; dharm=harm * (1-exp(-2*!pi*complex(0,1)*pcor))

print,'harm'
print, transpose(harm)
iharm=imat ## harm

del1=atan2(iharm(1)) /2/!pi / median(kzavlist) / kappa
del2=atan2(iharm(2)) /2/!pi / median(kzavlist) / kappa

delw=(del1*abs(iharm(1)) + del2 * abs(iharm(2))) / (abs(iharm(1))+abs(iharm(2)))
print,'derived del=',del
pcor2=abs(kzavlist)*delw*kappa*(1)

if not keyword_set(nocor) then harm=harm * exp(-2*!pi*complex(0,1)*pcor2)
iharm=imat ## harm



print,'iharm'
print, transpose(iharm)
print,'s2/s1 angle'
print,atan(abs(iharm(2)),abs(iharm(1)))*!radeg
print, 'phase angle s1'
print, atan2(iharm(1))*!radeg
print,'phase angle s2'
print,atan2(iharm(2))*!radeg

print,'phase angle s3'
print,atan2(iharm(3))*!radeg

print,'pcor',pcor

;print, 'from phase angle s1 derived del=', del1
;print, 'from phase angle s2 derived del=', del2
print,'true del=',del

;ns=v(3,*)
;rat=iharm(1)
;print,'null space in s vector is'
;print,transpose(ns)
;nss=u ## transpose([0,0,1])
;print,'null space in harm vector is'
;print,transpose(nss)

;print,mat


stop

;vt=conj(transpose(v))
;nss=u ## transpose([0,0,0,1])
;print, vt ## ns
;print, mat ## ns

;toutsum
;kzlist
;
;stop

;plotss,kx(idx),ky(idx),abs(toutc(idx)),psym=8

;getdxdy,kx(idx),ky(idx),dx,dy

;print,dx,dy

;stop

; sz=size(mat,/dim)
; matr=float(mat)
; mati=imaginary(mat)
; matc=fltarr(2*sz)
; matc(0:sz(0)-1,0:sz(1)-1) = matr
; matc(sz(0):2*sz(0)-1,0:sz(1)-1) = -mati

; matc(0:sz(0)-1,sz(1):2*sz(1)-1) = mati
; matc(sz(0):2*sz(0)-1,sz(1):2*sz(1)-1) = matr


; ;[[matr],[mati]]


;         imsz=[(p.roir-p.roil+1),(p.roit-p.roib+1)]/p.bin
;         print,'imsz=',imsz
;         k2=k* $; fringes/deg
;            1/!dtor* $; /rad
;            1/p.flencam* $; per mm on detector
;            6.5e-3*p.bin ; per binned pixel
end


pro gendel
lam=656.1e-9
cquartz,n_e=n_e,n_o=n_o,lambda=lam
d=8.25 * lam / (n_e-n_o) & print,'quarts thick=',d
;t1=688.91690 & t1=(689./t1) * 5. & print,'5mm thick=',t1
;t2= 377.63713 & t2=(378./t2) * 4. & print,'4mm thick=',t2

t1= 688.58950& t1=(689./t1) * 5. & print,'5mm thick=',t1
t2= 377.32361 & t2=(378./t2) * 4. & print,'4mm thick=',t2
end


;test2
;end

