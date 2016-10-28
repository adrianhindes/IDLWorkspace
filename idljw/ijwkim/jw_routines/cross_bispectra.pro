;+
;NAME:
;       cross_bispectra
;PURPOSE:
;       Return cross-bispectral density functions of two input records.
;       This follows the definition in Kim and Powers, IEEE
;       Trans. Plasma Sci. PS-7 #2 p. 120 (1979).



;CALLING SEQUENCE:
;       cross_bispectra,t,X,Y,Z,nd,f1,f2,f1_2d,f2_2d,bsquared,smooth=smoothie
;INPUT:
;       t  : time array
;       X  : first data record
;       Y  : second data record
;       Z  : third data record
;       nd : number of blocks to divide up the full X, Y, and Z records
;            into for averaging purposes
;
;KEYWORD PARAMETERS:
;       smooth : smoothing parameter used wherever an 'ensemble
;                average' is called for in the mathematical definition
;
;OUTPUT:
;       f1 : frequency array corresponding to X array
;       f2 : frequency array corresponding to Y array
;       f1_2d : 2-dimensional map of f1 values
;       f2_2d : 2-dimensional map of f2 values
;       bsquared : square of the bicoherence (2-d array, vs. f1 and f2)
;
;HISTORY:
;       Written 05-May-09 by T. Munsat
;-

FUNCTION add_bitnoise,x,level,verbose=verbose
   IF keyword_set(verbose) THEN print,'adding a dash of bitnoise...'
   xk = fft(x)
   r = 5*level*randomn(seed,n_elements(x),/normal)
   ;r1 = 20*dcomplex(1,0)*level*randomn(seed,n_elements(x),/normal)
   ;r2 = 20*dcomplex(0,1)*level*randomn(seed,n_elements(x),/normal)
   xk = xk+r
   newx = fft(xk,/inverse)
   return, newx
END

PRO cross_bispectra,t,X,Y,Z,f1,f2,f1_2d,f2_2d,bsquared,nd=nd,$
                    verbose=verbose,nobitnoise=nobitnoise ;,smooth=smoothie
  IF NOT keyword_set(nd) THEN nd=1
  IF NOT keyword_set(smoothie) THEN smoothie = 2
  ii      = dcomplex(0,1)
  npoints = n_elements(t)
  tsamp   = t(1)-t(0)

  N       = long(npoints/nd)
  Xk      = dcomplexarr(N,nd)
  Yk      = dcomplexarr(N,nd)
  Zk      = dcomplexarr(N,nd)
  ;Xk      = dcomplexarr(N)
  ;Yk      = dcomplexarr(N)
  ;Zk      = dcomplexarr(N)

  Bxyz_nd              = dcomplexarr(N,N,nd)
  Denominator_term1_nd = dcomplexarr(N,N,nd)
  Denominator_term2_nd = dcomplexarr(N,N,nd)
  ;Bxyz              = dcomplexarr(N,N)
  ;Denominator_term1 = dcomplexarr(N,N)
  ;Denominator_term2 = dcomplexarr(N,N)
  ;redundancy= intarr(N,N)       ;value 1 where bispectrum is redundant
  f             = dblarr(N)

  f0            = dindgen(N)/(N*tsamp)
  tfmax         = f0(N/2)*2
  f0(N/2+1:N-1) = f0(N/2+1:N-1) - tfmax
  shifter       = N/2-1
  f             = shift(f0,shifter)

  f1 = f
  f2 = f
  dummy = replicate(1,N)
  f1_2d = f1#dummy
  f2_2d = dummy#f2
  j_2d  = indgen(N)#dummy
  k_2d  = dummy#indgen(N)
  thirdindex = j_2d+k_2d - N/2
  finite_indicator = 0*thirdindex
  finite_indicator(where(thirdindex GE 0 AND thirdindex LT N)) = 1
  thirdindex = thirdindex*finite_indicator ;set out-of-range indices to zero

  ;wset,0
  ;contour,thirdindex,/fill,nlevels=25
  ;result=get_kbrd()

  FOR d=0,nd-1 DO BEGIN         ;chop up X,Y,Z into nd segments
     X2 = X( N*d : N*(d+1)-1 )
     Y2 = Y( N*d : N*(d+1)-1 )
     Z2 = Z( N*d : N*(d+1)-1 )

     level1 = 0.001
     level1 = 0.0005
     IF NOT keyword_set(nobitnoise) THEN BEGIN
        X2 = add_bitnoise(X2,level1,verbose=verbose)
        Y2 = add_bitnoise(Y2,level1,verbose=verbose)
        Z2 = add_bitnoise(Z2,level1,verbose=verbose)
     ENDIF

     X2 = X2-mean(X2)
     Y2 = Y2-mean(Y2)
     Z2 = Z2-mean(Z2)
     Xk = fft(X2,/double)
     Yk = fft(Y2,/double)
     Zk = fft(Y2,/double)
     Xk = shift(Xk,shifter)
     Yk = shift(Yk,shifter)
     Zk = shift(Zk,shifter)

     XjYk = Xk # Yk
     Zl   = Zk(thirdindex)

     Bxyz_nd             (*,*,d) = XjYk*conj(Zl)
     Denominator_term1_nd(*,*,d) = abs(XjYk)^2
     Denominator_term2_nd(*,*,d) = abs(Zl)^2

     ;*** Why is this smoothing necessary?!
     ;*** (It doesn't help anyway)
     ;Bxyz_nd             (*,*,d) = smooth(Bxyz_nd(*,*,d),2)
     ;Denominator_term1_nd(*,*,d) = smooth(Denominator_term1_nd(*,*,d),2)
     ;Denominator_term2_nd(*,*,d) = smooth(Denominator_term2_nd(*,*,d),2)

     ;print
     ;print,where(finite(Bxyz_nd) NE 1)
     ;print
     ;print,where(finite(Denominator_term1_nd) NE 1)
     ;print
     ;print,where(finite(Denominator_term2_nd) NE 1)
     ;result=get_kbrd()
  ENDFOR

  IF nd GT 1 THEN BEGIN
     Bxyz              = total(Bxyz_nd,3)/double(nd)
     Denominator_term1 = total(Denominator_term1_nd,3)/double(nd)
     Denominator_term2 = total(Denominator_term2_nd,3)/double(nd)
  ENDIF ELSE BEGIN
     Bxyz              = smooth(Bxyz_nd,2)
     Denominator_term1 = smooth(Denominator_term1_nd,2)
     Denominator_term2 = smooth(Denominator_term2_nd,2)
  ENDELSE

  ;wset,0
  ;!p.multi=[0,1,1]
  ;contour,abs(Bxyz),/fill,nlevels=25,title='Bxyz',zrange=[0,.00001]
  ;result=get_kbrd()


  Bxyz = Bxyz*finite_indicator

  ;wset,0
  ;!p.multi=[0,1,1]
  ;contour,abs(Bxyz),/fill,nlevels=25,title='Bxyz',zrange=[0,.00001]
  ;result=get_kbrd()


  ;Bxyz              = smooth(Bxyz,2)
  ;Denominator_term1 = smooth(Denominator_term1,2)
  ;Denominator_term2 = smooth(Denominator_term2,2)





  top = abs(Bxyz)^2
  bottom = (Denominator_term1*Denominator_term2)
  bsquared = abs(top/bottom)


  ;wset,0
  ;loadct,3
  ;!p.multi=[0,1,1]
  ;contour,bsquared,/fill,nlevels=25,title='bsquared within cross bispectra',zrange=[0,.5]
  ;result=get_kbrd()



  ;*** get rid of infinite values further up! ***

  ;Gets rid of infinite values
  tester = where(finite(bsquared) ne 1)
  IF tester(0) NE -1 THEN bsquared(tester) = 0.0
  bsquared = bsquared*finite_indicator

  ;Enforces upper bound of 1.0 -- why is this necessary?!
  tester = where(bsquared GT 1)
  IF tester(0) NE -1 THEN bsquared(tester) = 1.0


  ;wset,0
  ;!p.multi=[0,1,1]
  ;contour,bsquared,/fill,nlevels=25,title='bsquared within cross bispectra part 2',zrange=[0,.5]
  ;result=get_kbrd()

END
