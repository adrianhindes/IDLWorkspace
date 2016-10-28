
function pseudoinvtomo, mat,w=w,u=u,v=v, maxcondition=maxcondition,debug=debug,$
	fw=wf,cond=cond, dM=dM,plotbasis=plotbasis,double=double


svdc, transpose(mat), w,u, v,double=double
nw = n_elements(w)
w1mat = fltarr(nw,nw)
tol = 1.e-6
default, maxcondition, 50.

wmax = max(w)
wminreq = wmax / maxcondition
for i=0,nw-1 do if (abs(w(i)) lt wminreq) then begin
    if (abs(w(i)) gt tol) and keyword_set(debug) then print, $
      'neglecting sv. [to prevent cond = ',wmax/w(i),']'
    w(i) = 0.
endif
wvec=fltarr(n_elements(w))
for i=0,nw-1 do if w(i) ne 0. then wvec(i)=1./w(i) else wvec(i)=0.
for i=0,nw-1 do w1mat(i,i) = wvec(i)

if keyword_set(debug) then begin
    wok = where(abs(w) ne 0.)
    print, 'condition # finally = ', max(w(wok))/min(w(wok))
    print, '# sv which are nonsmall = ',n_elements(wok)
    print, 'svs are ', w(wok)
endif
wok = where(abs(w) ne 0.)
wf = w(wok)
isort=sort(wf)
wf=wf(isort)
cond=max(wf)/min(wf)

if keyword_set(plotbasis) then begin
    wset,0
    svdc,mat,w2,u2,v2
    idx=sort(w2)
    nidx=n_elements(idx)
    idx=idx(nidx-1-findgen(nidx))
    ntake=n_elements(wf)
    for i=0,ntake-1 do begin
        !p.multi=[0,1,2]
        plot, w2(idx)
        plot, u2(idx(i),*),title=string(i,w2(idx(i))/max(w2),format='(G0," sv:",G0)')
        !p.multi=0
        cursor,dx,dy,/down
    endfor
endif




vw = v ## w1mat
nm=n_elements(w)
dM=fltarr(nm)
;for i=0,nm-1 do dM=dM + vw(i,*)^2
;dM=sqrt(dM)
mr=	v ## w1mat ## transpose(u)



return, mr

end
