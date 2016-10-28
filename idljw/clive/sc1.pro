pro sc1
;removed crystal
d=[$
[89 ,   457.93],$
[91 ,   465.79],$
[93 ,   476.48],$
[95 ,   487.98],$ 
[97 ,   496.51],$
[99 ,   501.71],$
[101,   514.53]]

;d(0,*) = d(0,*)-89 + 105;1st dataset, wed 7th may
d(0,*) = d(0,*)-89 + 119 & tmp=d(*,0) & d(*,0)=d(*,1) & d(*,1)=tmp;2nd datasethot
;d(0,*) = d(0,*)-89 + 133 ;, wed 8th may cold
;d(0,*) = d(0,*)-89 + 147 ;, wed 8th may hot

;d(0,*) = d(0,*)-89 + 165 ;, wed 8th may 4 crystal cell

;d(0,*) = d(0,*)-89 + 179 ;, wed 9th may 4 crystal cell, cooler

;d(0,*) = d(0,*)-89 + 67 ;, old dataset, 4 crystal
;193 is he

;195 is he
;197->210 is laser
;211 is he
;d(0,*) = d(0,*)-89 + 197 


;stop
testit2c_wb1, d(0,3),d(1,3)*1e-9 
for i=0,6 do begin
   testit2c_wb1, d(0,i),d(1,i)*1e-9 ,shbase=d(0,3)
;   stop
endfor
for i=0,6 do  wbsp4,d(1,i),d(0,i),shcorr=d(0,3),doresid=1,fout='~/kagain.txt'
end

pro sc1b
;testit2c_wb1, 161,514.53*1e-9 
;testit2c_wb1, 163,514.53e-9 ,shbase=161
wbsp4, 514.53, 161, shcorr=161,doresid=1
wbsp4, 514.53, 163, shcorr=161,doresid=1
end

