pro scdump,fil=fil,norev=norev,png=png
if keyword_set(png) then suff='.png' else suff='.jpg'
default,fil,'~/scdump'+suff


im=tvrd(true=3)
if not keyword_set(norev) then begin
    nn=n_elements(im)
    im0=im(*,*,0)
    im1=im(*,*,1)
    im2=im(*,*,2)
    imc = long(im0)+long(im1)+long(im2)
    sm0=im0
    sm1=im1
    sm2=im2

    idx=where( imc eq 0)
    if idx(0) ne -1 then begin
        im0(idx)=248
        im1(idx)=252
        im2(idx)=248
        print,'reversed ',float(n_elements(idx))/float(n_elements(im(*,*,0)))
    endif

    idx=where( (sm0 eq 248) and (sm1 eq 252) and (sm2 eq 248) eq 1)
    if idx(0) ne -1 then begin
        im0(idx)=0
        im1(idx)=0
        im2(idx)=0
        print,'reversed ',float(n_elements(idx))/float(n_elements(im(*,*,0)))
    endif

;    stop
    sz=size(im0,/dim)
    im(*,*,0)=im0
    im(*,*,1)=im1
    im(*,*,2)=im2
;    im=reform([[im0],[im1,im2],3,sz(0),sz(1))
;    im=transpose(im,[1,2,0])
;    stop
;'    idx=where( tvrd() eq 248)
;'    nn=n_elements(im)
;'    if idx(0) ne -1 then begin
;'        im(idx*3)=0
;'        im(idx*3+1)=0
;'        im(idx*3+2)=0
;'        print,'reversed ',float(n_elements(idx))/float(n_elements(im(*,*,0)))
;    endif

    
endif
;stop
tv,im,true=3
if keyword_set(png) then write_png,fil,transpose(im,[2,0,1])  else $
  write_jpeg,fil,im,true=3

;stop
end
