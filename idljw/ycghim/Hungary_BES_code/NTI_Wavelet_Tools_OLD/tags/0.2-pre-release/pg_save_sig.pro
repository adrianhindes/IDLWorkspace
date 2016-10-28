;+
; Name: pg_save_sig
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2007.12.28.
;
; Purpose: Save signals of AUG magnetic pick-up ciols to data/...sav using get_rawsignal.pro
;	for a given shot
;
; Calling sequence:
;	pg_save_sig, shots (vector)
;
; Input:
;	shot: shot numbers
;
; Output: -
;-

pro pg_save_sig,shots

shots=[shots,0]
;channels=['C04-01','C04-02','C04-16','C05-01','C05-20','C07-01','C07-02','C07-16'$
;	,'C09-01','C09-02','C09-03','C09-04','C09-05','C09-06','C09-07','C09-08','C09-09'$
;	,'C09-10','C09-11','C09-12','C09-14','C09-15','C09-16','C09-17','C09-18','C09-20'$
;	,'C09-21','C09-22','C09-23','C09-24','C09-25','C09-26','C09-27','C09-28','C09-29'$
;	,'C09-30','C09-31','C09-32','C10-01','C10-20','B31-01','B31-02','B31-03','B31-05','B31-06'$
;	,'B31-07','B31-08','B31-09','B31-10','B31-11','B31-12','B31-13','B31-14','B31-17'$
;	,'B31-18','B31-19','B31-20','B31-21','B31-22','B31-23','B31-24','B31-25','B31-26'$
;	,'B31-27','B31-28','B31-29']
for j=0,n_elements(shots)-2 do begin
	if where(shots(j) EQ [19807,19821,20975,21292,22154,22188,22265,22268,22310,22375,22377,22382,$
	   22501,22559,22565,23418,23824,23913,25740,25845,26941]) GT -1 then channels=['C04-01','C04-16','C05-01','C05-20','C07-01','C07-16'$
		,'C09-01','C09-02','C09-03','C09-04','C09-05','C09-06','C09-07','C09-08','C09-09'$
		,'C09-10','C09-11','C09-12','C09-14','C09-15','C09-16','C09-17','C09-18','C09-20'$
		,'C09-21','C09-22','C09-23','C09-24','C09-25','C09-26','C09-27','C09-28','C09-29'$
		,'C09-30','C09-31','C09-32','C10-01','C10-20','B31-01','B31-02','B31-03','B31-05','B31-06'$
		,'B31-07','B31-08','B31-09','B31-10','B31-11','B31-12','B31-13','B31-14','B31-30']
	if where(shots(j) EQ [19090,20040]) GT -1 then channels=['C04-01','C04-16','C05-01','C05-20','C07-01','C07-16'$
		,'C09-01','C09-02','C09-03','C09-04','C09-05','C09-06','C09-07','C09-08','C09-09'$
		,'C09-10','C09-11','C09-12','C09-14','C09-15','C09-16','C09-17','C09-18','C09-20'$
		,'C09-21','C09-22','C09-23','C09-24','C09-25','C09-26','C09-27','C09-28','C09-29'$
		,'C09-30','C09-31','C09-32','C10-01','C10-20','B31-01','B31-02','B31-03','B31-05','B31-06'$
		,'B31-07','B31-08','B31-09','B31-10','B31-11','B31-12','B31-13','B31-14']
  if where(shots(j) EQ [18931]) GT -1 then channels=['C04-01','C04-16','C05-01','C05-20','C07-01','C07-16'$
    ,'C09-01','C09-02','C09-03','C09-04','C09-05','C09-06','C09-07','C09-08','C09-09'$
    ,'C09-10','C09-11','C09-12','C09-14','C09-15','C09-16','C09-17','C09-18','C09-20'$
    ,'C09-21','C09-22','C09-23','C09-24','C09-25','C09-26','C09-27','C09-28','C09-29'$
    ,'C09-30','C09-31','C09-32','C10-01','C10-20','B31-01','B31-02','B31-03','B31-05','B31-06'$
    ,'B31-07','B31-08','B31-09','B31-10','B31-11','B31-12','B31-13','B31-14','B31-30']
 
	if NOT keyword_set(channels) then begin
		print,'Channels not defined for shot '+i2str(shots(j))
		continue
	endif
	channels='AUG_mirnov/'+channels
	for i=0,n_elements(channels)-1 do begin
    get_rawsignal,shots(j),channels(i),t,d,/movedata
	endfor
endfor

end