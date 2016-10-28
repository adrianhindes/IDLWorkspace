@ds_profile
fil='/home/cmichael/fromboyd/heliac/cfg/output'
fil='/home/cmichael/fromboyd/heliac/cfg_highovf/output'

;fil='/home/cmichael/fromboyd/heliac/cfg/gHg110324-kh0.720-kv1.000.hin.out'

openr,lun,fil,/get_lun

while not eof(lun) do begin
lins=''
readf,lun,lins
if lins eq '0OUTPUT SUMMARY:' then break
endwhile
linshead=''
readf,lun,linshead;head
readf,lun,lins;unit
readf,lun,lins;unit
readf,lun,lins;unit
readf,lun,lins;unit

;fmt='(I3,F6.1,F7.3,F7.3,F7.3,F7.3,F7.3,F7.1,F7.2,F7.2,F6.2)'
fmt='(A3,A6  ,A7  ,A7  ,A7  ,A7  ,A7  ,A7  ,A7  ,A7  ,A7  ,A6  ,A7  ,A7  ,A8  ,A7  ,A6  ,A7  ,A8  )'
np=20
d=fltarr(np,50)
d1=strarr(np)
for i=0,49 do begin
;catch,err
;if err ne 0 then goto,nono
readf,lun,d1,format=fmt ; lins ; line 
print,i
;STOP
d(*,i)=float(d1)
endfor
nono:
catch,/cancel

idx=findgen(32)
idx=sort(d(0,idx))
rmid=d(2,idx)
ra=d(3,idx)

well=d(10,idx)
iota=-d(14,idx)
;xr=[1.29,1.36]
;rmid(32)=0.5*(rmid(31)+rmid(33))

;mkfig,'~/heloutprofs.eps',xsize=10,ysize=8,font_size=9
!p.thick=3
plot,rmid,well,xr=xr,xsty=1,pos=posarr(1,2,0,cnx=.1,cny=.1,msraty=8),/ynozero,title='Well (%)',xtickname=replicate(' ',10)
plot,rmid,iota,xr=xr,xsty=1,pos=posarr(/next),/ynozero,/noer,title='iota',xtitle='R (m)'
endfig,/gs,/jp


;tw=[.08,.09]
;tw=[.02,.03]
;ds_profile,'3rd',tw,rad,prof
;ds_profile,'1st',tw,rad3,prof3
;plot,rad/1000. + (1112-45)/1000.,prof,psym=4,xr=xr,pos=posarr(/next),/noer,xsty;=1
;oplot,(rad3+45)/1000. + (1112-45)/1000.,prof3*4,col=2,psym=4


writecsv,transpose(rmid),transpose(well),file='~/highovf.csv'

end



;;   420 FORMAT(I3,3PF6.1,0PF7.3,F7.3,F7.3,F7.3,F7.3,F7.1,F7.2,F7.2,F6.2,  61770000
;;      &F6.2,F7.2,F7.3,F7.4,F7.2,F6.2,F7.2,F8.2)                          61780000


;;   410 FORMAT('0 #','  FLUX','    R  ','    RA ','   RA/ ',              61620000
;;      &'  AREAI','  AREAO','   BRIP','   INT.','  DLRIP','  WELL',       61630000
;;      &'   C- ','   S-GR','   IOTA','   IOTA','  SHEAR','  1/RS',        61640000
;;      &'  B-PHI','   B-EQ.')                                             61650000
;;       WRITE (LUNIT,415)                                                 61660038
;;   415 FORMAT('   ',' (mWB)','   (M) ','   (M) ','   RAD ',              61670000
;;      &'   (M2)','   (M2)','    (%)','   DL/B','   (%) ','   (%)',       61680000
;;      &'  WELL','   (%) ','   /2PI','  /2NPI','       ',' (1/M)',        61690000
;;      &'   (%) ','    (%) ')                                             61700000
;;       IF (IMAG.NE.0)                                                    61710000
;;      &WRITE (LUNIT,420) 0,0.0,RAX,0.0,0.0,0.0,0.0,RIPPLE*100.0,DAV,0.D  61720038
;;      &0,0.0                                                             61730000
;; C BDB CHANGED FLUX TO 1000X (3P) AND IOTABAR FORMATS                    61740000
;; C 420 FORMAT(I3,F6.2,F7.3,F7.3,F7.3,F7.3,F7.3,F7.1,F7.2,F7.2,F6.2,      61750000
;; C    *F6.2,F7.2,F7.2,F7.2,F7.2,F6.2,F7.2,F8.2)                          61760000
;;   420 FORMAT(I3,3PF6.1,0PF7.3,F7.3,F7.3,F7.3,F7.3,F7.1,F7.2,F7.2,F6.2,  61770000
;;      &F6.2,F7.2,F7.3,F7.4,F7.2,F6.2,F7.2,F8.2)                          61780000
