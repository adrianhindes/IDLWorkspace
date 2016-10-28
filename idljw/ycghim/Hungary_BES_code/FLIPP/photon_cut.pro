pro photon_cut,corr,time,cut_length=cut_length,errormess=errormess,silent=silent,$
   extrapol_length=extrapol_length,extrapol_order=extrapol_order

; cut_length: microsecond delay range (-cut_length,+cut_length) in which
;             the autocorrelation functions are cut and extrapolated from
;             the edges of the interval (0 ==> no cut)
; extrapol_length: the length of the delay time interval from which the
;                  extrapolation around zero delay of the autocorrelation
;                  function is done
; extrapol_order: order of polynomial for extrapolation

default,cut_length,5
default,extrapol_length,cut_length*2
default,extrapol_order,1
              
errormess = ''
if (cut_length eq 0) then return

ttindex_c_p=where((time ge 0) and (time le cut_length))
ttindex_c_m=where((time lt 0) and (time ge -cut_length))
if ((ttindex_c_p(0) lt 0) and (ttindex_c_m(0) lt 0)) then return
                
if (ttindex_c_p(0) ge 0) then begin
  ttindex=where((time gt cut_length) and (time le cut_length+extrapol_length))
  if (n_elements(ttindex) lt 2) then begin
    errormess='Not enough time resolution. Cannot do photon cut.'
    if (not keyword_set(silent)) then print,errormess
    cut_length=0
    return
  endif
  tc=corr(ttindex)
  tt=time(ttindex)
  fitp=poly_fit(tt,tc,extrapol_order)
  
  time_c=time(ttindex_c_p)
  ttfit=fitp(0)
  for i=1,extrapol_order do ttfit=ttfit+fitp(i)*time_c^i
  corr(ttindex_c_p)=ttfit
endif

if (ttindex_c_m(0) ge 0) then begin
  ttindex=where((time lt -cut_length) and (time ge -cut_length-extrapol_length))
  if (n_elements(ttindex) lt 2) then begin
    errormess='Not enough time resolution. Cannot do photon cut.'
    if (not keyword_set(silent)) then print,errormess
    cut_length=0
    return
  endif
  tc=corr(ttindex)
  tt=time(ttindex)
  fitp=poly_fit(tt,tc,extrapol_order)
  
  time_c=time(ttindex_c_m)
  ttfit=fitp(0)
  for i=1,extrapol_order do ttfit=ttfit+fitp(i)*time_c^i
  corr(ttindex_c_m)=ttfit
endif
                                             

  
end

