;The next function is the Selden function that will be needed a lot.
;The inputs are the temperature,T in eV, the wavelength the function is to be
;evaluated at (lambda), the scattering angle (theta), and the laser wavelength
;(laserlam) which must be in the same units as lambda.  In this application we
;have both in angstroms.

;The following function can also return the derivative of the Selden equation with
;respect to temperature, given the same parameters as the function Selden
;above.

FUNCTION SELDEN,T,lambda,theta,laserlam,DTe=dte
                                     
	me=9.10956e-31 ;9.11e-31		; electron mass
	c=2.997925e8; 3.0e8			; speed of light
	k=1.60219e-19 ;1.6e-19		; boltzmann
	
	T=DOUBLE(T)					; electron temperature
	lambda=DOUBLE(lambda)		; wavelength
	laserlam=DOUBLE(laserlam[0])	; laser wavelength
	theta=theta[0]				; scattering angle
	

	alpha=me*c^2/(2*k*T)
	epsilon=lambda/laserlam-1.
  
	N = SQRT(alpha/!PI)*(1-15./(16.*alpha)+345./(512.*alpha^2))

	A = (1+epsilon)^3 * SQRT(2*(1-COS(theta))*(1+epsilon)+epsilon^2)

	B = SQRT(1+epsilon^2/(2*(1-COS(theta))*(1+epsilon))) - 1

	dNdalpha=(1/(2*SQRT(alpha))+15/(32*alpha^1.5)-1035/(1024*alpha^2.5))/SQRT(!PI)

	dalphadT=-alpha/T



	result=N/A*EXP(-2*alpha*B)

	IF KEYWORD_SET(dTe) THEN result=dalphadT*(dNdalpha/N-2*B)*result

	RETURN,result

END
