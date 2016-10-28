function splitlast, f
spl=strsplit(f,'/')
f2=strmid(f,spl(2),999)
return,f2
end

dir1='/nas/CXRS_2014_DATA'
fil1=file_search(dir1,'*',count=cnt1)

dir2='/nas2/CXRS_2014_DATA'
fil2=file_search(dir2,'*',count=cnt2)

sz1=lon64arr(cnt1)
sz2=lon64arr(cnt2)
for i=0,cnt1-1 do sz1(i)=(file_info(fil1(i))).size
for i=0,cnt2-1 do sz2(i)=(file_info(fil2(i))).size


fil1s=strarr(cnt1)
fil2s=strarr(cnt2)

for i=0,cnt1-1 do fil1s(i)=splitlast(fil1(i))

for i=0,cnt2-1 do fil2s(i)=splitlast(fil2(i))


fil2dup=bytarr(cnt2)
szeq=bytarr(cnt2)
sza=long64(0)
szb=long64(0)
szc=long64(0)
for i=0,cnt2-1 do begin
   idx=where(fil2s(i) eq fil1s,c)
   fil2dup(i)=c
   if c gt 0 then begin
      szeq(i)=sz2(i) eq sz1(idx(0)) ;print,fil1s(i),sz1(i),sz2(idx(0))
      if szeq(i) eq 1 then sza+=sz2(i) else szb+=sz2(i)
   endif else szc+=sz2(i)
endfor


end
