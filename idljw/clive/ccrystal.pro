pro ccrystal,par,n_e,n_o,kappa=kappa
if par.crystal eq 'bbo' then cbbo,n_e=n_e,n_o=n_o,dnedl=dn_edl,dnodl=dn_odl,lambda=par.lambda
if par.crystal eq 'linbo3' then clinbo3,n_e=n_e,n_o=n_o,dnedl=dn_edl,dnodl=dn_odl,lambda=par.lambda
if par.crystal eq 'quartz' then cquartz,n_e=n_e,n_o=n_o,dnedl=dn_edl,dnodl=dn_odl,lambda=par.lambda
if par.crystal eq 'calcite' then ccalcite,n_e=n_e,n_o=n_o,dnedl=dn_edl,dnodl=dn_odl,lambda=par.lambda

if istag(par,'temperature') then begin
    if par.crystal eq 'bbo' then begin
;http://www.redoptronics.com/BBO-crystal.html
        dn_edt=-16.6e-6
        dn_odt=-9.3e-6
    endif
    if par.crystal eq 'linbo3' then begin
;http://www.lambdaphoto.co.uk/pdfs/Inrad_datasheet_LNB.pdf
        dn_edt = 37e-6 
        dn_odt = 3.3e-6
    endif
    n_e=n_e * (1 +dn_edt * par.temperature)
    n_o=n_o * (1 +dn_odt * par.temperature)
endif


nc=sqrt(n_o^2 * cos(par.facetilt)^2 + n_e^2 * sin(par.facetilt)^2 )


dncdl=(dn_odl*n_o*cos(par.facetilt)^2 + dn_edl*n_e*sin(par.facetilt)^2)/nc
fprime=dn_odl + (dncdl*n_e*n_o)/nc^2 - (dn_odl*n_e + dn_edl*n_o)/nc
f=n_o*(1-n_e/nc)
kappa=1-par.lambda * fprime/f


end
