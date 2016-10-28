pro getnd, sh,nodearr,res,status=status
mdsopen,'mse_2014',sh,status=status,/quiet
;print,sh,status
status=(status eq 265388041);this is good
;print,sh,status
;return
;stop
if status eq 0 then return
n=n_elements(nodearr)
res=strarr(n)
for i=0,n-1 do begin
res(i)=string(mdsvalue(nodearr(i)))
;print,i,nodearr(i),res(i)
endfor
mdsclose
end



openr,lun,'~/idl/clive/snodes.txt',/get_lun
nmax=100
nodearr=strarr(nmax)
i=0
while not eof(lun) do begin
s=''
readf,lun,s
nodearr(i)=s
i++
endwhile
nodearr=nodearr(0:i-1)
nmax=i
close,lun & free_lun,lun


openw,lun,'~/scalars.csv',/get_lun

fmt='('+string(nmax,format='(I0)')+'(A,","),A)'
printf,lun,['shot',nodearr],format=fmt


reslast=strarr(nmax)
for sh=9862,11724 do begin
;for sh=11497,11498 do begin
getnd,sh,nodearr,res,status=status
if status eq 0 then continue
if product(res eq reslast) then continue
reslast=res
printf,lun,[string(sh,format='(I0)'),res],format=fmt
print,sh
endfor


close,lun & free_lun,lun


end

