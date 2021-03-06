pro getphasejohn,sh,t,av,i0=i0,geti0=geti0,pd=pd

fil='/home/cmichael/mm'+string(sh,format='(I0)')+'.sav'
dum=file_search(fil,count=cnt)
if cnt ne 0 then begin
   restore,file=fil
   return
endif

mdsopen,'mse_2014_prc',sh
y=mdsvalue('.demod:phase')
t=1e-6 * long64(mdsvalue('dim_of(.demod:phase,0)'))
sz=size(y,/dim)

v=reform(y(sz(0)/2,sz(1)/2,*))
n=n_elements(t)
v1=v(1:n-1)
v0=v(0:n-2)
av=0.5*(v0+v1)*!radeg
;plot,t,av
pd=(v1-v0)*!radeg*0.25
w=findgen(n) mod 2
sg = w*2 -1 
pd = pd * sg

if keyword_set(geti0) then begin
   y2=mdsvalue('.demod:i0')
   i0=reform(y2(sz(0)/2,sz(1)/2,*))
endif
save,t,av,i0,pd,file=fil

end






;dum= read_segmented_images( 'mse_2014_prc',sh, '.demod:phase', 0);, long=long, $
;    all=all, bin=bin, transpose = transpose, status=status
;end
