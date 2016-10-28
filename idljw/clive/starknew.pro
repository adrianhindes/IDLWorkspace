pro getzeta, delay,power,zeta2,p
db='pfly'
dbbg='pbg'
;; if delay eq 3.2 and power eq 20 then begin
;; sh=7609;&shbg=9
;; shcal=7610
;; ;shcal=7608;3kW
;; endif
;; if delay eq 3.2 and power eq 3 then begin
;; sh=7608
;; shcal=7610
;; endif

;; if delay eq 0 and power eq 20 then begin
;; sh=7594
;; shcal=7597
;; ;shcal=7596;3kw
;; endif

;; if delay eq 5 and power eq 0 then begin
;; sh=7611 ; yesfilter laser
;; shcal=7612 ; no fo;ter ;aser
;; ;shcal=7596;3kw
;; endif

;; if delay eq 5 and power eq -1 then begin
;; sh=7613 ; 1
;; shcal=7617 ;200
;; ;shcal=7596;3kw
;; endif

if delay eq 0 and power eq 20 then begin
sh=7624; ; 1
shcal=7626;17 ;200
;shcal=7625;3kw

endif

if delay eq 5  and power eq 20 then begin
sh=7630; ; 1
shcal=7631;17 ;200
;shcal=7629;3kw

endif




d=getimgnew(sh,0,db=db)*1. - getimgnew(sh,0,db=dbbg)

dcal=getimgnew(shcal,0,db=db)*1. - getimgnew(shcal,0,db=dbbg)



newdemod,d,cars,doplot=1,db=db,sh=sh,lam=488e-9,demodtype='magpienew2'


newdemod,dcal,carscal,doplot=1,db=db,sh=sh,lam=488e-9,demodtype='magpienew2'

zeta=abs(cars(*,*,1)/cars(*,*,0))
zetacal=abs(carscal(*,*,1)/carscal(*,*,0))
zeta2=zeta/zetacal

p=atan2(cars(*,*,1)/carscal(*,*,0))
stop
end

getzeta,5,20,z,p

end
