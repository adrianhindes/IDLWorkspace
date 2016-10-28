
pro readflc0,sh,flc0t0,flc0per,flc0mark,flc0invert,flc0endt,flc0endstate,db=db
;path='/projects/diagnostics/MAST/FIDA/fidaidl/settings/'
default,db,'k'


path=getenv('HOME')+'/idl/clive/settings/'
readtextc,path+'log_flctiming.csv',data,nskip=1

isstr=size(sh,/type) eq 7
if isstr then begin

endif

db1=data[1,*]
idx=where(db1 eq db)
data=data[*,idx] ;; select only certain databse entries


shl = longtrap(data[0,*],err=err)


if isstr eq 0 then begin
    wg=where(err eq 0) & shl=shl(wg) & data=data(*,wg)
    idx = where( (shl le sh),count)
    if count eq 0 then begin
        print,'error'
        return
    endif
endif else begin
    wg=where(err eq 1) & shl=data(0,wg) & data=data(*,wg)
    nn=n_elements(shl)
    tvar=intarr(nn)
    for i=0,nn-1 do tvar(i)=strpos(sh,shl(i))
    idx = where(tvar ne -1)
    if n_elements(idx) gt 1 then begin
        print,'error more than one match'
        stop
    endif
    if idx(0) eq -1 then begin
        print,'error2'
        stop
    endif
endelse



; the relevant record is the one with the highest shotnumber that is lower than or equal to the desired shotnumber.
idx = idx(n_elements(idx)-1)	; row number

i=2
flc0t0=fix(data(i++,idx))
flc0per=fix(data(i++,idx))
flc0mark=fix(data(i++,idx))
flc0invert=fix(data(i++,idx))
flc0endt=fix(data(i++,idx))
flc0endstate=fix(data(i++,idx))


end

