sh=9163
   openr,lun,'~/ikstar/my2/EXP00'+string(sh,format='(I0)')+'_k/bdat.txt',/get_lun
   txt=''
   while 1 do begin
      readf,lun,txt
      
      if strmid(txt,2,4) eq '----' then break
   endwhile
   cnt=0
   done=0
   arr=fltarr(30,4)
   while 1 do begin
      txt=''
      readf,lun,txt
      print,txt
      if strmid(txt,1,1) ne 'f' and done eq 0 then continue
      done=1
      spl=strsplit(txt,/extr)
      arr(cnt,0)=float(spl(1))
      arr(cnt,1)=float(spl(2))
      arr(cnt,2)=float(spl(3))
      readf,lun,txt
      spl=strsplit(txt,/extr)
      arr(cnt,3)=float(spl(0))
      cnt=cnt+1
      if cnt eq 30 then break
   endwhile
   close,lun & free_lun,lun


stop
end

