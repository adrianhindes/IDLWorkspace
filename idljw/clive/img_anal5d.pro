@simimg2






pro circtest
;rarr=[23,24,26,27,29,30,32,31];16];3,5,6,10,11,12]
;rarr=[26,29,32]
;rarr=[33,34]
;rarr=[35,39,38] ; no window, contiguous
;rarr=[36,40,37] ; window,contiguous
;rarr=[45,46,47];win img
;rarr=[44,43,42] ;nowin img
;rarr=[44,45]; nowin/win

;rarr=[49,48]; nowin/win

;rarr=[54,55]
rarr=[50,51,52,53,54]
iarr=replicate(0,n_elements(rarr))
sm=2;4
presm=1
aoffs=0.

; new ones
;rarr=replicate(60,10)&iarr=intspace(0,9)
;rarr=[64,65]&iarr=[0,0]
;rarr=[64,replicate(66,9)]&iarr=[0,intspace(0,8)]
;rarr=[67,replicate(68,15)]&iarr=[0,intspace(0,14)]&i0=0
;rarr=replicate(74,38)&iarr=intspace(0,37)


rarr=replicate(74,19)&iarr=2*intspace(0,18) & i0=0


;rarr=[72] & iarr=[0]
sm=1&presm=2&aoffs=-30+90
renorm=1

sim=0
;sim=1&rarr=replicate(74,17)&iarr=intspace(0,16)

angarr=linspace(0,2*!pi,n_elements(iarr))
    

nrun=n_elements(iarr)


;d;at=fltarr(nx,nrun)
;for i=0,nrun-1 do begin
;    dat(*,i)

s3arr=fltarr(nrun)
s3arr2=fltarr(nrun)
common cbss,sz,pcent,s3store
;goto,aa
pcent=fltarr(nrun)
poslin,nrun,nx,ny
erase & pos=posarr(nx,ny,0,msratx=5)
for i=0,nrun-1 do begin

    if sim eq 1 then $
      img=simimg2(angarr(i),sm=presm) $
    else $
      img=getimg(rarr(i),sm=sm,index=iarr(i))


;    imgplot,img,/cb
;    wait,1
;    continue

    demodc, img,c1,c2a,c2b,s3,idxng=idx,thres=0.01,pixfringe=20/presm/sm,aoffs=aoffs,wintype='sg',/dopl


;    stop
;,sub=[512,384]
    sz=size(c1,/dim)



    ;,c1r,c2ar,c2br,p2a,p2b
    if i eq 0 then begin
        c1r=c1
        c2ar=c2a
        c2br=c2b


        s3store=fltarr(sz(0),sz(1),nrun)
        p2bstore=s3store
        p2astore=s3store

    endif
;    if i eq 1 then begin
;        c2ar=c2a
;        c2br=c2b
;    endif
    c2ac = c2a/c2ar
    c2bc = c2b/c2br
    p2a=atan2(c2ac)
    p2b=atan2(c2bc)
    p2a(idx)=!values.f_nan
    p2b(idx)=!values.f_nan
    pcent(i)=p2b(sz(0)/2,sz(1)/2)


    c1c=c1/c1r
    sc1c = float(c1c)/abs(float(c1c))

    if renorm eq 1 then begin
        s3=sin(atan(abs(c1) * sc1c,2*abs(c2a)))
        s3(idx)=!values.f_nan
    endif

    s3store(*,*,i)=s3
    p2astore(*,*,i)=p2a
    p2bstore(*,*,i)=p2b


    s3arr(i)=s3(sz(0)/2,sz(1)/2)
    s3arr2(i)=s3(sz(0)/2*0.8,sz(1)/2*0.8)
;    stop&!p.multi=0
    
    imgplot,s3,/cb,title=string(rarr(i),iarr(i),format='(I0,"_",I0)'),zr=[-0.2,0.2],pal=-2,/noer,xsty=5,ysty=5,pos=pos & pos=posarr(/next)

;    imgplot,p2a,/cb,title=string(rarr(i),iarr(i),format='(I0,"_",I0)');,zr=[-!pi,!pi],pal=-2

;    stop
endfor
!p.multi=0
;stop
aa:
ca=[0.1,0.5]
ia=intspace(1,9)*0.1
ib=ia
na=n_elements(ia)
ia2=ia # replicate(1,na)
ib2=replicate(1,na) # ib
iaf=reform(ia2,n_elements(ia2))
ibf=reform(ib2,n_elements(ia2))
s3a=fltarr(na^2,nrun)
for i=0,nrun-1 do s3a(i,*)=s3store(iaf(i)*sz(0),ibf(i)*sz(1),*)

xx=phs_jump(pcent)/2 /2/!pi ; 2*!pi-
xxb=phs_jump(pcent)/2
plotm,xx,transpose(s3a),psym=-4
;plot,-phs_jump(pcent)/2/!pi,s3store(sz(0)*ca(0),sz(1)*ca(1),*),psym=-4,xticklen=1

s1 = cos(2*(xxb(i0:*)-!pi/4))
s2 = sin(2*(xxb(i0:*)-!pi/4))

s3fit=reform(s3store(0.5*sz(0),0.5*sz(1),i0:*))
rc=regress(transpose([[s1],[s2]]),s3fit,yfit=s3fit2)
plot,s3fit,s3fit2
oplot,s3fit,s3fit,col=2
;2 (-2 db s1 - da s2 + s3/2)

;plot,deriv(phs_jump(pcent))     
stop
;plot,s3arr
;oplot,s3arr2,col=2
;stop
end
circtest
;linpolscan

end
