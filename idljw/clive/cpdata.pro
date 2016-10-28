function resolp, tree, sh,base=base,dirhund=dirhund,recent=recent,filnam=filnam
default,base,'/h1data/'
filarr=['datafile','characteristics','tree']
nf=3
dirhund=string(sh/100,format='(I4.4)')
shs=string(sh,format='(I0)')
file=strarr(nf)
filnam=file
for i=0,nf-1 do begin
   if recent eq 0 then file(i) = base+'sorted'+'/'+dirhund+'/'+tree+'_'+shs+'.'+filarr(i)
   if recent eq 1 then file(i) = base+'recent'+'/'+tree+'_'+shs+'.'+filarr(i)
   if recent eq 2 then file(i) = base+'staging'+'/'+tree+'_'+shs+'.'+filarr(i)
   filnam(i)=tree+'_'+shs+'.'+filarr(i)
endfor
return,file
end
function resolall,sh,base=base,sz=sz,dirhund=dirhund,recent=recent,filnam=filnam
trees=['h1data','mirnov','electr_dens','fluctuations','oriel_260i','spectroscopy']
;trees=['h1data','electr_dens','fluctuations','oriel_260i','spectroscopy']
;trees=['mirnov']
nt=n_elements(trees)
res=strarr(nt,3)
filnam=res
for i=0,nt-1 do begin
res(i,*)=resolp(trees(i),sh,base=base,dirhund=dirhund,recent=recent,filnam=dum)
filnam(i,*)=dum
endfor
res=reform(res,n_elements(res))
filnam=reform(filnam,n_elements(res))
sz=lonarr(n_elements(res))
for i=0,n_elements(res)-1 do begin
   dum=file_info(res(i)) & sz(i)=dum.size
endfor

return,res

end

sh0=85990;83973
sh1=86119

sh0=86390
sh1=86450

sh0=40105
sh1=40105
sh0=86508
sh1=sh0


sh0=87031 & sh1=87082
;sh0=86401 & sh1=86540
sh0=87345 & sh1=87365

sh0=87700 & sh1=87803
sh0=87804 & sh1=87891


;sh0=85220
sh0=88200
sh1=88891

sh0=81746
sh1=83000

szt=0L
targpath='/dataext/h1/'

recent=0
doit=1
for i=sh0,sh1 do begin
   dum=resolall(i,sz=sz,dirhund=dirhund,recent=recent,filnam=filnam) & szt+=total(sz)
   if doit eq 1 then begin
   for j=0,n_elements(dum)-1 do begin
      file_mkdir,targpath+dirhund
      dum2=file_search(targpath+dirhund+'/'+filnam(j),count=cnt)
;      stop
      if cnt ne 0 then continue
      if sz(j) ne 0 then file_copy,dum(j),targpath+dirhund,/overwrite
      print,file_search(dum(j))
   endfor
   endif
print,i-sh0,sh1-sh0,szt/1e9
endfor



end

;87784 is good match of probes.
