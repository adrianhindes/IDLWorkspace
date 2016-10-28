
nmax=50000
lins=strarr(nmax)
avail=fltarr(nmax)
nsh=1000
nfield=30
tab=strarr(nsh,nfield)
i=0

;for c=1,14 do begin
;fil='~/log/log'+string(c,format='(I0)')+'.txt'

for c=1,1 do begin
fil='~/log/lognbi.txt'

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
tab(0,2)='FAULT'
tab(0,4)='ENERGY A'
tab(0,5)='ENERGY B'
tab(0,6)='POWER A'
tab(0,7)='POWER B'
tab(0,8)='ONTIME A'
tab(0,9)='ONTIME B'
tab(0,10)='WIDTH A'
tab(0,11)='WIDTH B'
tab(0,12)='MOD TIME DEL A'
tab(0,13)='MOD TIME DEL B'
tab(0,14)='MOD PULS WID A'
tab(0,15)='MOD PULS WID B'
tab(0,16)='MOD FREQ A'
tab(0,17)='MOD FREQ B'
tab(0,18)='MOD DUTY CYCLE A'
tab(0,19)='MOD DUTY CYCLE B'

j=1
err=0
for i=0,n-1 do begin
   catch,err
   if err ne 0 then continue
   spl=strsplit(lins(i),/extract) & nspl=n_elements(spl)
   if n_elements(spl) ge 4 then if spl(3) eq 'Aug' then begin
;   if n_elements(spl) ge 4 then if spl(3) eq 'Oct' or spl(3) eq 'Nov' then begin
      print,lins(i)
      if spl(2) eq 'NBI' then begin
         j=j+1
         tab(j,0)=spl(0)
         tmp=file_search('/data/kstar/disk1/MSE_2013_data/MSE_2013_'+spl(0)+'_Record.TDMS',count=cnt)
         if cnt eq 0 then begin
         tmp=file_search('/data/kstar/MSE_2013_DATA_LASTDAY/MSE_2013_'+spl(0)+'_Record.TDMS',count=cnt)
      endif
         avail(j,0)=cnt

         doprint=1
         k=1
      endif else doprint=0
      continue
   endif
   if doprint eq 1 then begin
      print, lins(i)
      if k lt 32767 then begin
         if k eq 1 then begin
            if spl(0) eq 'KSTAR' and spl(1) eq 'EMG.' then begin
               tab(j,2)=spl(5)
               k=k+1
               continue
            endif  else begin
               tab(j,2)=''
               k=k+1
            endelse
         endif

         k=9999
         if n_elements(spl) lt 3 then continue
         if spl(2) eq 'energy(A/B):' then k=2
         if spl(2) eq 'power(A/B):' then k=3
         if spl(2) eq 'on' then begin
            k=4
            spl=[spl(0:2),spl(4:*)]
         endif
         if spl(2) eq 'width(A/B):' then k=5
         if spl(1) eq 'Modulation(A/B):' then k=6

         if k le 5 then begin
            tab(j,2*k)=spl(3)
            tab(j,2*k+1)=spl(5)
         endif
         if k eq 6 then begin
            if spl(2) eq 'No' then continue
            sspl=strsplit(lins(i),':,',/extract)
            for f=0,3 do begin
               ssspl=strsplit(sspl(1+f),'()/ ',/extract)

               tab(j,2*(k+f))=ssspl(1)
               tab(j,2*(k+f)+1)=ssspl(2)
            endfor
         endif
      endif 
   endif
endfor

ntab=j+1
tab=tab(0:ntab-1,*)
avail=avail(0:ntab-1)
ftab=float(tab)

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

writecsv2,'~/log/ann.csv',transpose(tab)

end
