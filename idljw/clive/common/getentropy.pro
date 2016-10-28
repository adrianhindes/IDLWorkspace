pro getentropy, acoeff, ent, pder;,hess
ent = total( alog(float(acoeff)) )
pder = 1./acoeff
na=n_elements(acoeff)

end
