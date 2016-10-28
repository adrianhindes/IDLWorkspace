function getbes,n,ch=ch
default,ch,43

;cd,'c:\Users\Admin\Desktop\pllc'
;spawn,'C:\Users\Admin\Desktop\pllc\VC_Acq_IntClk_DigRef.exe 10 none 0'
;fil='c:\Users\Admin\Desktop\pllc\clive_'+string(n,format='(I0)')+'.dat'
fil='/data/kstar/bes/'+string(n,format='(I0)')+'/Channel_'+string(ch,format='(I3.3)')+'.dat'
openr,lun,fil,/get_lun
d=uintarr(40000000)
 readu,lun,d
close,lun & free_lun,lun
return,d
; plot,d,/yno
 end

