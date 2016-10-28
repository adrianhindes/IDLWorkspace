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

;for c=1,14 do begin
;fil='~/log/log'+string(c,format='(I0)')+'.txt'

for c=1,1 do begin
;fil='~/log/lognbi.txt'
fil='~/ktxt2014/nbin.txt'

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
tab(0,0)='#'
tab(0,1)='AVAIL'
tab(0,2)='KAVAIL'
tab(0,3)='FAULT'
tab(0,6)='ENERGY A'
tab(0,7)='ENERGY B'
tab(0,8)='ENERGY C'
tab(0,9)='POWER A'
tab(0,10)='POWER B'
tab(0,11)='POWER C'
tab(0,12)='ONTIME A'
tab(0,13)='ONTIME B'
tab(0,14)='ONTIME C'
tab(0,15)='WIDTH A'
tab(0,16)='WIDTH B'
tab(0,17)='WIDTH C'
tab(0,18)='MOD TIME DEL A'
tab(0,19)='MOD TIME DEL B'
tab(0,20)='MOD TIME DEL C'
tab(0,21)='MOD PULS WID A'
tab(0,22)='MOD PULS WID B'
tab(0,23)='MOD PULS WID C'
tab(0,24)='MOD FREQ A'
tab(0,25)='MOD FREQ B'
tab(0,26)='MOD FREQ C'
tab(0,27)='MOD DUTY CYCLE A'
tab(0,28)='MOD DUTY CYCLE B'
tab(0,29)='MOD DUTY CYCLE C'

j=1
err=0
for i=0,n-1 do begin
   catch,err
   if err ne 0 then begin
      print,'caught error'
      continue
   endif
   spl=strsplit(lins(i),/extract) & nspl=n_elements(spl)
   if n_elements(spl) ge 4 then if spl(3) eq 'Sep' or spl(3) eq 'Oct' then begin
;   if n_elements(spl) ge 4 then if spl(3) eq 'Oct' or spl(3) eq 'Nov' then begin
      print,lins(i)
      if spl(2) eq 'NBI' then begin
         j=j+1
         tab(j,0)=spl(0)
         nbm=0

         tmp=file_search('/home/cam112/share/nas/MSE_2014_DATA/mse_2014_'+spl(0)+'.datafile',count=cnt)
         avail(j)=cnt
         tab(j,1)=cnt
         tmp=file_search('/home/cam112/share/nas/KSTAR_DATA/KSTAR_'+spl(0)+'.datafile',count=cnt)
         tab(j,2)=cnt
         doprint=1
         k=1
      endif else begin
         doprint=0
      endelse

      continue
   endif


   if doprint eq 1 then begin
      print, lins(i)


      if k eq 1 then begin
         spl=strsplit(lins(i),' ',/extr)
         if spl(1) eq 'shot' then begin
            whichbm=spl(2)
            bms=strsplit(whichbm,'()/',/extract)
            nbm=n_elements(bms)
            ibms=fix(byte(bms)-(byte('A'))(0))
            k=9999
;            stop
            continue
         endif
         if spl(1) eq 'EMG.' then begin
            whichbm=strmid(lins(i),strpos(lins(i),'('),9999)
            bms=strsplit(whichbm,'()/',/extract)
            nbm1=n_elements(bms)
            ibms1=fix(byte(bms)-(byte('A'))(0))
            if nbm eq 0 then ibms=ibms1 else ibms=[ibms,ibms1]
            nbm=nbm+nbm1
            continue
         endif

         if nbm eq 0 then begin
            doprint=0
            continue
         endif
         
      endif

      if mystrmid(lins(i),2,'beam energy') then k=2
      if mystrmid(lins(i),2,'beam power') then k=3
      if mystrmid(lins(i),2,'beam on time') then k=4
      if mystrmid(lins(i),2,'pulse width') then k=5
;         if mystrmid(lins(i),2,'modulation') then k=5

;            if tab(j,0) eq '10054' then stop
      if k le 5 then begin
         spl=strsplit(lins(i),':',/extract)
         spl2=strsplit(spl(1),'/ ',/extract)
         tab(j,3*k + ibms) = spl2(0:nbm-1)
         
;            stop
      endif
   endif
endfor

;stop
ntab=j+1
tab=tab(0:ntab-1,*)
avail=avail(0:ntab-1)
;ftab=float(tab)
writecsv2,'~/ktxt2014/an4.csv',transpose(tab)

stop

sh=ftab(*,0)
ontime1=ftab(*,8)
wid1=ftab(*,10)
offtime1=ontime1+wid1
ontime2=ftab(*,9)
wid2=ftab(*,11)
offtime2=ontime2+wid2
del=1e-6
modon1=(ftab(*,8)+ftab(*,12)) mod (1/ftab(*,16)-del)
modon2=(ftab(*,9)+ftab(*,13)) mod (1/ftab(*,17)-del)

modoff1=1/ftab(*,16) * (100.-ftab(*,18))/100.
modoff2=1/ftab(*,17) * (100.-ftab(*,19))/100.


cond=offtime1 le ontime2 and offtime1 ne 0 and wid1 gt 0.5 and wid2 gt 0.5 and avail eq 1
idx=where(cond)
print,' beam switch shots'
print,fix(sh(idx))

cond=ftab(*,4) ne 0 and ftab(*,5) eq 0 and avail eq 1
;cond=ftab(*,5) ne 0 and ftab(*,4) eq 0
idx=where(cond)
print,' beam 1only shots'
print,fix(sh(idx))

cond=ftab(*,5) ne 0 and ftab(*,4) eq 0 and avail eq 1
idx=where(cond)
print,' beam 2only shots'
print,fix(sh(idx))



;retall
;print, transpose([[sh],[ftab(*,16)],[modon1],[modon2],[modon2-modon1],[modoff1],[modoff2]])


cond=finite(modoff1) and finite(modoff2) and modon2 lt modon1 and avail eq 1
idx=where(cond)
print,'modulation shots'
print,fix(sh(idx))


print, transpose([[sh(idx)],[ftab(idx,16)],[modon1(idx)],[modon2(idx)],[modon2(idx)-modon1(idx)],[modoff1(idx)],[modoff2(idx)]])


end
