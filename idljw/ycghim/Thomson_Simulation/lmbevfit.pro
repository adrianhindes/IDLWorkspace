;lmbevfit: combination of good bits from IDL's Bevington routine (Curvefit)
;and NR version of Levenberg-Marquardt routine (mrqfit, section 15.5).

function lmbevfit,x,y,sdev,a,$
		amask=amask, chisq=chisq, itmax=itmax, iter=iter,$
		noderivative=noderivative, function_name=function_name,tol=tol,$
		debug=debug,sigmaa=sigmaa,covariance=covariance,error=error,$
		dcoefs=dcoefs,_extra=extra
on_error,0

;20/5/05 NJC: adding capability to generate numerical derivatives, following
;approach used by CX code 'sigtestwrapper', and requiring the user to explicitly
;provide 'dcoefs' to inform us by how much each coef should be tweaked when
;generating forward differences.  Derivs are activated by supplying delcoefs
;as keyword.

;29/8/02 NJC: Now passing amask to the user function, but only when "extra"
;keywords are supplied: this is because we can't allow the routine to break
;for user functions which don't accept any keywords.  NB: amask is only
;supplied when pders are required, and the purpose of passing the mask to
;the user fcn is to allow it to skip the calculation of any pders that
;won't be used.

;21/5/02 NJC: Added "_extra" keyword to pass information down to the user's
;function. 

;11/12/01 NJC: Add 'error' keyword at request of Eric Arends to allow caller
;to establish whether any failures occurred during fitting.  Value of 'error'
;will be set to 0 if fit OK, 1 if failed to converge (this is not necessarily
;a serious problem of course and may be cured with more iterations or looser
;tolerance), 2 if failed in tight loop.  More return codes may be added if
;necessary...

;24/7/00: want the whole covariance matrix now, for looking at correlated
;errors.  This is messy simply because parameters can be locked, and thus
;the covariance matrix needs to be inserted piece-by-piece into a larger
;matrix with some rows and columns of zeros in it for the locked parms;
;this was also necessary on a smaller scale with the sigmaa vector.

;19/5/97: add the sigmaa keyword to return error estimate (fairly iffy) for
;each of the parms (0 for those that are locked).

;x is indep var, y is dep var, sdev is standard dev on y, a is parameter
;list for user function - must be initialised to guesses for first call
;amask is optional 'bitmask' to say which parameters to modify, use all if
;not specified, otherwise only fit parameters with mask entry =1, ignore 
;params with mask entry=0, undefined if other value ;-)
;chisq returns final chisqr value, itmax is limit on iterations, iter returns
;number of iterations performed, noderivative specifies that partial derivs
;are estimated numerically by forward differences, function_name specifies
;name of user function, defaults to 'stupid_function', tol specifies 
;convergence tolerance for chisqr.

;NB: function uses double precision for more or less everything...

if n_elements(function_name) eq 0 then function_name = "stupid_function"
if n_elements(tol) eq 0 then tol = 1d-3         ;Convergence tolerance
if n_elements(itmax) eq 0 then itmax = 20        ;Maximum # iterations

if size(/type,extra) ne 0 then doextra=1 else doextra=0

a=1d*a ; ensure double precision

nterms = n_elements(a)   ; # of parameters
if n_elements(amask) eq 0 then amask=intarr(nterms)+1
fitind=where(amask eq 1,nfit)
;if keyword_set(debug) then print,'varying coeffs ',strtrim(fitind,2)
nfree = n_elements(y) - nfit ; Degrees of freedom
if nfree le 0 then message, 'lmbevfit - not enough data points.'
lambda = 1d-3          ;Initial lambda
diag = lindgen(nfit)*(nfit+1) ; Subscripts of diagonal elements
pder = dblarr(n_elements(y), nfit)
pderfcn = dblarr(n_elements(y), nterms) ; the array passed to the function has
	;the full nterms rows in it...

;weighting for standard dev:
w=1d/sdev^2

for iter=1,itmax do begin
 ; do num. derivs later...
 if keyword_set(debug) then print,'starting iter ',strtrim(iter,2)

 if not keyword_set(dcoefs) then begin
  if doextra then call_procedure, function_name, x, a, yfit, pderfcn, amask=amask, _extra=extra $
   else call_procedure, function_name, x, a, yfit, pderfcn
  pder=pderfcn(*,fitind) ;throw away the ones we don't need
	;should consider allowing user function to know which partial derivs
	;we don't actually need in case it's expensive to evaluate them
  endif else begin
   ;...we need to generate numerical derivatives:
   if keyword_set(debug) then print,'getting numerical derivatives'
   if doextra then call_procedure, function_name, x, a, yfit, _extra=extra $
    else call_procedure, function_name, x, a, yfit
   ;that's the first call, to get a baseline yfit
   ;now we need to tweak each unlocked coef, one at a time:
   ;dcoefs values >0 mean add a little, <0 mean multiply by abs() of value
   for c=0,nterms-1 do begin
	if not amask[c] then continue
	amod=a
	modc=dcoefs[c]
	if modc gt 0 then amod[c]=amod[c]+modc else amod[c]=amod[c]*abs(modc)
	if doextra then call_procedure, function_name, x, amod, ymod, _extra=extra $
	  else call_procedure, function_name, x, amod, ymod
	pderfcn[*,c]=(ymod-yfit)/(amod[c]-a[c])

    endfor
   pder=pderfcn(*,fitind) ;throw away the ones we don't need
  endelse

 beta=transpose( (y-yfit)*w # pder)
 alpha=transpose(pder) # (w#(fltarr(nfit)+1)*pder)
 chisq=total(w*(y-yfit)^2)
 if keyword_set(debug) then print,'Chisq is ',strtrim(chisq,2)

 ;could now decide not to iterate as curvefit does based on absolute value
 ;of chisq but leave that for the moment...

 ;now enter tight loop (with safety iteration count), which should be 
 ;guaranteed to reduce chisq unless we hit numerical roundoff limits or
 ;overflow limits or we have a problem with the partial derivatives, since
 ;it will eventually just be stepping down the gradient in smaller and smaller
 ;steps.  Presumably this breaks if we are at the definitive minimum though :-)
 ;(hmm, well loop ends if new chisqr le old, so maybe ok...)

 error=0 ;default return code is 0
 tightcount =0
 repeat begin
	alphap=alpha
	alphap(diag)=alphap(diag)*(1d +lambda)
	covar=invert(alphap)
	ainc= covar # beta ; this only has nfit terms in it...
	ap=a ; ap is our aprime: new guesses
	ap(fitind)=ap(fitind)+ainc ;slot the deltas in the right spots
	;if keyword_set(debug) then print,'guess increments= ',strtrim(ainc,2)
	if doextra then call_procedure, function_name, x, ap, yfit, _extra=extra $
	  else call_procedure, function_name, x, ap, yfit
	chinew=total(w*(y-yfit)^2)
	if keyword_set(debug) then print,'New chisq (tightloop) is ',strtrim(chinew,2)
	lambda=10d*lambda ; assume fit got worse
	tightcount=tightcount+1
 endrep until chinew le chisq or tightcount gt 100

 if tightcount gt 100 then begin
	;don't crash out anymore
	;;message,'lmbevfit: failed in tight loop - pder prob?'
	print,'lmbevfit: failed in tight loop - pder prob?'
	error=2
	return,yfit-yfit ; i.e. return 0 vector
      end

 ;otherwise, all is well: update stuff and reduce lambda
 lambda=lambda/100d ; was multiplied by 10 already so divide by 100
 a=ap
 if ((chisq-chinew)/chisq) le tol then goto,done ;sufficiently small change ?
endfor

;finished for-loop so must be out of iterations
message,"lmbevfit: didn't converge",/info
error=1

done: 
chisq=chinew
if keyword_set(debug) then print,'Final chisqr= ',strtrim(chisq,2)

;sigmaa:
if arg_present(sigmaa) then begin
 sigmaa=dblarr(nterms)
 covar2=invert(alpha)
 ;revert to alpha matrix instead of alphap because the lambda correction to
 ;alphap would change the values of the covariances, corrupting our already
 ;dodgy error estimates even further...
 tmp=sqrt(covar2(diag)) 
 sigmaa(fitind)=tmp  ;fill in the relevant unlocked parms with sigmaa values
end

;covariance:
if arg_present(covariance) then begin
 ;make covar2 matrix if not yet made:
 if n_elements(covar2) eq 0 then covar2=invert(alpha)
 ;now need to fill in the covariance matrix non-zero entries based on the
 ;covar2 matrix entries:
 covariance=dblarr(nterms,nterms)
 for i=0,nfit-1 do for j=0,nfit-1 do covariance[fitind[i],fitind[j]]=covar2[i,j]
end


return,yfit

end
