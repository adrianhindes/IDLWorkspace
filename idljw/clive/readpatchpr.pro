function fixstr, str
return,strjoin(strsplit(str,'/. ',/extract))
end


pro readpatchpr,sh,str,data=data0,file=file,fillnull=fillnull,dowrite=dowrite
default,file,'log_probe.csv'
;path='/projects/diagnostics/MAST/FIDA/fidaidl/settings/'

path=getenv('HOME')+'/idl/clive/settings/'

if n_elements(data0) eq 0 then readtextc,path+file,data0,nskip=0
data=data0
head=data[*,0]
data=data[*,1:*]

if keyword_set(fillnull) then begin

nf=n_elements(data(*,0))
nsh=n_elements(data(0,*))
for i=0,nsh-1 do begin
  for j=0,nf-1 do $
    if (strlen(data[j,i]) eq 0) && (i gt 0) then data[j,i] = data[j,i-1]
  ; increment record counter
endfor

endif

if keyword_set(dowrite) then begin
   datah=[[head],[data]]
   writecsv2, dowrite, datah
   stop
endif

isstr=size(sh,/type) eq 7
if isstr then begin

endif

shl = longtrap(data[0,*],err=err)

;stop
if isstr eq 0 then begin
    wg=where(err eq 0) & shl=shl(wg) & data=data(*,wg)
    idx=where(shl eq sh,count)
    if count eq 0 then idx = where( (shl le sh),count)
;    stop
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

iidx=where(head ne '')
head=head(iidx)

nh=n_elements(head)
head2=head & for i=0,nh-1 do head2(i)=strlowcase(fixstr(head(i)))
uq=uniq(head2,sort(head2))
nuq=n_elements(uq)
for i=0,nuq-1 do begin
   ii=where(head2(uq(i)) eq head2)
   if n_elements(ii) gt 1 then begin
      nii=n_elements(ii)
      base=head2(uq(i))
      for j=0,nii-1 do begin
         head2(ii(j))=base+string(j+1,format='(I0)')
      endfor
   endif
endfor



for i=0,nh-1 do begin
   if head2(i) eq '' then continue
   dval=(floattrap(data(i,idx),err=err))(0) & if err eq 1 then dval=data(i,idx)
   if i eq 0 then str=create_struct(head2(i),dval) else $
      str=create_struct(str,head2(i),dval)
endfor




   
end

;readpatchpr,81857,str

;end
