pro getg, l,t,d,sh=sh
path='~cmichael/greg'
;path='~cmichael/alex'
;fil='2013 October 29 13_25_34.spe'
;fil='2013 October 29 14_37_29.spe'

;spawn,'ls -lart ~cmichael/greg'
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
end

;getg,sh=83506,l,t,d1; no puff, acq 
;getg,sh=83501,l,t,d2 ;21.3
;getg,sh=83497,l,t,d2 ; 40ms
;dd=d2-d1
getg,sh=83563,l,t,d1
imgplot,(reform(d1(*,5,*))),l,indgen(11),/cb


end
