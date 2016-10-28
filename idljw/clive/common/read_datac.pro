function repslash,s1
s=s1
p=0
p=strpos(s1,'/',p)

while p ne -1 do begin
    strput,s,'B',p
    p=strpos(s1,'/',p+1)
endwhile
return,s
end

    
function read_datac, s, ch, dt=dt,npts=n,skip=skip,sm=sm,ds=ds,nocache=nocache,t0=t0


if ismsetest(s) then begin
    d=gentestshot( s, ch, dt=dt,n=n,skip=skip,sm=sm)
    return,d
endif

ch2=repslash(ch)
if not keyword_set(ds) then begin
    fl='/scratch/cmichael/dcache/'+string(s,ch2,format='(I0,"_",A)')+'.hdf'
endif else begin
    fl='/scratch/cmichael/dcache/'+string(s,ch2,n,skip,$
    format='(I0,"_",A,"_n",I0,"_sk",I0)')+'.hdf'
endelse

dum=findfile(fl,count=cnt)
if cnt ne 0 then begin
    hdfrestoreext,fl,dum
    print,'restored',fl
    d=dum.d
    dt=dum.dt
    t0=dum.t0
    if keyword_set(ds) then return,d
    goto,af
endif
str=read_data(s,ch)
d=reform(str.data)
dt=str.taxis.vector(1)-str.taxis.vector(0)
t0=str.taxis.vector(0)


if not keyword_set(nocache) then file_mkdir,'/scratch/cmichael/dcache'
if (not keyword_set(ds)) and (not keyword_set(nocache)) then $
  hdfsaveext,fl,{d:d,dt:dt,t0:t0}

print,'saved ',fl
af:



default,n,n_elements(d)
default,skip,1
ix=lindgen(n)*skip

if keyword_set(sm) and skip gt 1 then d=(smooth(d,skip))(ix) else d=d(ix)
dt=dt*skip

if keyword_set(ds) and (not keyword_set(nocache)) then hdfsaveext,fl,{d:d,dt:dt,t0:t0}


return,d
end
