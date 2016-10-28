function svdinverse, nimpacts, nrad, matrix


svdc, matrix, svals, U, V, /double


n = size(svals, /N_ELEMENTS) ;number of singular values for svals

s = FLTARR(nimpacts, nimpacts) ;Creates the Singular values matrix, where Svals is the diagonal matrix in A = U Svals V^T
for K = 0, n-1 do s[K,K] = svals[K]

;Truncation code
;i = WHERE(s LT 0.0001, count) ;zero small singular values
;IF (count GT 0) THEN s[i] = 0


inverted = V ## invert(s) ## transpose(U)

return, inverted

end