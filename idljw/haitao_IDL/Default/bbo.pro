function BBO, lambda, n_e=n_e, n_o=n_o, dnedl=dnedl, dnodl=dnodl, dmudl=dmudl,kapa=kapa

;wavelength input in nm

ao = double([2.7359,.01878,.01822,-.01354])
ae = double([2.3753,.01224,.01667,-.01516])



l = lambda*1d-3    ;wavelength in microns
n_e = sqrt(ae(0)+ae(1)/(l^2-ae(2))+ae(3)*l^2)
n_o = sqrt(ao(0)+ao(1)/(l^2-ao(2))+ao(3)*l^2)
dnedl = l/n_e*(-ae(1)/(l^2-ae(2))^2+ae(3))
dnodl = l/n_o*(-ao(1)/(l^2-ao(2))^2+ao(3))
dmudl = dnodl-dnedl
kapa=1+l*dmudl/(n_e-n_o)
return, n_e-n_o
end
