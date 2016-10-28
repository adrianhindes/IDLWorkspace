

  trange = [0.06, 0.08]
  frng=[50e3,200e3]
;  shot_number= 86418
;  shot_number = 82766
;  shot_number = 88467
;  shot_number = 82834
;  shot_number = 88533
;  shot_number = 86418
  shot_number = 86428
  
  
  a = getpar(shot_number,'isat',y=y1,tw=trange)
  b = getpar(shot_number,'isatfork',y=y2,tw=trange) ;[mm]
  
  c = jw_corr_measure(y1.t, ch1_array=y1.v, ch2_array=y2.v,trange=trange, freq_filter = frng)
  
  ycplot, c.tvector, c.corr, out_base_id = oid
  ycplot, c.tvector, c.corr_en, oplot_id = oid
  
  d = cctd(y1.t, ch1_array=y1.v, ch2_array=y2.v,trange=trange, freq_filter = frng, distance = 120.0, /cross_plot)
  
  window,0
  plot, d.tvector, d.velocity, yr=[0, 10.0^5.0]

end