function jw_quad_fit , time, value

  expr = 'p[0]*(x-p[1])^2+p[2]'
  start = [-1.0d, 0.0001d, 1.0d]
  result= mpfitexpr_noprint(expr, time, value,rerr, start)

  return, result
end
