function emiss, lamnm, temp=temp
lam=lamnm*1e-9
clight=3d8
hplank=6.62606957d-34
kbolt=1.3806488d-23
nu = clight/lam
;inten = 2*hplank * nu^3 / clight^2 * 1. / (exp(hplank*nu / (kbolt*temp) ) - 1.)
;radiance in J/s/m^2/str / (Hz)
;inten = inten * clight / lam^2 / 1d9 ; radiance in J/s/m^2/str/nm
inten = 2 * hplank * clight^2 / lam^5 * 1/(exp(hplank*nu / (kbolt*temp) ) - 1.) ; radiance in J/s/m^2/str / m
inten=inten / 1e9 ; per nm
photon = inten / (hplank * nu)
;radiance in photons/s/m^2/str / nm
return,photon
end


e=transpose((read_ascii('~/cdata/ipad_100ms.txt',data_start=12)).(0))
e0=transpose((read_ascii('~/cdata/black_ipad_100ms.txt',data_start=12)).(0))
f=transpose((read_ascii('~/cdata/oven_10ms_1187C.txt',data_start=12)).(0))

;.txt
l=e(*,1)
e=e(*,3)
e0=e0(*,3)
f=f(*,3)
iz=where(l ge 250 and l le 350)
e-=mean(e(iz))
e0-=mean(e0(iz))
f-=mean(f(iz))
e0(*)=0.
plot,l,e
oplot,l,e0,col=2
oplot,l,f,col=4
;stop
ratio=((e-e0) / 100.) / ((f-e0)/10.)
radref=emiss(l,temp=(1187.+273));C to K

plot,l,(e-e0)/100.,xr=[400,700],/ylog,yr=[1e-1,1e4]
oplot,l,(f-e0)/10.,col=2
oplot,l,radref/max(radref)*1e6,col=4

stop
sens=(f-e0)/10. / radref
plot,l,sens,xr=[400,700]
stop
;plot,l,ratio,yr=[0,1];,/noer,col=6
;stop
rad = radref * ratio
;stop
plot,l,rad,xr=[400,700],xsty=1
;save,l,rad,file='~/ipad_radiance.sav',/verb

end
