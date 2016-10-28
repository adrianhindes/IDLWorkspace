function rebinc,z,a,b,c,d,e,f,g,sample=sample
zr=float(z)
zi=imaginary(z)
if n_params() eq 3 then begin
    zzr=rebin(zr,a,b,sample=sample)           ;,c,d,e,f,g,h)
    zzi=rebin(zi,a,b,sample=sample)           ;,c,d,e,f,g,h)
endif
if n_params() eq 4 then begin
    zzr=rebin(zr,a,b,c,sample=sample)           ;,c,d,e,f,g,h)
    zzi=rebin(zi,a,b,c,sample=sample)           ;,c,d,e,f,g,h)
endif


zz=complex(zzr,zzi)
return,zz
end
