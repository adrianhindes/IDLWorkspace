pro combinebeams3,cd,wt=wt
default,wt,[1,1,1]
neut=cd.neutrals
tn=tag_names(neut)
ntag=n_tags(neut)
for i=0,ntag-1 do begin
    field=neut.(i)
    sz=size(field,/dim)
    nd=size(field,/n_dim)
    if nd gt 1 then begin
        dum=field
        if nd eq 4 then begin
           dum(*,*,*,0)*=wt(0)
           dum(*,*,*,1)*=wt(1)
           dum(*,*,*,2)*=wt(2)
        endif
        if nd eq 3 then begin
           dum(*,*,0)*=wt(0)
           dum(*,*,1)*=wt(1)
           dum(*,*,2)*=wt(2)
        endif
        if nd eq 2 then begin
           dum(*,0)*=wt(0)
           dum(*,1)*=wt(1)
           dum(*,2)*=wt(2)

        endif
        if nd ge 5 then stop

        
        fieldout=total(dum,nd)
    endif else begin
        fieldout=field
    endelse
    if i eq 0 then neut2=create_struct(tn(i),fieldout) else $
      neut2=create_struct(neut2,tn(i),fieldout)
endfor
cd=create_struct(delstruct(cd,'NEUTRALS'),'NEUTRALS',neut2)

    
;
;help,neut2
end
