function bbo_sell, lambda, n_e=n_e, n_o=n_o, dnedl=dnedl, dnodl=dnodl, dmudl=dmudl
;
; calculate ne, no using the sellmeier equation
; CASIX website
;
; these are bBBO
ao = double([2.7359,.01878,.01822,-.01354])
ae = double([2.3753,.01224,.01667,-.01516])

;Scott Silburn's numbers - aBBO - incorrect
;ao = double([2.7471, 0.01878, 0.01822, - 0.01354])
;ae = double([2.3174, 0.01224, 0.01667, - 0.01516])

l = lambda*1d6    ;wavelength in microns
n_e = sqrt(ae(0)+ae(1)/(l^2-ae(2))+ae(3)*l^2)
n_o = sqrt(ao(0)+ao(1)/(l^2-ao(2))+ao(3)*l^2)
dnedl = l/n_e*(-ae(1)/(l^2-ae(2))^2+ae(3))
dnodl = l/n_o*(-ao(1)/(l^2-ao(2))^2+ao(3))
dmudl = dnodl-dnedl

return, n_e-n_o
end

;--------------------------------------------------------------------
;function bbo, thickness, lambda, biref=biref, dnedl=dnedl, dnodl=dnodl, dmudl=dmudl,  $
                 ;n_e=n_e, n_o=n_o, kappa=kappa
;+
; return #waves delay caused by birefringent LiTaO3 crystal
; kappa is the group delay factor.  Total group delay is twopi * #waves * (1 + k)
; all input parameters are in MKS units
;-

    ;biref = bbo_sell(lambda, n_e=n_e, n_o=n_o, dnedl=dnedl, dnodl=dnodl, dmudl=dmudl)
   ; kappa = lambda*1.e6/biref*dmudl
   ; dnedl = dnedl*1e6
    ;dnodl = dnodl*1e6

;return, biref*thickness/lambda

;end


