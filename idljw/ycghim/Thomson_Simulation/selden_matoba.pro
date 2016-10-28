;The next function is the Selden function that will be needed a lot.
;The inputs are the temperature,T in eV, the wavelength the function is to be
;evaluated at (lambda), the scattering angle (theta), and the laser wavelength
;(laserlam) which must be in the same units as lambda.  In this application we
;have both in angstroms.

;The following function can also return the derivative of the Selden equation with
;respect to temperature, given the same parameters as the function Selden
;above.


; 	MODIFIED APRIL - 04 RDS
; 	ADD MATOBA YOSHIDA NAITO CORRECTION
; 	' ANALYTICAL FORMULA FOR FULLY RELATIVISTIC THOMSON SCATTERING SPECTRUM'
; 	THIS CORRECTION ONLY REALLY MATTERS UPWARDS OF 5/10keV after which point integral(selden) ne laserlam
;	THE CORRECTIONS FROM POLARIZATION AGREE WELL WITH THOSE

FUNCTION SELDEN_MATOBA,T,lambda,theta,laserlam,DTe=dte
                                     
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



	selden = N/A*EXP(-2*alpha*B)

	DseldenDte = dalphadT*(dNdalpha/N-2*B)*selden


	; MATOBA PART
       
       x = sqrt( 1 + epsilon*epsilon/(2d*(1-cos(theta))*(1+epsilon)) )
       u = sin(theta)/(1-cos(theta))
       
       y = 1d/sqrt(x^2 + u^2)
       
       eta = y/(2d*alpha)
       
       zeta = x*y
       
	; this is the matoba (1,1) approximation      	
	q_num=4*eta*zeta*(2*zeta-2*eta+3*eta*zeta*zeta)
	q_denom=(2*zeta-eta*(2-15*zeta*zeta))
    
       q = 1 - q_num/q_denom
       
       matoba = q
       
       IF KEYWORD_SET(dTe) THEN BEGIN 
       
       		Dq_numDeta = 8*zeta^2 - 8*eta*zeta + 24*eta*zeta^3
		Dq_denom = -2+15*zeta^2
       
       		DqDeta = -(q_denom*Dq_numDeta - q_num*Dq_denom)/q_denom^2
       
       		DetaDalpha = -eta/alpha
       
       		DmatobaDte = DqDeta * DetaDalpha * DalphaDT
		
		RETURN,selden * DmatobaDte +matoba*DseldenDte
	ENDIF
       


	RETURN,selden*matoba

END
