;sh=81908;81749;857;753
sh=81750
path='~cmichael/share/greg'
;fil='2013 October 29 13_25_34.spe'
;fil='2013 October 29 14_37_29.spe'

spawn,'ls -lart ~cmichael/share/greg'
;fils=file_search(path,'2013 October 29 14_55*.spe',count=cnt)
;read,'enter shot no',sh
;sh=81712
fils=file_search(path,'shaun_'+string(sh,format='(I0)')+'.spe',count=cnt)

;2013 October 29 14_55_27.spe

;print,fils
;stop

;read,'enter ifrom',ifrom
;fil=fils(n_elements(fils)-1-ifrom)
fil=fils(0)
print,fil


;for i=0,cnt-1 do begin

;fil='2013 August 08 13_28_41.spe'
stop

read_spe,fil,l,t,d,str=str
;; d0=d
help,l,t,d


d=float(d)

;read,'enter itime',itime
;read,'enter ichan',ichan
itime=5
ichan=5
;; ff=1.1
;; l=l*ff + 656*(1-ff) - 0.6
;; da=(d(*,*,5)-d(*,*,9))/max(d(*,*,5))
;; la=l
;; plot,la,da,/ylog,yr=[1e-4,1]
;d2=[$
;[      513.294, 0.1417],$
;      [513.328 ,0.1417],$
;      [513.726 ,0.0493],$
;      [513.917 ,0.0495],$
;      [514.349 ,0.1359],$
;      [514.516 ,0.3275],$
;      [515.109 ,0.1544]]
l=reverse(l)
if n_elements(lcorr) eq 0 then lcorr=0
l=l+lcorr
;l-=0.5
;cut=d(*,1,5)
cut=d(*,ichan,itime)

itimeoff=1
cutbg=d(*,ichan,itimeoff)
cutbg2=d(*,ichan,0)
;cut=cut-cutbg
;cut-=min(cut)
;cut=d(*,0,5)
;cut=alog10(cut>1)
plot,l,cut,ysty=1,xsty=1,xr=xr,/ylog
oplot,l,cutbg,col=2
oplot,l,cutbg2,col=3

val=cut-cutbg
val=smooth(val,20)
plot,l,val
nch=10
arr=fltarr(2,nch)

for i=0,1 do begin
   cursor,dx1,dy,/down
   cursor,dx2,dy,/down
   idx=where(l ge dx1 and l le dx2)

   for j=0,nch-1 do begin
      acut=d(*,j,itime)
      acutbg=d(*,j,itimeoff)
      aval=acut-acutbg

;   inten=total(val(idx))
      inten=max(aval(idx))

      arr(i,j)=inten
   endfor
endfor


plotm,transpose(arr)
plot,arr(0,*)/arr(1,*),/noer,col=3,yr=[0,0.3]
;print,arr
;print,arr(0)/arr(1), arr(1)/arr(0)

end


