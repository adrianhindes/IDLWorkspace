pro cutind, ind, ind2
;restore,file='~/hlt.sav',/verb


;nc=n_elements(coord(0,*))
;ix=fltarr(nc)
;ix(findgen(nc/3)*3)=1
ni=n_elements(ind(0,*))
if ni lt 7 then begin
    ind2=ind
    return
endif
lk=fltarr(ni)
lkip=fltarr(3,ni)
lkin=fltarr(3,ni)
ind2=ind
for i=1,ni-1 do begin
    nl=0
    for j=0,2 do begin
        for k=0,2 do if ind(j,i) eq ind(k,i-1) then begin
            nl=nl+1
            lkin(k,i-1)=1
            lkip(j,i)=1
        endif
    endfor
    lk(i)=nl
endfor

ix=where(lk eq 2) & nix=n_elements(ix)
dix=ix(1:nix-1)-ix(0:nix-2)
ix2=where(dix gt 1)
if ix2(0) ne 0 then ix2=[0,ix2]
if ix2(n_elements(ix2)-1) ne n_elements(ix)-1  then ix2=[ix2,n_elements(ix)-1]
nix2=n_elements(ix2)

ist=ix(ix2(0:nix2-2)+1)
ien=ix(ix2(1:nix2-1))
ng=n_elements(ist)
nel=fltarr(ng)
for i=0,ng-1 do begin
    nel(i)=ien(i)-ist(i)+1
    if nel(i) mod 2 eq 1 then begin
        nel(i)=nel(i)-1
        ien(i)=ist(i)+nel(i)-1
    endif
endfor

nps=20
for i=0,ng-1 do begin
    ns=nel(i)/nps
    c=ist(i)
    while c le ien(i) do begin
        ce=c+nps-1
        ce=ce<ien(i)
;        print,c,ce
        if ce+1-c le 2 then goto,skk
        ia2=ind(where(lkin(*,c+1) eq 0),c+1);where(lkip(*,c) eq 1)
        ia0=ind(where(lkin(*,c)   eq 0),c) ;where(lkin(*,c+1) eq 0)
        ib2=ind(where(lkip(*,ce-1) eq 0),ce-1)
        ib0=ind(where(lkip(*,ce) eq 0),ce)
        ind2(*,c)=[ia0,ia2,ib2]
        ind2(*,c+1)=[ib0,ib2,ia2]
        ind2(*,c+2:ce)=-1
        skk:
        c=ce+1
    endwhile
;    print,ist(i),ien(i)

endfor
ii=where(ind2(0,*) ne -1)
ind2=ind2(*,ii)        
        

end
