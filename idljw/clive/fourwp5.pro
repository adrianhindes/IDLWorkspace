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

function array_index, arr, dim, i
sz=size(arr,/dim)
nsz=size(arr,/n_dim)
if nsz eq 1 then return, arr(i)
if nsz eq 2 and dim eq 0 then return, arr(i,*)
if nsz eq 2 and dim eq 1 then return, arr(*,i)
if nsz eq 3 and dim eq 0 then return, arr(i,*,*)
if nsz eq 3 and dim eq 1 then return, arr(*,i,*)
if nsz eq 3 and dim eq 2 then return, arr(*,*,i)
end

pro array_index_put, arr, dim, i, val
sz=size(arr,/dim)
nsz=size(arr,/n_dim)
if nsz eq 1 then arr(i)=val
if nsz eq 2 and dim eq 0 then arr(i,*)=val
if nsz eq 2 and dim eq 1 then arr(*,i)=val
if nsz eq 3 and dim eq 0 then arr(i,*,*)=val
if nsz eq 3 and dim eq 1 then arr(*,i,*)=val
if nsz eq 3 and dim eq 2 then arr(*,*,i)=val
end


function touter,tens1,tens2,idim=idim
default,idim,2
sz1=size(tens1,/dim) 
sz2=size(tens2,/dim) 

n1=sz1(idim)
n2=sz2(idim)
n=n1*n2
szout=sz1 & szout(idim)=n
tout=complexarr(szout)
for i=0,n1-1 do for j=0,n2-1 do $
    array_index_put,tout,idim,n2*i + j, $
      array_index(tens1,idim,i) * $
      array_index(tens2,idim,j) 
return,tout
end


function mytr, a, tr=tr
if keyword_set(tr) then return,transpose(a) else return,a
end


function tinner,tens1,tens2,idim1=idim1,idim2=idim2,tr1=tr1,tr2=tr2
sz1=size(tens1,/dim) 
sz2=size(tens2,/dim) 

if n_elements(idim1) ne 0 then begin
    n=sz1(idim1)
    for i=0,n-1 do begin
        tmp1=mytr(array_index(tens1,idim1,i),tr=tr1)
        tmp2=mytr(tens2,tr=tr2)
        tmp=tmp1 ## tmp2
        if i eq 0 then begin
            dim=size(tmp,/dim)
            dim=[dim,n] & idim=n_elements(dim)-1
            tout=complexarr(dim)
        endif
        array_index_put, tout, idim, i, tmp
;        stop
    endfor
endif

if n_elements(idim2) ne 0 then begin
    n=sz2(idim2)
    for i=0,n-1 do begin
        tmp1=mytr(tens1,tr=tr1)
        tmp2=mytr(array_index(tens2,idim2,i),tr=tr2)
        tmp=tmp1 ## tmp2
        if i eq 0 then begin
            dim=size(tmp,/dim)
            dim=[dim,n] & idim=n_elements(dim)-1
            tout=complexarr(dim)
        endif
        array_index_put, tout, idim, i, tmp
    endfor
endif
return,tout
end

function kouter,kay1,kay2
sz1=size(kay1,/dim) ; k1 3zxn
sz2=size(kay2,/dim) ; k2 must be 3zx3

szout=[sz1(0),sz1(1)*sz2(1)]
kout=complexarr(szout)
for i=0,sz1(0)-1 do for k1=0,sz1(1)-1 do for k2=0,sz2(1)-1 do begin
;    kout(i,k1*sz2(1)+k2)=kay1(i,k1)+kay2(i,k2)
    kout(i,k1+k2*sz1(1))=kay1(i,k1)+kay2(i,k2)
endfor

return,kout
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

sp0=transpose([1.,0,1,0])
tens0=fourwp(!pi/4,0.25,0.,kvecxy=kvec0)
tens1=fourwp(0,1000.,1,kvecxy=kvec1)
tens2=fourwp(!pi/4,707,0.707,kvecxy=kvec2)
tens3=fourwp(-!pi/4,707,0.707,kvecxy=kvec3)
mp=matpol(0)

tout=touter(tens3,touter(tens2,touter(tens1,tens0)))
tout=tinner(mp,tout,idim2=2)
tout=tinner(tout,sp0,idim1=2,/tr1)
tout=tout(0,0,*)
kout=kouter(kouter(kouter(kvec0,kvec1),kvec2),kvec3)
idx=(where(abs(tout) ge 1e-5))
plot,kout(0,idx),kout(1,idx),psym=4

end
