pro getg, l,t,d
path='~cmichael/greg'
;fil='2013 October 29 13_25_34.spe'
;fil='2013 October 29 14_37_29.spe'

spawn,'ls -lart ~cmichael/greg'
;fils=file_search(path,'2013 October 29 14_55*.spe',count=cnt)
read,'enter shot no',sh
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
