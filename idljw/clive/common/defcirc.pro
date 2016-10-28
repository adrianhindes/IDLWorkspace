pro defcirc,fill=fill
    ncirc=20
    xsym=fltarr(ncirc) & ysym=fltarr(ncirc)
    for i=0,ncirc-1 do begin
        xsym(i)=1*cos(2*!pi*float(i)/float(ncirc-1))
        ysym(i)=1*sin(2*!pi*float(i)/float(ncirc-1))
    endfor

    usersym, xsym, ysym,fill=fill
end
