pro potential_check

   bpp_position = dblarr(4)
   for i = 0L, 4-1 do begin
      bpp_position[i] = 230.0+10.0*i
   endfor

   potential_avg = dblarr(4)
   density_avg = dblarr(4)
   shot_number = 87776
   trange = [0.05, 0.07]
   a = getpar(shot_number,'isatfork',y=y1,tw=trange)
   a = getpar(shot_number,'vfloatfork',y=y2,tw=trange)
   d1 = select_time(y1.t,y1.v,trange)
   d2 = select_time(y2.t,y2.v,trange)
   potential_avg[0] = mean(d1.yvector)
   density_avg[0] = mean(d2.yvector)
   
   shot_number = 87782
   a = getpar(shot_number,'isatfork',y=y1,tw=trange)
   a = getpar(shot_number,'vfloatfork',y=y2,tw=trange)
   d1 = select_time(y1.t,y1.v,trange)
   d2 = select_time(y2.t,y2.v,trange)
   potential_avg[1] = mean(d1.yvector)
   density_avg[1] = mean(d2.yvector)
   
   shot_number = 87794
   a = getpar(shot_number,'isatfork',y=y1,tw=trange)
   a = getpar(shot_number,'vfloatfork',y=y2,tw=trange)
   d1 = select_time(y1.t,y1.v,trange)
   d2 = select_time(y2.t,y2.v,trange)
   potential_avg[2] = mean(d1.yvector)
   density_avg[2] = mean(d2.yvector)
   
   shot_number = 87803
   a = getpar(shot_number,'isatfork',y=y1,tw=trange)
   a = getpar(shot_number,'vfloatfork',y=y2,tw=trange)
   d1 = select_time(y1.t,y1.v,trange)
   d2 = select_time(y2.t,y2.v,trange)
   potential_avg[3] = mean(d1.yvector)
   density_avg[3] = mean(d2.yvector)
   
   ycplot, bpp_position, potential_avg
   ycplot, bpp_position, density_avg


end