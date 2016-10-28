function gettiming, shot,nameunit=nameunit,nounit=nounit
if nameunit eq 'greg' then nounit=15

mdsopen,'h1data',shot

nd='.log.machine:timing'
txt=mdsvalue(nd)
lins=strsplit(txt,string(byte(10)),/extract)
nl=n_elements(lins)
numarr=fltarr(nl)
for i=0,nl-1 do begin
spl=strsplit(lins(i),';',/extract)
numarr(i)=long(spl(0))
endfor
i=value_locate3(numarr,nounit)
;print,lins(i)
spl=strsplit(lins(i),';',/extract)
nspl=n_elements(spl)
 pos=stregex(spl(1),'[^0-9]') & t0=float(strmid(spl(1),0,pos))
stat=strmid(spl(1),strlen(spl(1))-1,1)
tout=fltarr(nspl-1)
hi=fltarr(nspl-1)
tout(0)=t0
hi(0)=stat eq 'h'
for i=2,nspl-1 do begin
   pos1=stregex(spl(i),'[0-9]')
   pos2=pos1+stregex(strmid(spl(i),pos1,999),'[^0-9]')
   num=float(strmid(spl(i),pos1,pos2-pos1))
   stat=strmid(spl(i),strlen(spl(i))-1,1)
   tout(i-1) = tout(i-2) + num
   hi(i-1) = stat eq 'h'


   
endfor
idx=where(hi eq 1)
tout=tout(idx)

return,tout


end

;d=gettiming(88533,nameunit='greg')

;end
