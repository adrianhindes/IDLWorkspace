function jw_select_time, tvector, yvector, trange
  tv_temp = tvector[WHERE(tvector GE trange[0])]
  yv_temp = yvector[WHERE(tvector GE trange[0])]
  tv = tv_temp[WHERE(tv_temp LT trange[1])]
  yv = yv_temp[WHERE(tv_temp LT trange[1])]
  result = CREATE_STRUCT('tvector',tv,'yvector',yv)
  return, result
end
