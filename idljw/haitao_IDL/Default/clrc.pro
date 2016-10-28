pro clrc,contrast
restore, 'Contrast change with ratio at shorter delay.save'
d=reform(cont(48,*))
d1=1.0/r
lratio=interpol(d1, d, contrast, /LSQUADRATIC)
lratio1=interpol(d1, d, contrast+0.1, /LSQUADRATIC)
restore, 'Phase shift caused by carbon line ratio change.save'
d2=reform(phs(255,255,*))
ps=interpol(d2, clr, lratio, /LSQUADRATIC)
slope=deriv(clr, d2)
slope1=deriv(d, clr)
;return, ps
stop
end
;pro crv



slope=deriv()
psa=make_array(200,/float)
for i=0,199 do begin
  psa(i)=clrc(con(i))
  endfor
  stop
  end
