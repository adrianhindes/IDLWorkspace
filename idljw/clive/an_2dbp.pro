@pr_prof2
;goto,ee

sh=intspace(82811,82819)
nsh=n_elements(sh)
rad=fltarr(nsh)
for i=0,nsh-1 do begin
readpatchpr,sh(i),str,data=data
stop

rad(i)=
endfor

end
