path='~/greg2/'
;path='~/haitao/'
;fil='2013 October 29 13_25_34.spe'
;fil='2013 October 29 14_37_29.spe'


;fils=file_search(path,'2013 October 29 14_55*.spe',count=cnt)
;fils=file_search(path,'2013 November 08*.spe',count=cnt)
  fils=file_search(path,'2013 July 17 1*.spe',count=cnt)
;  fils=file_search(path,'EBeams_18_12_2013*.spe',count=cnt)
;  fils=file_search(path,'seq??.SPE',count=cnt)
;  fils=file_search(path,'ebeam*.SPE',count=cnt)

;2013 October 29 14_55_27.spe

for i=0,n_elements(fils)-1 do begin
print,i,fils(i)
endfor
;print,fils
;stop

read,'enter ifrom',ifrom
;fil=fils(n_elements(fils)-1-ifrom)
fil=fils(ifrom)
print,fil


;for i=0,cnt-1 do begin

;fil='2013 August 08 13_28_41.spe'
read_spe,fil,l,t,d,str=str
;; d0=d
help,l,t,d


d=float(d)
imgplot,d,title=fil
stop

read,'enter itime',itime
read,'enter ichan',ichan

;; ff=1.1
;; l=l*ff + 656*(1-ff) - 0.6
;; da=(d(*,*,5)-d(*,*,9))/max(d(*,*,5))
;; la=l
;; plot,la,da,/ylog,yr=[1e-4,1]
d2=[$
[      513.294, 0.1417],$
      [513.328 ,0.1417],$
      [513.726 ,0.0493],$
      [513.917 ,0.0495],$
      [514.349 ,0.1359],$
      [514.516 ,0.3275],$
      [515.109 ,0.1544]]
l=reverse(l)
;l-=0.5
;cut=d(*,1,5)
cut=d(*,ichan,itime)
cut-=min(cut)
;cut=d(*,0,5)
plot,l,cut,title=fil+string(ifrom,ichan,itime),ysty=1
oplot,d2(0,*),d2(1,*)*!y.crange(1)/max(d2(1,*)),col=2,psym=4
end
