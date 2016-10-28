pro lktms,sh,data,noplot=noplot,qty=qty,yr=yr
default,qty,'te'
nch=10
mdsopen,'kstar',sh

for i=0,nch-1 do begin
nd='\KSTAR::TOP.ELECTRON.TS_CORE:TS_CORE'+string(i+1,format='(I0)')+':CORE'+string(i+1,format='(I0)')+'_'+strupcase(qty)
y=mdsvalue(nd)

if i eq 0 then  begin
nt=n_elements(y)
data=fltarr(nt,nch)
t=mdsvalue('DIM_OF('+nd+')')
endif
data(*,i)=y
endfor
if not keyword_set(noplot) then plotm,data,yr=yr
end

