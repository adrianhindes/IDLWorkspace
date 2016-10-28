
pro dummy1, x

  help, x
  print, x

  return

end

function nag_aspline, x,y,smooth=smooth,weights=weights,xfit=xfit,scale=scale,$
                      warm=warm
;------------------------------------------------------------------------------
;
; NAG Spline fitter with auto-knot placement, based upon algorithm in
; [1].
;
; USES f77 NAG routines: E02BBF, E02BEF.
;
; x                    : Input x-array.
; y                    : Input y-array.
; weights  [optional]  : weights (=1/sigma_i : N.B. .NOT. 1/sigma_i^2).
; xfit     [optional]  : x-array for fit (if not set xfit=x).
; scale    [optional]  : Optionally scale smoothing parameter s by 'scale'
;
;------------------------------------------------------------------------------
;
; Notes:
;       If weights are not specified, spline will be an
;       interpolating spline (s=0.0).
;
;       If s is not specified, the central value of the
;       "suggested" smoothing parameter will be taken [1]:
;
;       s = sigma^2*(np +- sqrt(2*np)) -> np,
;
;       (unless weights are not specified, in which case S=0.0). 
;
;       sigma is the standard deviation of wi*yi 
;       (s.d. = +-wi*sigma_i = 1.0), i.e. we assume that the
;       correct weights are supplied. See NAG documentation for E02BEF.
;
;       Data are returned in a structure:
;
;          
;
; [1] : DIERCKX, P.   An Algorithm for Smoothing, Differentiating and
;       Integration of Experimental Data Using Spline Functions.
;       J.Comp.Appl. Maths., 1, pp., 165-184, 1975.
;
; [2] : REINSCH, C.H. Smoothing by Spline Functions. 
;       Num. Math., 10, pp. 177-183, 1967.
;
;------------------------------------------------------------------------------

COMMON SPLINE, n,lambda,c,fp,w,s

;- Initialize error flag:

iflag = 0

if(keyword_set(WARM)) then goto, warm_start

;- Ensure variable types/ranks are correct for passing to NAG:

np    = long(n_elements(x))

if(n_elements(y) ne np)then begin
   print, ':nag_spline : ERROR : n(x) .ne. n(y).'
   iflag =1
   goto, build
endif

x     = double(x)
y     = double(y)

if(not keyword_set(weights))then begin
   w = make_array(np,/double,value=1.0D0) 
endif else begin
   
   if(n_elements(weights) ne np)then begin
      print, ':nag_spline : ERROR : n(weights) .ne. np.'
      iflag =2
      goto, build
   endif

   w = double(weights)

endelse

if(n_elements(xfit) eq 0)then begin
   xfit = x
endif

if(not keyword_set(smooth))then begin

   if(not keyword_set(weights))then begin
      s = 0.0d0
   endif else begin
      s = double(np)
   endelse

endif else begin

   s    = double(smooth)

endelse

if(n_elements(scale) ne 0)then s=s*double(scale)

;- Set up NAG work arrays:

nest    = np + 4L
n       = 0L
ifail   = 0L
lambda  = dblarr(nest)
c       = dblarr(nest)
fp      = 0.0d0
lwrk    = 4L*np+16L*nest+41L
wrk     = dblarr(lwrk)
iwrk    = intarr(lwrk)


;- Test for NaNs in input data:

i = where(finite(x) eq 0)

if(i(0) ne -1)then begin
   print, ':nag_spline : ERROR : NaN/Inf detected in x.'
   iflag =3
   goto, build
endif

i = where(finite(y) eq 0)

if(i(0) ne -1)then begin
   print, ':nag_spline : ERROR : NaN/Inf detected in y.'
   iflag =4
   goto, build
endif

i = where(finite(w) eq 0)

if(i(0) ne -1)then begin
   print, ':nag_spline : ERROR : NaN/Inf detected in w.'
   iflag =5
   goto, build
endif

;------------------------------- NAG work -------------------------------------

;- Calculate Knots:

icount  = 0
ds      = s

while (icount ge 0 and icount lt 5) do begin

;- Set ifail for silent, soft exit (note, unlike e02bef, this works!):
   ifail = 1L
   help, ifail

   idl_e02bef, 'C', np, x, y, w, s, nest, n, lambda, c, fp, wrk, lwrk, iwrk, ifail

   if(ifail ne 0L)then begin
      print, ':nag_spline : ERROR : Failure in E02BEF Knot builder:',ifail

      if(ifail eq 5)then begin
         icount = icount + 1

         s = s + ds

         print, ':nag_spline : ERROR : Increase s....'
      endif else begin
         iflag = 100+ifail
         goto, build
      endelse
   endif else begin

      icount = -1

   endelse
endwhile

warm_start:

if(n le 0)then begin
   if(keyword_set(WARM))then print, ':nag_aspline : WARM START FAILURE'
   iflag = 6
   s     = 0.0
   goto, build
endif
   
xfit    = double(xfit)
ns      = n_elements(xfit)
yfit    = dblarr(ns)
iflg    = intarr(ns)

;- Calculate spline:

for i=0,ns-1 do begin

;-  xs and ys must be single real*8:

    ys = 0.0d0
    xs = xfit(i)

;-  For some strange reason, e02bbf is only working when ifail=0, so
;-  must trap anything that will cause output to screen:

    if(xs ge lambda(3) and xs le lambda(n-4) and n ge 8L)then begin

       ifail = 0L

       idl_e02bbf,n,lambda,c,xs,ys,ifail

;-     Store status of splined point:

       iflg(i) = ifail

    endif else begin

       iflg(i) = -1

    endelse

;-  If point OK, store in fit array:

    if(ifail eq 0L)then yfit(i) = ys

endfor

i = where(finite(yfit) eq 0)

if(i(0) ne -1)then begin
   print, ':nag_spline : ERROR : NaN/Inf detected FIT.'
   iflag =6
   goto, build
endif

;------------------------------------------------------------------------------

build:

;- Build return structure:

if(iflag ne 0)then begin
   NAG_STRC = CREATE_STRUCT ( 'iflag', iflag, $
                              's',     s )
endif else begin
   NAG_STRC = CREATE_STRUCT ( 'iflag', 0,       $
                              'istat', iflg,    $
                              'x',     x,       $
                              'y',     y,       $
                              'w',     w,       $
                              's',     s,       $
                              'xfit',  xfit,    $
                              'yfit',  yfit,    $
                              'c',     c,       $
                              'fp',    fp,      $
                              'lambda', lambda)
endelse

return, NAG_STRC
                              
end

