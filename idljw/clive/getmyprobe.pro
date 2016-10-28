function getmyprobe,n
;cd,'c:\Users\Admin\Desktop\pllc'
;spawn,'C:\Users\Admin\Desktop\pllc\VC_Acq_IntClk_DigRef.exe 10 none 0'
;fil='c:\Users\Admin\Desktop\pllc\clive_'+string(n,format='(I0)')+'.dat'
fil='/nas/pllc/clive_'+string(n,format='(I0)')+'.dat'
openr,lun,fil,/get_lun
d=dblarr(5000000)
 readu,lun,d
close,lun & free_lun,lun
return,d
; plot,d,/yno
 end

