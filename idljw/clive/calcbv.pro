shr=intspace(7345,7507)

nsh=n_elements(shr)

v1=fltarr(nsh)
v2=v1
common cbshot, shotc,dbc, isconnected
dbc='kstar'
for i=0,nsh-1 do begin
    shotc=shr(i)
    nbi1=cgetdata('\NB11_VG1')  ;\NB11_I0')
    nbi2=cgetdata('\NB12_VG1')
    v1(i)=max(nbi1.v)
    v2(i)=max(nbi2.v)
endfor

end

