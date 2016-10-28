pro loadinterf, sh, d,ref,anal=anal,pmt=pmt,dt=dt,t0=t0
nch=22
if keyword_set(pmt) then nch=16
if keyword_set(anal) then nch=21
for i=0,nch-1 do begin
   tmp=read_datam(sh,i,anal=anal,pmt=pmt,dt=dt,t0=t0)
   if i eq 0 then nt=n_elements(tmp)
   if i eq 0 then d=fltarr(nt,keyword_set(pmt)  ? nch : nch-1)
   if i ne nch-1 or keyword_set(pmt) then d(*,i)=tmp(0:nt-1) else ref=tmp(0:nt-1)

endfor
end


;; 88895, 88894 voltage on/off
;; 190-225 is white mark
;; 88896 - 400V

;; 88897 - 200V

;; pl88898 - pmt off
;; 88899 - 15V off

;; 88900 - 15V on

;901 hv off
;902 200V
;903 200V, blackened dump view of what seeing

; try again 23rd nov, pulled apart but alas it works?
;88968 : voltge=250V, not much singal
;88969 : 350V, should be more signal
