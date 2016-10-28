FUNCTION FUNC, P
COMMON FUNC_XY, X, Y
RETURN, MAX(ABS(Y - (P[0] + P[1] * X)))
END
; Put the data points into a common block so they are accessible to
; the function: 
COMMON FUNC_XY, X, Y
; Define the data points:
X = FINDGEN(17)*5
Y = [ 12.0,  24.3,  39.6,  51.0,  66.5,  78.4,  92.7, 107.8, $
    120.0, 135.5, 147.5, 161.0, 175.4, 187.4, 202.5, 215.4, 229.9]
; Call the function. Set the fractional tolerance to 1 part in
; 10^5, the initial guess to [0,0], and specify that the minimum
; should be found within a distance of 100 of that point: 
R = AMOEBA(1.0e-5, SCALE=1.0e2, P0 = [0, 0], FUNCTION_VALUE=fval)
; Check for convergence:
IF N_ELEMENTS(R) EQ 1 THEN MESSAGE, 'AMOEBA failed to converge'
; Print results:
PRINT, 'Intercept, Slope:', r, $
       'Function value (max error): ', fval[0]
END