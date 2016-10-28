function mystrmid, txt, start, pat
return,strlowcase(strmid(txt,start,strlen(pat))) eq strlowcase(pat)
end

nmax=50000
lins=strarr(nmax)
avail=fltarr(nmax)
avail2=fltarr(nmax)
nsh=3000
nfield=30
tab=strarr(nsh,nfield)
i=0

for c=1,1 do begin

fil='~/session_leade.txt' & outfile='~/sl.csv'
;fil='~/physics_operator.txt' & outfile='~/po.csv'

openr,lun,fil,/get_lun
while not eof(lun) do begin
   lin=''
   readf,lun,lin
   lins(i++)=lin
endwhile
close,lun & free_lun,lun
endfor



lins=lins(0:i-1)
n=i
doprint=0

dat=strarr(3,n)
j=-1
err=0
for i=0,n-1 do begin
;   catch,err
;   if err ne 0 then begin
;      print,'caught error'
;      continue
;   endif
   spl=strsplit(lins(i),/extract) & nspl=n_elements(spl)
   if n_elements(spl) ge 4 then if spl(3) eq 'Aug' or spl(3) eq 'Sep' or spl(3) eq 'Oct' or spl(3) eq 'Nov' then begin
      j++
      dat(0,j)=spl(0) ; shot#
      dat(1,j)=spl(1)
      continue
   endif else begin
      if j eq -1 then continue
      dum=strjoin(strsplit(lins(i),',',/extract))

      dat(2,j)=dat(2,j)+dum
   endelse
endfor
dat=dat(*,0:j)


writecsv2,outfile,dat
end
