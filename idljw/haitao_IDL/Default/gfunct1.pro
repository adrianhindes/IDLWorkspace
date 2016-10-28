PRO gfunct1, X, A, F,pder

  bx = EXP(A[1] * X)

  F = A[0] * bx + A[2]

 IF N_PARAMS() GE 4 THEN $

    pder = [[bx], [A[0] * X * bx], [replicate(1.0, N_ELEMENTS(X))]]

 

END

