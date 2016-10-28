pro program1, sh,fig=fig,factor=factor,lcorr=lcorr,xr=xr,yr=yr
path='~cmichael/greg'
;fil='2013 October 29 13_25_34.spe'
;fil='2013 October 29 14_37_29.spe'

spawn,'ls -lart ~cmichael/greg'
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
read_spe,fil,l,t,d,str=str
;; d0=d
help,l,t,d


d=float(d)

;read,'enter itime',itime
;read,'enter ichan',ichan
itime=4
ichan=4
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
cutbg=d(*,ichan,0)
cut=cut-cutbg
;cut-=min(cut)
;cut=d(*,0,5)
ifrom=0
;cut=cut/max(cut)*1000
cut=alog10(cut>1)
if keyword_set(fig) then mkfig,'~/sp_'+string(sh,format='(I0)')+'.eps',xsize=25,ysize=18
plot,l,cut,title=fil+string(ifrom,ichan,itime),ysty=1,xsty=1,xr=xr,yr=yr
;oplot,d2(0,*),d2(1,*)*!y.crange(1)/max(d2(1,*)),col=2,psym=4

restore,file='~cmichael/combined_spectra.xdr',/verb
tmp=read_ascii('~cmichael/extra_spec.txt')
tmp=tmp.(0)

spec=[[spec],[tmp]]
;stop
ion=spec(0,*)
cs=spec(1,*)
wl=spec(3,*)/10.
int=spec(2,*)*1.
idx=where(wl ge min(l) and wl le max(l) );and ion eq 8)
if idx(0) eq -1 then return
int=alog10(int)
int/=max(int(idx)) / (!y.crange(1)-!y.crange(0))
if n_elements(factor) eq 0 then factor=1.
int=int*factor
for i=0,n_elements(idx)-1 do begin
  col=3
  if cs(idx(i)) eq 1 then col=2 
  if cs(idx(i)) eq 2 then col=4 
   oplot,wl(idx(i))*[1,1],[0,int(idx(i))]+!y.crange(0),col=col
   xyouts,wl(idx(i)),int(idx(i))+!y.crange(0),string(ion(idx(i)),cs(idx(i)),format='(I0," ",I0)'),ali=0.5,col=col
endfor
oplot,wl,int,psym=4,col=2
if keyword_set(fig) then endfig,/gs,/jp
stop
end

;program1,81717
;end
