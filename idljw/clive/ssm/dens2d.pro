sh=83993;82823

ch=indgen(20)

nch=n_elements(ch)

for i=0,nch-1 do begin
   demodsw,sh,i,pdum,t,amp=adum
   if i eq 0 then begin
      p=fltarr(n_elements(pdum),nch) & a=p
   endif
   p(*,i) = pdum
   a(*,i) = adum
endfor
nt=n_elements(t)

it=value_locate(t,0.01)
idx=where(a(it,*) ge max(a(it,*)) * 0.1)

ch2=ch(idx)
p2=p(*,idx)
plot,ch2,p2(it,*),psym=-4


ee:

end
