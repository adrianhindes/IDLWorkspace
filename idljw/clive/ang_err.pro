function ang_err, thx, thy, par=par,delta=delta

r=par.facetilt
ccrystal,par,n_e,n_o
th=sqrt(thx^2+thy^2)/sqrt(n_e*n_o)
ph=atan(thy,thx)-delta ;;+!pi/2 ; take away pi/2 to match exp
;phi=0 is ordinary axis with displacer, fringes are along
;extraordinary axis
err=-th *sin(ph) * tan(r) +  th^2 * (-cos(ph)* sin(ph) - cos(ph)* sin(ph)* tan(r)^2)

return,err
end
