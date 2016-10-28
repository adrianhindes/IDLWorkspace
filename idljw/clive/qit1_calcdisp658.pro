path='~/greg/'
;fil='2013 October 29 13_25_34.spe'
;fil='2013 October 29 14_37_29.spe'


;fils=file_search(path,'2013 October 29 14_55*.spe',count=cnt)
fils=file_search(path,'2013 November 08*.spe',count=cnt)

;2013 October 29 14_55_27.spe

print,fils
;stop

;read,'enter ifrom',ifrom
ifrom=3 ; 660
ifrom=2 ; 540

fil=fils(n_elements(fils)-1-ifrom)
print,fil


;for i=0,cnt-1 do begin

;fil='2013 August 08 13_28_41.spe'
read_spe,fil,l,t,d
;; d0=d
help,l,t,d


d=float(d)

l=reverse(l)
;l-=0.5
;cut=d(*,1,5)
cut=d(*,*,1)
cut-=min(cut)
;cut=d(*,0,5)
imgplot,cut
stop
nch=10
maxarr=fltarr(nch)
vmaxarr=maxarr
for i=0,nch-1 do begin
vmaxarr(i)=max(cut(*,i),imax)
maxarr(i)=imax
endfor
maxarr(0)=maxarr(1) - (maxarr(2)-maxarr(1))
maxarr(9)=maxarr(8) - (maxarr(7)-maxarr(8))
lshift=maxarr
for i=0,nch-1 do begin
   lshift(i)= (maxarr(i)) - (maxarr(nch/2))
endfor

plot,lshift
print,lshift,format='("lshift=[",9(G0,", "),G0,"]")'


end
