

pro dfunc, acoefft, ent=ent, chisq=chisq,$
                grads=pderent, gradc=pder
common fblock2, matr_s, tmatr_s, rcoeff_s
getchisq, matr_s, tmatr_s, acoefft, rcoeff_s,chisq,pder
getentropy, acoefft, ent, pderent
end
